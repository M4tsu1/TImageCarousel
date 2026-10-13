unit UDemoImageCarousel;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Types, System.IOUtils,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.GraphUtil,
  ImageCarousel;

type
  TfmDemoImageCarousel = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    pnlOpcoes: TPanel;
    lblVisiveis: TLabel;
    cbVisiveis: TComboBox;
    lblAjuste: TLabel;
    cbAjuste: TComboBox;
    chkAutoPlay: TCheckBox;
    chkSetas: TCheckBox;
    btnPasta: TButton;
    btnExemplos: TButton;
    pnlCarousel: TPanel;
    pnlDetalhe: TPanel;
    imgDetalhe: TImage;
    lblDetCategoria: TLabel;
    lblDetTitulo: TLabel;
    lblDetDescricao: TLabel;
    lblDetContador: TLabel;
    lblDica: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure cbVisiveisChange(Sender: TObject);
    procedure cbAjusteChange(Sender: TObject);
    procedure chkAutoPlayClick(Sender: TObject);
    procedure chkSetasClick(Sender: TObject);
    procedure btnPastaClick(Sender: TObject);
    procedure btnExemplosClick(Sender: TObject);
  private
    { Private declarations }
    FCarousel: TImageCarousel;
    procedure CarouselItemClick(Sender: TObject; AIndex: Integer; AItem: TCarouselItem);
    procedure CarregarExemplos;
    procedure LimparDetalhe;
  public
    { Public declarations }
  end;

var
  fmDemoImageCarousel: TfmDemoImageCarousel;

implementation

{$R *.dfm}

const
  IMG_LARGURA = 960;
  IMG_ALTURA = 540;

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
  ACanvas.TextOut(X + 3, Y + 3, ATexto);
  ACanvas.Font.Color := vCor;
  ACanvas.TextOut(X, Y, ATexto);
end;

{ Imagem de teste: gradiente, círculos e textos. Em produção, use AddItemFromFile ou AddItemFromStream. }
function GerarImagem(AIndice: Integer; const ATitulo, ACategoria: string; ACorInicio, ACorFim: TColor): TBitmap;
var
  i, vTam, vX, vY, vSemente: Integer;
begin
  Result := TBitmap.Create;
  Result.PixelFormat := pf24bit;
  Result.SetSize(IMG_LARGURA, IMG_ALTURA);
  GradientFillCanvas(Result.Canvas, ACorInicio, ACorFim, Rect(0, 0, IMG_LARGURA, IMG_ALTURA), gdHorizontal);

  vSemente := RandSeed;
  RandSeed := AIndice * 7919 + 13;
  Result.Canvas.Pen.Style := psClear;
  for i := 1 to 8 do
  begin
    vTam := 80 + Random(300);
    vX := Random(IMG_LARGURA) - vTam div 2;
    vY := Random(IMG_ALTURA) - vTam div 2;
    Result.Canvas.Brush.Style := bsSolid;
    Result.Canvas.Brush.Color := Misturar(Misturar(ACorInicio, ACorFim, Random), clWhite, 0.15 + Random * 0.15);
    Result.Canvas.Ellipse(vX, vY, vX + vTam, vY + vTam);
  end;
  RandSeed := vSemente;
  Result.Canvas.Pen.Style := psSolid;

  Result.Canvas.Font.Name := 'Segoe UI';
  Result.Canvas.Font.Quality := fqAntialiased;
  Result.Canvas.Font.Color := clWhite;
  Result.Canvas.Font.Size := 30;
  Result.Canvas.Font.Style := [fsBold];
  TextoComSombra(Result.Canvas, 48, 36, Format('%.2d', [AIndice + 1]));
  Result.Canvas.Font.Size := 20;
  Result.Canvas.Font.Style := [];
  TextoComSombra(Result.Canvas, 48, IMG_ALTURA - 170, UpperCase(ACategoria));
  Result.Canvas.Font.Size := 42;
  Result.Canvas.Font.Style := [fsBold];
  TextoComSombra(Result.Canvas, 48, IMG_ALTURA - 130, ATitulo);
