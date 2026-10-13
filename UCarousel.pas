unit UCarousel;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  Vcl.GraphUtil;

type
  TItemCarousel = record
    Titulo: string;
    Categoria: string;
    Descricao: string;
    CorInicio: TColor;
    CorFim: TColor;
  end;

  TfmCarousel = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    pnlCarousel: TPanel;
    btnAnterior: TSpeedButton;
    btnProximo: TSpeedButton;
    pnlViewport: TPanel;
    pbCarousel: TPaintBox;
    pbIndicadores: TPaintBox;
    lblPosicao: TLabel;
    chkAutoPlay: TCheckBox;
    pnlDetalhe: TPanel;
    imgDetalhe: TImage;
    lblDetCategoria: TLabel;
    lblDetTitulo: TLabel;
    lblDetDescricao: TLabel;
    lblDetContador: TLabel;
    lblDica: TLabel;
    tmrAnimacao: TTimer;
    tmrAutoPlay: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnAnteriorClick(Sender: TObject);
    procedure btnProximoClick(Sender: TObject);
    procedure pbCarouselPaint(Sender: TObject);
    procedure pbCarouselMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure pbCarouselMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure pbCarouselMouseLeave(Sender: TObject);
    procedure pbIndicadoresPaint(Sender: TObject);
    procedure pbIndicadoresMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure tmrAnimacaoTimer(Sender: TObject);
    procedure tmrAutoPlayTimer(Sender: TObject);
    procedure chkAutoPlayClick(Sender: TObject);
  private
    { Private declarations }
    FItens: TArray<TItemCarousel>;
    FImagens: TArray<TBitmap>;
    FPrimeiro: Integer;     // primeiro card visível
    FSelecionado: Integer;  // card clicado (-1 = nenhum)
    FHover: Integer;        // card sob o mouse (-1 = nenhum)
    FMouseDentro: Boolean;
    FOffset: Double;        // deslocamento atual da faixa, em pixels
    FAlvo: Double;          // deslocamento que a animação quer alcançar
    procedure CarregarItens;
    function GerarImagem(const AItem: TItemCarousel; AIndice: Integer): TBitmap;
    function IndiceNaPosicao(X, Y: Integer): Integer;
    function IndicadorNaPosicao(X: Integer): Integer;
    function MaxPrimeiro: Integer;
    procedure IrPara(APrimeiro: Integer);
    procedure Anterior;
    procedure Proximo;
    procedure SelecionarItem(AIndice: Integer);
    procedure ReiniciarAutoPlay;
  public
    { Public declarations }
  end;

var
  fmCarousel: TfmCarousel;

implementation

{$R *.dfm}

const
  VISIVEIS = 3;
  CARD_W = 264;
  CARD_TOP = 2;
  CARD_PAD = 4;
  IMG_H = 144;              // (CARD_W - 2 * CARD_PAD) em 16:9
  LEGENDA_H = 26;
  CARD_H = CARD_PAD + IMG_H + LEGENDA_H;
  ESPACO = 16;
  PASSO = CARD_W + ESPACO;

  IMG_LARGURA = 480;        // tamanho das imagens geradas (= tamanho do imgDetalhe)
  IMG_ALTURA = 270;

  DOT = 10;
  DOT_ESPACO = 10;

  COR_DESTAQUE = $00CB6B0B; // #0B6BCB
  COR_HOVER = $00EBC69A;    // #9AC6EB
  COR_BORDA = $00E1DDD9;
  COR_SOMBRA = $00E6E2DE;
  COR_TEXTO = $00332B26;
  COR_INATIVO = $00D2CDC8;

function Misturar(ACor1, ACor2: TColor; APeso: Double): TColor;
var
  vC1, vC2: Longint;
begin
  vC1 := ColorToRGB(ACor1);
  vC2 := ColorToRGB(ACor2);
  Result := RGB(
    Round(GetRValue(vC1) + (GetRValue(vC2) - GetRValue(vC1)) * APeso),
    Round(GetGValue(vC1) + (GetGValue(vC2) - GetGValue(vC1)) * APeso),
    Round(GetBValue(vC1) + (GetBValue(vC2) - GetBValue(vC1)) * APeso));
end;

procedure TextoComSombra(ACanvas: TCanvas; X, Y: Integer; const ATexto: string);
var
  vCor: TColor;
begin
  vCor := ACanvas.Font.Color;
  ACanvas.Brush.Style := bsClear;
  ACanvas.Font.Color := $00303030;
  ACanvas.TextOut(X + 2, Y + 2, ATexto);
  ACanvas.Font.Color := vCor;
  ACanvas.TextOut(X, Y, ATexto);
end;

{ TfmCarousel }

procedure TfmCarousel.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  CarregarItens;
  SetLength(FImagens, Length(FItens));
  for i := 0 to High(FItens) do
    FImagens[i] := GerarImagem(FItens[i], i);

  FPrimeiro := 0;
  FSelecionado := -1;
  FHover := -1;
  FOffset := 0;
  FAlvo := 0;
  IrPara(0);
  tmrAutoPlay.Enabled := chkAutoPlay.Checked;
end;

procedure TfmCarousel.FormDestroy(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to High(FImagens) do
    FImagens[i].Free;
end;

procedure TfmCarousel.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_LEFT:
      begin
        Anterior;
        ReiniciarAutoPlay;
        Key := 0;
      end;
    VK_RIGHT:
      begin
        Proximo;
        ReiniciarAutoPlay;
        Key := 0;
      end;
  end;
end;

procedure TfmCarousel.CarregarItens;

  function Item(const ATitulo, ACategoria, ADescricao: string; ACorInicio, ACorFim: TColor): TItemCarousel;
  begin
    Result.Titulo := ATitulo;
    Result.Categoria := ACategoria;
    Result.Descricao := ADescricao;
    Result.CorInicio := ACorInicio;
    Result.CorFim := ACorFim;
  end;

begin
  FItens := [
    Item('Nascer do sol no campo', 'Paisagem',
      'Os primeiros raios de sol iluminam a lavoura ainda coberta pelo orvalho. ' +
      'É o horário em que o trabalho no campo começa e a temperatura ainda está amena.',
      RGB(255, 153, 51), RGB(255, 94, 98)),
    Item('Lavoura de soja', 'Agricultura',
      'Plantas de soja em pleno desenvolvimento vegetativo, com o dossel fechado. ' +
      'Nessa fase o monitoramento de pragas e doenças é decisivo para a produtividade.',
      RGB(86, 171, 47), RGB(168, 224, 99)),
    Item('Colheita do milho', 'Agricultura',
      'Colheitadeira trabalhando na safrinha de milho. ' +
      'A umidade do grão é medida antes da colheita para reduzir custos de secagem.',
      RGB(247, 183, 51), RGB(252, 74, 26)),
    Item('Armazém de grãos', 'Logística',
      'Silos metálicos que recebem, secam e armazenam a produção. ' +
      'O controle de temperatura e umidade preserva a qualidade do grão por meses.',
      RGB(67, 97, 238), RGB(76, 201, 240)),
    Item('Rio e mata ciliar', 'Meio ambiente',
      'A vegetação nas margens protege o rio contra erosão e assoreamento. ' +
      'É área de preservação permanente e serve de corredor para a fauna local.',
      RGB(17, 153, 142), RGB(56, 239, 125)),
    Item('Céu de tempestade', 'Clima',
      'Nuvens carregadas se formam no fim da tarde, típicas do início do período chuvoso. ' +
      'A chuva regular marca o momento ideal para o plantio da safra.',
      RGB(44, 62, 80), RGB(76, 161, 175)),
    Item('Pôr do sol no cerrado', 'Paisagem',
      'O céu alaranjado sobre a vegetação do cerrado ao fim do dia. ' +
      'A estação seca deixa o ar limpo e as cores do entardecer mais intensas.',
      RGB(238, 9, 121), RGB(255, 106, 0)),
    Item('Plantio direto', 'Agricultura',
      'Semeadura feita sobre a palhada da cultura anterior, sem revolver o solo. ' +
      'A técnica conserva umidade, reduz erosão e aumenta a matéria orgânica.',
      RGB(131, 96, 195), RGB(46, 191, 145)),
    Item('Transporte da safra', 'Logística',
      'Carretas graneleiras levando a produção da fazenda até o armazém. ' +
      'Cada carga é pesada e classificada no recebimento, gerando o ticket de entrada.',
      RGB(255, 65, 108), RGB(255, 75, 43)),
    Item('Noite estrelada', 'Paisagem',
      'Longe das luzes da cidade, o céu do interior revela a Via Láctea. ' +
      'Noites limpas como essa são comuns no auge da estação seca.',
      RGB(15, 32, 39), RGB(44, 83, 100))
  ];
end;

function TfmCarousel.GerarImagem(const AItem: TItemCarousel; AIndice: Integer): TBitmap;
var
  i, vTam, vX, vY: Integer;
  vSemente: Integer;
begin
  Result := TBitmap.Create;
  Result.PixelFormat := pf24bit;
  Result.SetSize(IMG_LARGURA, IMG_ALTURA);

  GradientFillCanvas(Result.Canvas, AItem.CorInicio, AItem.CorFim,
    Rect(0, 0, IMG_LARGURA, IMG_ALTURA), gdHorizontal);

  // círculos decorativos, sempre iguais para a mesma imagem
  vSemente := RandSeed;
  RandSeed := AIndice * 7919 + 13;
  Result.Canvas.Pen.Style := psClear;
  for i := 1 to 7 do
  begin
    vTam := 40 + Random(150);
    vX := Random(IMG_LARGURA) - vTam div 2;
    vY := Random(IMG_ALTURA) - vTam div 2;
    Result.Canvas.Brush.Style := bsSolid;
    Result.Canvas.Brush.Color := Misturar(Misturar(AItem.CorInicio, AItem.CorFim, Random),
      clWhite, 0.15 + Random * 0.15);
    Result.Canvas.Ellipse(vX, vY, vX + vTam, vY + vTam);
  end;
  RandSeed := vSemente;
  Result.Canvas.Pen.Style := psSolid;

  Result.Canvas.Font.Name := 'Segoe UI';
  Result.Canvas.Font.Quality := fqAntialiased;
  Result.Canvas.Font.Color := clWhite;

  Result.Canvas.Font.Size := 16;
  Result.Canvas.Font.Style := [fsBold];
  TextoComSombra(Result.Canvas, 24, 18, Format('%.2d', [AIndice + 1]));

  Result.Canvas.Font.Size := 11;
  Result.Canvas.Font.Style := [];
  TextoComSombra(Result.Canvas, 24, IMG_ALTURA - 84, UpperCase(AItem.Categoria));

  Result.Canvas.Font.Size := 22;
  Result.Canvas.Font.Style := [fsBold];
  TextoComSombra(Result.Canvas, 24, IMG_ALTURA - 62, AItem.Titulo);
end;

function TfmCarousel.MaxPrimeiro: Integer;
begin
  Result := Max(0, Length(FItens) - VISIVEIS);
end;

function TfmCarousel.IndiceNaPosicao(X, Y: Integer): Integer;
var
  vPos: Integer;
begin
  Result := -1;
  if (Y < CARD_TOP) or (Y > CARD_TOP + CARD_H) then
    Exit;
  vPos := X + Round(FOffset);
  if vPos < 0 then
    Exit;
  if (vPos mod PASSO) >= CARD_W then
    Exit; // espaço entre os cards
  if (vPos div PASSO) <= High(FItens) then
    Result := vPos div PASSO;
end;

function TfmCarousel.IndicadorNaPosicao(X: Integer): Integer;
var
  vInicio, vPos: Integer;
begin
  Result := -1;
  vInicio := (pbIndicadores.Width - (Length(FItens) * DOT + (Length(FItens) - 1) * DOT_ESPACO)) div 2;
  vPos := X - vInicio + DOT_ESPACO div 2; // metade do espaço conta como área de clique
  if vPos < 0 then
    Exit;
  if (vPos div (DOT + DOT_ESPACO)) <= High(FItens) then
    Result := vPos div (DOT + DOT_ESPACO);
end;

procedure TfmCarousel.IrPara(APrimeiro: Integer);
begin
  FPrimeiro := EnsureRange(APrimeiro, 0, MaxPrimeiro);
  FAlvo := FPrimeiro * PASSO;
  tmrAnimacao.Enabled := True;
  lblPosicao.Caption := Format('Exibindo %d a %d de %d',
    [FPrimeiro + 1, Min(FPrimeiro + VISIVEIS, Length(FItens)), Length(FItens)]);
  pbIndicadores.Invalidate;
end;

procedure TfmCarousel.Anterior;
begin
  if FPrimeiro <= 0 then
    IrPara(MaxPrimeiro)
  else
    IrPara(FPrimeiro - 1);
end;

procedure TfmCarousel.Proximo;
begin
  if FPrimeiro >= MaxPrimeiro then
    IrPara(0)
  else
    IrPara(FPrimeiro + 1);
end;

procedure TfmCarousel.SelecionarItem(AIndice: Integer);
var
  vItem: TItemCarousel;
begin
  FSelecionado := AIndice;
  vItem := FItens[AIndice];

  imgDetalhe.Picture.Assign(FImagens[AIndice]);
  lblDetCategoria.Caption := UpperCase(vItem.Categoria);
  lblDetTitulo.Caption := vItem.Titulo;
  lblDetDescricao.Caption := vItem.Descricao;
  lblDetContador.Caption := Format('Imagem %d de %d', [AIndice + 1, Length(FItens)]);

  lblDica.Visible := False;
  imgDetalhe.Visible := True;
  lblDetCategoria.Visible := True;
  lblDetTitulo.Visible := True;
  lblDetDescricao.Visible := True;
  lblDetContador.Visible := True;

  // centraliza o card clicado
  IrPara(AIndice - VISIVEIS div 2);
  pbCarousel.Invalidate;
end;

procedure TfmCarousel.ReiniciarAutoPlay;
begin
  if chkAutoPlay.Checked then
  begin
    tmrAutoPlay.Enabled := False;
    tmrAutoPlay.Enabled := True;
  end;
end;

procedure TfmCarousel.btnAnteriorClick(Sender: TObject);
begin
  Anterior;
  ReiniciarAutoPlay;
end;

procedure TfmCarousel.btnProximoClick(Sender: TObject);
begin
  Proximo;
  ReiniciarAutoPlay;
end;

procedure TfmCarousel.chkAutoPlayClick(Sender: TObject);
begin
  tmrAutoPlay.Enabled := chkAutoPlay.Checked;
end;

procedure TfmCarousel.tmrAnimacaoTimer(Sender: TObject);
begin
  // ease-out: anda 20% do que falta a cada passo
  FOffset := FOffset + (FAlvo - FOffset) * 0.2;
  if Abs(FAlvo - FOffset) < 0.5 then
  begin
    FOffset := FAlvo;
    tmrAnimacao.Enabled := False;
  end;
  pbCarousel.Invalidate;
end;

procedure TfmCarousel.tmrAutoPlayTimer(Sender: TObject);
begin
  if not FMouseDentro then
    Proximo;
end;

procedure TfmCarousel.pbCarouselPaint(Sender: TObject);
var
  i, vX: Integer;
  vCanvas: TCanvas;
  vCard, vImg, vLegenda: TRect;
  vCorBorda: TColor;
begin
  vCanvas := pbCarousel.Canvas;
  vCanvas.Brush.Style := bsSolid;
  vCanvas.Brush.Color := pnlViewport.Color;
  vCanvas.FillRect(pbCarousel.ClientRect);

  SetStretchBltMode(vCanvas.Handle, HALFTONE);
  SetBrushOrgEx(vCanvas.Handle, 0, 0, nil);

  for i := 0 to High(FItens) do
  begin
    vX := i * PASSO - Round(FOffset);
    if (vX + CARD_W + 2 < 0) or (vX > pbCarousel.Width) then
      Continue;

    vCard := Rect(vX, CARD_TOP, vX + CARD_W, CARD_TOP + CARD_H);

    // sombra
    vCanvas.Pen.Style := psClear;
    vCanvas.Brush.Color := COR_SOMBRA;
    vCanvas.RoundRect(vCard.Left + 2, vCard.Top + 3, vCard.Right + 2, vCard.Bottom + 3, 10, 10);

    // card
    if i = FSelecionado then
      vCorBorda := COR_DESTAQUE
    else if i = FHover then
      vCorBorda := COR_HOVER
    else
      vCorBorda := COR_BORDA;
    vCanvas.Pen.Style := psSolid;
    vCanvas.Pen.Color := vCorBorda;
    vCanvas.Pen.Width := IfThen(i = FSelecionado, 3, IfThen(i = FHover, 2, 1));
    vCanvas.Brush.Color := clWhite;
    vCanvas.RoundRect(vCard.Left + 1, vCard.Top + 1, vCard.Right, vCard.Bottom, 10, 10);
    vCanvas.Pen.Width := 1;

    // imagem
    vImg := Rect(vCard.Left + CARD_PAD, vCard.Top + CARD_PAD, vCard.Right - CARD_PAD,
      vCard.Top + CARD_PAD + IMG_H);
    StretchBlt(vCanvas.Handle, vImg.Left, vImg.Top, vImg.Width, vImg.Height,
      FImagens[i].Canvas.Handle, 0, 0, IMG_LARGURA, IMG_ALTURA, SRCCOPY);

    // legenda
    vLegenda := Rect(vCard.Left + 8, vImg.Bottom, vCard.Right - 8, vCard.Bottom - 1);
    vCanvas.Brush.Style := bsClear;
    vCanvas.Font.Name := 'Segoe UI';
    vCanvas.Font.Size := 9;
    vCanvas.Font.Style := [fsBold];
    if i = FSelecionado then
      vCanvas.Font.Color := COR_DESTAQUE
    else
      vCanvas.Font.Color := COR_TEXTO;
    DrawText(vCanvas.Handle, PChar(FItens[i].Titulo), -1, vLegenda,
      DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS or DT_NOPREFIX);
    vCanvas.Brush.Style := bsSolid;
  end;
end;

procedure TfmCarousel.pbCarouselMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  vIndice: Integer;
begin
  FMouseDentro := True;
  vIndice := IndiceNaPosicao(X, Y);
  if vIndice >= 0 then
    pbCarousel.Cursor := crHandPoint
  else
    pbCarousel.Cursor := crDefault;
  if vIndice <> FHover then
  begin
    FHover := vIndice;
    pbCarousel.Invalidate;
  end;
end;

procedure TfmCarousel.pbCarouselMouseLeave(Sender: TObject);
begin
  FMouseDentro := False;
  if FHover <> -1 then
  begin
    FHover := -1;
    pbCarousel.Invalidate;
  end;
end;

procedure TfmCarousel.pbCarouselMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  vIndice: Integer;
begin
  if Button <> mbLeft then
    Exit;
  vIndice := IndiceNaPosicao(X, Y);
  if vIndice >= 0 then
  begin
    SelecionarItem(vIndice);
    ReiniciarAutoPlay;
  end;
end;

procedure TfmCarousel.pbIndicadoresPaint(Sender: TObject);
var
  i, vInicio, vY: Integer;
  vCanvas: TCanvas;
  vR: TRect;
begin
  vCanvas := pbIndicadores.Canvas;
  vInicio := (pbIndicadores.Width - (Length(FItens) * DOT + (Length(FItens) - 1) * DOT_ESPACO)) div 2;
  vY := (pbIndicadores.Height - DOT) div 2;
  for i := 0 to High(FItens) do
  begin
    vR := Rect(vInicio + i * (DOT + DOT_ESPACO), vY, vInicio + i * (DOT + DOT_ESPACO) + DOT, vY + DOT);
    if (i >= FPrimeiro) and (i < FPrimeiro + VISIVEIS) then
      vCanvas.Brush.Color := COR_DESTAQUE
    else
      vCanvas.Brush.Color := COR_INATIVO;
    vCanvas.Pen.Color := vCanvas.Brush.Color;
    vCanvas.Ellipse(vR);

    if i = FSelecionado then
    begin
      // anel em volta do item clicado
      vCanvas.Brush.Style := bsClear;
      vCanvas.Pen.Color := COR_DESTAQUE;
      vCanvas.Ellipse(vR.Left - 3, vR.Top - 3, vR.Right + 3, vR.Bottom + 3);
      vCanvas.Brush.Style := bsSolid;
    end;
  end;
end;

procedure TfmCarousel.pbIndicadoresMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  vIndice: Integer;
begin
  if Button <> mbLeft then
    Exit;
  vIndice := IndicadorNaPosicao(X);
  if vIndice >= 0 then
  begin
    IrPara(vIndice - VISIVEIS div 2);
    ReiniciarAutoPlay;
  end;
end;

end.