end;

{ TfmDemoImageCarousel }

procedure TfmDemoImageCarousel.FormCreate(Sender: TObject);
begin
  // criado em código para a demo compilar mesmo sem o pacote instalado;
  // com o pacote instalado, é só arrastar o TImageCarousel da paleta "Carousel"
  FCarousel := TImageCarousel.Create(Self);
  FCarousel.Parent := pnlCarousel;
  FCarousel.AlignWithMargins := True;
  FCarousel.Margins.SetBounds(16, 12, 16, 6);
  FCarousel.Align := alClient;
  FCarousel.Color := pnlCarousel.Color;
  FCarousel.AutoPlay := chkAutoPlay.Checked;
  FCarousel.OnItemClick := CarouselItemClick;

  CarregarExemplos;
end;

procedure TfmDemoImageCarousel.CarregarExemplos;

  procedure Adicionar(const ATitulo, ACategoria, ADescricao: string; ACorInicio, ACorFim: TColor);
  var
    vBmp: TBitmap;
  begin
    vBmp := GerarImagem(FCarousel.Items.Count, ATitulo, ACategoria, ACorInicio, ACorFim);
    try
      FCarousel.AddItem(ATitulo, ACategoria, ADescricao, vBmp);
    finally
      vBmp.Free;
    end;
  end;

begin
  FCarousel.Items.BeginUpdate;
  try
    FCarousel.Clear;
    Adicionar('Nascer do sol no campo', 'Paisagem',
      'Os primeiros raios de sol iluminam a lavoura ainda coberta pelo orvalho. ' +
      'É o horário em que o trabalho no campo começa e a temperatura ainda está amena.',
      RGB(255, 153, 51), RGB(255, 94, 98));
    Adicionar('Lavoura de soja', 'Agricultura',
      'Plantas de soja em pleno desenvolvimento vegetativo, com o dossel fechado. ' +
      'Nessa fase o monitoramento de pragas e doenças é decisivo para a produtividade.',
      RGB(86, 171, 47), RGB(168, 224, 99));
    Adicionar('Colheita do milho', 'Agricultura',
      'Colheitadeira trabalhando na safrinha de milho. ' +
      'A umidade do grão é medida antes da colheita para reduzir custos de secagem.',
      RGB(247, 183, 51), RGB(252, 74, 26));
    Adicionar('Armazém de grãos', 'Logística',
      'Silos metálicos que recebem, secam e armazenam a produção. ' +
      'O controle de temperatura e umidade preserva a qualidade do grão por meses.',
      RGB(67, 97, 238), RGB(76, 201, 240));
    Adicionar('Rio e mata ciliar', 'Meio ambiente',
      'A vegetação nas margens protege o rio contra erosão e assoreamento. ' +
      'É área de preservação permanente e serve de corredor para a fauna local.',
      RGB(17, 153, 142), RGB(56, 239, 125));
    Adicionar('Céu de tempestade', 'Clima',
      'Nuvens carregadas se formam no fim da tarde, típicas do início do período chuvoso. ' +
      'A chuva regular marca o momento ideal para o plantio da safra.',
      RGB(44, 62, 80), RGB(76, 161, 175));
    Adicionar('Pôr do sol no cerrado', 'Paisagem',
      'O céu alaranjado sobre a vegetação do cerrado ao fim do dia. ' +
      'A estação seca deixa o ar limpo e as cores do entardecer mais intensas.',
      RGB(238, 9, 121), RGB(255, 106, 0));
    Adicionar('Plantio direto', 'Agricultura',
      'Semeadura feita sobre a palhada da cultura anterior, sem revolver o solo. ' +
      'A técnica conserva umidade, reduz erosão e aumenta a matéria orgânica.',
      RGB(131, 96, 195), RGB(46, 191, 145));
    Adicionar('Transporte da safra', 'Logística',
      'Carretas graneleiras levando a produção da fazenda até o armazém. ' +
      'Cada carga é pesada e classificada no recebimento, gerando o ticket de entrada.',
      RGB(255, 65, 108), RGB(255, 75, 43));
    Adicionar('Noite estrelada', 'Paisagem',
      'Longe das luzes da cidade, o céu do interior revela a Via Láctea. ' +
      'Noites limpas como essa são comuns no auge da estação seca.',
      RGB(15, 32, 39), RGB(44, 83, 100));
  finally
    FCarousel.Items.EndUpdate;
  end;
  LimparDetalhe;
end;

procedure TfmDemoImageCarousel.CarouselItemClick(Sender: TObject; AIndex: Integer; AItem: TCarouselItem);
begin
  imgDetalhe.Picture.Assign(AItem.Picture);
  lblDetCategoria.Caption := UpperCase(AItem.Category);
  lblDetTitulo.Caption := AItem.Title;
  lblDetDescricao.Caption := AItem.Description;
  lblDetContador.Caption := Format('Imagem %d de %d', [AIndex + 1, FCarousel.Items.Count]);

  lblDica.Visible := False;
  imgDetalhe.Visible := True;
  lblDetCategoria.Visible := True;
  lblDetTitulo.Visible := True;
  lblDetDescricao.Visible := True;
  lblDetContador.Visible := True;
end;

procedure TfmDemoImageCarousel.LimparDetalhe;
begin
  lblDica.Visible := True;
  imgDetalhe.Visible := False;
  lblDetCategoria.Visible := False;
  lblDetTitulo.Visible := False;
  lblDetDescricao.Visible := False;
  lblDetContador.Visible := False;
end;

procedure TfmDemoImageCarousel.cbVisiveisChange(Sender: TObject);
begin
  FCarousel.VisibleCount := cbVisiveis.ItemIndex + 1;
end;

procedure TfmDemoImageCarousel.cbAjusteChange(Sender: TObject);
begin
  FCarousel.ImageFit := TCarouselImageFit(cbAjuste.ItemIndex);
end;

procedure TfmDemoImageCarousel.chkAutoPlayClick(Sender: TObject);
begin
  if FCarousel <> nil then
    FCarousel.AutoPlay := chkAutoPlay.Checked;
end;

procedure TfmDemoImageCarousel.chkSetasClick(Sender: TObject);
begin
  if FCarousel <> nil then
    FCarousel.ShowArrows := chkSetas.Checked;
end;

procedure TfmDemoImageCarousel.btnExemplosClick(Sender: TObject);
begin
  CarregarExemplos;
end;

procedure TfmDemoImageCarousel.btnPastaClick(Sender: TObject);
var
  vDialogo: TFileOpenDialog;
  vArquivo, vExt: string;
begin
  vDialogo := TFileOpenDialog.Create(nil);
  try
    vDialogo.Title := 'Escolha uma pasta com imagens';
    vDialogo.Options := vDialogo.Options + [fdoPickFolders];
    if not vDialogo.Execute then
      Exit;

    FCarousel.Items.BeginUpdate;
    try
      FCarousel.Clear;
      for vArquivo in TDirectory.GetFiles(vDialogo.FileName) do
      begin
        vExt := LowerCase(ExtractFileExt(vArquivo));
        if (vExt = '.jpg') or (vExt = '.jpeg') or (vExt = '.png') or (vExt = '.bmp') or (vExt = '.gif') then
          FCarousel.AddItemFromFile(vArquivo, '', ExtractFileName(ExtractFileDir(vArquivo)),
            'Arquivo: ' + vArquivo);
      end;
    finally
      FCarousel.Items.EndUpdate;
    end;
    LimparDetalhe;
    if FCarousel.Items.Count = 0 then
      ShowMessage('Nenhuma imagem JPG, PNG, BMP ou GIF encontrada nessa pasta.');
  finally
    vDialogo.Free;
  end;
end;

end.
