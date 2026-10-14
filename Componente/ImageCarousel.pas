unit ImageCarousel;

{ TImageCarousel - carrossel de imagens clicáveis para VCL.

  Desenhado inteiro no Canvas (sem um componente por imagem), com:
  - itens editáveis em design time (Items: título, categoria, descrição, imagem PNG/JPG/BMP/GIF);
  - navegação por setas, indicadores, roda do mouse, teclado e arrastar com o mouse;
  - animação suave, avanço automático e evento OnItemClick. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Types, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.ExtCtrls, Vcl.Forms,
  Vcl.Imaging.pngimage, Vcl.Imaging.jpeg, Vcl.Imaging.GIFImg;

type
  TImageCarousel = class;

  TCarouselImageFit = (
    cifFill,     // preenche o card e corta o excesso (padrão)
    cifFit,      // mostra a imagem inteira, com faixas de ImageBackground
    cifStretch); // estica para o tamanho do card

  TCarouselHit = (chNone, chCard, chPrev, chNext, chDot);

  TCarouselItem = class(TCollectionItem)
  private
    FTitle: string;
    FCategory: string;
    FDescription: string;
    FPicture: TPicture;
    FTag: NativeInt;
    FData: TObject;
    FCache: TBitmap; // imagem já redimensionada para o tamanho atual do card
    FRendering: Integer; // > 0 enquanto o cache é montado
    procedure SetTitle(const Value: string);
    procedure SetCategory(const Value: string);
    procedure SetDescription(const Value: string);
    procedure SetPicture(const Value: TPicture);
    procedure PictureChanged(Sender: TObject);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure InvalidateCache;
    { Livre para o programador: ID do registro, objeto associado etc. Não é liberado pelo componente. }
    property Data: TObject read FData write FData;
  published
    property Title: string read FTitle write SetTitle;
    property Category: string read FCategory write SetCategory;
    property Description: string read FDescription write SetDescription;
    property Picture: TPicture read FPicture write SetPicture;
    property Tag: NativeInt read FTag write FTag default 0;
  end;

  TCarouselItems = class(TOwnedCollection)
  private
    function GetItem(Index: Integer): TCarouselItem;
    procedure SetItem(Index: Integer; const Value: TCarouselItem);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TImageCarousel);
    function Add: TCarouselItem;
    property Items[Index: Integer]: TCarouselItem read GetItem write SetItem; default;
  end;

  TCarouselItemEvent = procedure(Sender: TObject; AIndex: Integer; AItem: TCarouselItem) of object;

  TImageCarousel = class(TCustomControl)
  private
    FItems: TCarouselItems;
    FItemIndex: Integer;
    FFirstVisible: Integer;
    FVisibleCount: Integer;
    FSpacing: Integer;
    FCardRadius: Integer;
    FCaptionHeight: Integer;
    FShowCaptions: Boolean;
    FShowIndicators: Boolean;
    FShowArrows: Boolean;
    FImageFit: TCarouselImageFit;
    FAccentColor: TColor;
    FHoverColor: TColor;
    FBorderColor: TColor;
    FShadowColor: TColor;
    FCardColor: TColor;
    FArrowColor: TColor;
    FIndicatorColor: TColor;
    FImageBackground: TColor;
    FWrap: Boolean;
    FCenterOnClick: Boolean;
    FPauseOnHover: Boolean;
    FAutoPlay: Boolean;
    FAnimTimer: TTimer;
    FAutoTimer: TTimer;
    FBuffer: TBitmap;
    FOffset: Double;
    FTarget: Double;
    FHoverHit: TCarouselHit;
    FHoverIndex: Integer;
    FMouseInside: Boolean;
    FMouseDown: Boolean;
    FDragging: Boolean;
    FDragStartX: Integer;
    FDragStartOffset: Double;
    FOnItemClick: TCarouselItemEvent;
    FOnChange: TNotifyEvent;
    FOnScroll: TNotifyEvent;
    procedure SetItems(const Value: TCarouselItems);
    procedure SetItemIndex(Value: Integer);
    procedure SetFirstVisible(Value: Integer);
    procedure SetVisibleCount(Value: Integer);
    procedure SetSpacing(Value: Integer);
    procedure SetCardRadius(Value: Integer);
    procedure SetCaptionHeight(Value: Integer);
    procedure SetShowCaptions(Value: Boolean);
    procedure SetShowIndicators(Value: Boolean);
    procedure SetShowArrows(Value: Boolean);
    procedure SetImageFit(Value: TCarouselImageFit);
    procedure SetImageBackground(Value: TColor);
    function GetColorProp(Index: Integer): TColor;
    procedure SetColorProp(Index: Integer; Value: TColor);
    procedure SetWrap(Value: Boolean);
    procedure SetAutoPlay(Value: Boolean);
    function GetAutoPlayInterval: Cardinal;
    procedure SetAutoPlayInterval(Value: Cardinal);
    function GetSelectedItem: TCarouselItem;
    procedure AnimTimerTick(Sender: TObject);
    procedure AutoTimerTick(Sender: TObject);
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  protected
    { layout }
    function DisplayCount: Integer;
    function ArrowAreaWidth: Integer;
    function IndicatorAreaHeight: Integer;
    function ViewRect: TRect;
    function IndicatorRect: TRect;
    function CardWidth: Integer;
    function StepSize: Integer;
    function MaxFirstVisible: Integer;
    function CardRect(AIndex: Integer): TRect;
    function ImageRect(const ACard: TRect): TRect;
    function CanGoPrevious: Boolean;
    function CanGoNext: Boolean;
    { desenho }
    function GetCache(AItem: TCarouselItem; AWidth, AHeight: Integer): TBitmap;
    procedure RenderImage(AItem: TCarouselItem; ADest: TBitmap);
    procedure PaintCard(C: TCanvas; AIndex: Integer; const ACard: TRect; AViewRgn: HRGN);
    procedure PaintPlaceholder(C: TCanvas; const R: TRect);
    procedure PaintArrow(C: TCanvas; ALeft: Boolean);
    procedure PaintIndicators(C: TCanvas);
    procedure Paint; override;
    { estado }
    procedure ItemsChanged;
    procedure LayoutChanged;
    procedure InvalidateCaches;
    procedure UpdateAutoPlayTimer;
    procedure RestartAutoPlay;
    procedure SelectItem(AIndex: Integer; AByUser: Boolean);
    procedure DoChange; virtual;
    procedure DoItemClick(AIndex: Integer); virtual;
    procedure DoScroll; virtual;
    { entrada }
    procedure Loaded; override;
    procedure Resize; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function AddItem(const ATitle: string; const ACategory: string = '';
      const ADescription: string = ''; AGraphic: TGraphic = nil): TCarouselItem;
    function AddItemFromFile(const AFileName: string; const ATitle: string = '';
      const ACategory: string = ''; const ADescription: string = ''): TCarouselItem;
    { Aceita PNG, JPG, BMP, GIF e TIFF - útil para campos blob: Query.CreateBlobStream(Campo, bmRead) }
    function AddItemFromStream(AStream: TStream; const ATitle: string;
      const ACategory: string = ''; const ADescription: string = ''): TCarouselItem;
    procedure Clear;

    procedure Next;
    procedure Previous;
    { Rola até deixar o item visível, centralizado quando possível }
    procedure ScrollTo(AIndex: Integer);
    function HitTest(X, Y: Integer; out AIndex: Integer): TCarouselHit;
    function ItemAtPos(X, Y: Integer): Integer;

    property FirstVisible: Integer read FFirstVisible write SetFirstVisible;
    property SelectedItem: TCarouselItem read GetSelectedItem;
  published
    property Align;
    property Anchors;
    property Color default $00F7F5F3;
    property Constraints;
    property Enabled;
    property Font;
    property Hint;
    property ParentColor default False;
    property ParentFont default False;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;

    property Items: TCarouselItems read FItems write SetItems;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default -1;
    property VisibleCount: Integer read FVisibleCount write SetVisibleCount default 3;
    property Spacing: Integer read FSpacing write SetSpacing default 16;
    property CardRadius: Integer read FCardRadius write SetCardRadius default 6;
    property CaptionHeight: Integer read FCaptionHeight write SetCaptionHeight default 26;
    property ShowCaptions: Boolean read FShowCaptions write SetShowCaptions default True;
    property ShowIndicators: Boolean read FShowIndicators write SetShowIndicators default True;
    property ShowArrows: Boolean read FShowArrows write SetShowArrows default True;
    property ImageFit: TCarouselImageFit read FImageFit write SetImageFit default cifFill;
    property AccentColor: TColor index 0 read GetColorProp write SetColorProp default $00CB6B0B;
    property HoverColor: TColor index 1 read GetColorProp write SetColorProp default $00EBC69A;
    property BorderColor: TColor index 2 read GetColorProp write SetColorProp default $00E1DDD9;
    property ShadowColor: TColor index 3 read GetColorProp write SetColorProp default $00E6E2DE;
    property CardColor: TColor index 4 read GetColorProp write SetColorProp default clWhite;
    property ArrowColor: TColor index 5 read GetColorProp write SetColorProp default $00332B26;
    property IndicatorColor: TColor index 6 read GetColorProp write SetColorProp default $00D2CDC8;
    property ImageBackground: TColor read FImageBackground write SetImageBackground default $00EFEBE8;
    property Wrap: Boolean read FWrap write SetWrap default True;
    property CenterOnClick: Boolean read FCenterOnClick write FCenterOnClick default True;
    property PauseOnHover: Boolean read FPauseOnHover write FPauseOnHover default True;
    property AutoPlay: Boolean read FAutoPlay write SetAutoPlay default False;
    property AutoPlayInterval: Cardinal read GetAutoPlayInterval write SetAutoPlayInterval default 3500;

    property OnItemClick: TCarouselItemEvent read FOnItemClick write FOnItemClick;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnScroll: TNotifyEvent read FOnScroll write FOnScroll;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;

implementation

const
  CARD_PAD = 4;
  CARD_TOP = 2;
  SHADOW = 3;
  ARROW_AREA = 40;
  INDICATOR_AREA = 24;
  DOT = 8;
  DOT_GAP = 8;
  DRAG_THRESHOLD = 6;

{ TCarouselItem }

constructor TCarouselItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FPicture := TPicture.Create;
  FPicture.OnChange := PictureChanged;
end;

destructor TCarouselItem.Destroy;
begin
  FPicture.Free;
  FCache.Free;
  inherited Destroy;
end;

procedure TCarouselItem.Assign(Source: TPersistent);
begin
  if Source is TCarouselItem then
  begin
    FTitle := TCarouselItem(Source).Title;
    FCategory := TCarouselItem(Source).Category;
    FDescription := TCarouselItem(Source).Description;
    FTag := TCarouselItem(Source).Tag;
    FData := TCarouselItem(Source).Data;
    FPicture.Assign(TCarouselItem(Source).Picture);
    Changed(False);
  end
  else
    inherited Assign(Source);
end;

function TCarouselItem.GetDisplayName: string;
begin
  if FTitle <> '' then
    Result := FTitle
  else
    Result := inherited GetDisplayName;
end;

procedure TCarouselItem.InvalidateCache;
begin
  FreeAndNil(FCache);
end;

procedure TCarouselItem.PictureChanged(Sender: TObject);
begin
  // JPEG e outros formatos avisam "mudei" ao decodificar no primeiro desenho;
  // esse aviso vem da montagem do cache e não é troca de imagem
  if FRendering > 0 then
    Exit;
  InvalidateCache;
  Changed(False);
end;

procedure TCarouselItem.SetCategory(const Value: string);
begin
  if FCategory <> Value then
  begin
    FCategory := Value;
    Changed(False);
  end;
end;

procedure TCarouselItem.SetDescription(const Value: string);
begin
  if FDescription <> Value then
  begin
    FDescription := Value;
    Changed(False);
  end;
end;

procedure TCarouselItem.SetPicture(const Value: TPicture);
begin
  FPicture.Assign(Value);
end;

procedure TCarouselItem.SetTitle(const Value: string);
begin
  if FTitle <> Value then
  begin
    FTitle := Value;
    Changed(False);
  end;
end;

{ TCarouselItems }

constructor TCarouselItems.Create(AOwner: TImageCarousel);
begin
  inherited Create(AOwner, TCarouselItem);
end;

function TCarouselItems.Add: TCarouselItem;
begin
  Result := TCarouselItem(inherited Add);
end;

function TCarouselItems.GetItem(Index: Integer): TCarouselItem;
begin
  Result := TCarouselItem(inherited GetItem(Index));
end;

procedure TCarouselItems.SetItem(Index: Integer; const Value: TCarouselItem);
begin
  inherited SetItem(Index, Value);
end;

procedure TCarouselItems.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if GetOwner is TImageCarousel then
    TImageCarousel(GetOwner).ItemsChanged;
end;

{ TImageCarousel }

constructor TImageCarousel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csCaptureMouse, csClickEvents] - [csAcceptsControls, csSetCaption];
  TabStop := True;

  FItems := TCarouselItems.Create(Self);
  FItemIndex := -1;
  FVisibleCount := 3;
  FSpacing := 16;
  FCardRadius := 6;
  FCaptionHeight := 26;
  FShowCaptions := True;
  FShowIndicators := True;
  FShowArrows := True;
  FImageFit := cifFill;
  FAccentColor := $00CB6B0B;
  FHoverColor := $00EBC69A;
  FBorderColor := $00E1DDD9;
  FShadowColor := $00E6E2DE;
  FCardColor := clWhite;
  FArrowColor := $00332B26;
  FIndicatorColor := $00D2CDC8;
  FImageBackground := $00EFEBE8;
  FWrap := True;
  FCenterOnClick := True;
  FPauseOnHover := True;
  FHoverHit := chNone;
  FHoverIndex := -1;

  Color := $00F7F5F3;
  ParentColor := False;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  Font.Style := [fsBold];
  Font.Color := $00332B26;
  ParentFont := False;

  FAnimTimer := TTimer.Create(Self);
  FAnimTimer.Enabled := False;
  FAnimTimer.Interval := 15;
  FAnimTimer.OnTimer := AnimTimerTick;

  FAutoTimer := TTimer.Create(Self);
  FAutoTimer.Enabled := False;
  FAutoTimer.Interval := 3500;
  FAutoTimer.OnTimer := AutoTimerTick;

  // por último: mudar o tamanho dispara Resize, que já usa os itens e os timers
  Width := 600;
  Height := 220;
end;

destructor TImageCarousel.Destroy;
begin
  FAnimTimer.Enabled := False;
  FAutoTimer.Enabled := False;
  FreeAndNil(FItems);
  FreeAndNil(FBuffer);
  inherited Destroy;
end;

procedure TImageCarousel.Loaded;
begin
  inherited Loaded;
  ItemsChanged;
  if FItemIndex >= 0 then
    SetFirstVisible(FItemIndex - FVisibleCount div 2);
  FOffset := FTarget;
  UpdateAutoPlayTimer;
end;

{ ---------------------------------------------------------------- layout }

function TImageCarousel.DisplayCount: Integer;
begin
  // no designer, sem itens, mostra cards de exemplo para dar noção do visual
  if (FItems.Count = 0) and (csDesigning in ComponentState) then
    Result := FVisibleCount
  else
    Result := FItems.Count;
end;

function TImageCarousel.ArrowAreaWidth: Integer;
begin
  if FShowArrows then
    Result := ARROW_AREA
  else
    Result := 0;
end;

function TImageCarousel.IndicatorAreaHeight: Integer;
begin
  if FShowIndicators then
    Result := INDICATOR_AREA
  else
    Result := 0;
end;

function TImageCarousel.ViewRect: TRect;
begin
  Result := Rect(ArrowAreaWidth, 0, ClientWidth - ArrowAreaWidth, ClientHeight - IndicatorAreaHeight);
end;

function TImageCarousel.IndicatorRect: TRect;
var
  VR: TRect;
begin
  VR := ViewRect;
  Result := Rect(VR.Left, VR.Bottom, VR.Right, ClientHeight);
end;

function TImageCarousel.CardWidth: Integer;
begin
  Result := Max(20, (ViewRect.Width - (FVisibleCount - 1) * FSpacing - SHADOW) div FVisibleCount);
end;

function TImageCarousel.StepSize: Integer;
begin
  Result := CardWidth + FSpacing;
end;

function TImageCarousel.MaxFirstVisible: Integer;
begin
  Result := Max(0, DisplayCount - FVisibleCount);
end;

function TImageCarousel.CardRect(AIndex: Integer): TRect;
var
  VR: TRect;
  L: Integer;
begin
  VR := ViewRect;
  L := VR.Left + AIndex * StepSize - Round(FOffset);
  Result := Rect(L, VR.Top + CARD_TOP, L + CardWidth, VR.Bottom - SHADOW - 2);
end;

function TImageCarousel.ImageRect(const ACard: TRect): TRect;
var
  Bottom: Integer;
begin
  if FShowCaptions then
    Bottom := ACard.Bottom - FCaptionHeight
  else
    Bottom := ACard.Bottom - CARD_PAD;
  Result := Rect(ACard.Left + CARD_PAD, ACard.Top + CARD_PAD, ACard.Right - CARD_PAD,
    Max(ACard.Top + CARD_PAD, Bottom));
end;

function TImageCarousel.CanGoPrevious: Boolean;
begin
  Result := (DisplayCount > FVisibleCount) and (FWrap or (FFirstVisible > 0));
end;

function TImageCarousel.CanGoNext: Boolean;
begin
  Result := (DisplayCount > FVisibleCount) and (FWrap or (FFirstVisible < MaxFirstVisible));
end;

{ ---------------------------------------------------------------- desenho }

function TImageCarousel.GetCache(AItem: TCarouselItem; AWidth, AHeight: Integer): TBitmap;
var
  Bmp: TBitmap;
begin
  if (AItem.FCache = nil) or (AItem.FCache.Width <> AWidth) or (AItem.FCache.Height <> AHeight) then
  begin
    FreeAndNil(AItem.FCache);
    // monta num bitmap local e só guarda no item quando estiver pronto
    Bmp := TBitmap.Create;
    try
      Bmp.PixelFormat := pf24bit;
      Bmp.SetSize(AWidth, AHeight);
      Inc(AItem.FRendering);
      try
        RenderImage(AItem, Bmp);
      finally
        Dec(AItem.FRendering);
      end;
    except
      Bmp.Free;
      raise;
    end;
    FreeAndNil(AItem.FCache);
    AItem.FCache := Bmp;
  end;
  Result := AItem.FCache;
end;

procedure TImageCarousel.RenderImage(AItem: TCarouselItem; ADest: TBitmap);
var
  G: TGraphic;
  Src: TBitmap;
  SR, DR: TRect;
  Scale: Double;
  W, H: Integer;
begin
  ADest.Canvas.Brush.Style := bsSolid;
  ADest.Canvas.Brush.Color := FImageBackground;
  ADest.Canvas.FillRect(Rect(0, 0, ADest.Width, ADest.Height));

  G := AItem.Picture.Graphic;
  if (G = nil) or G.Empty or (G.Width = 0) or (G.Height = 0) then
    Exit;

  // a imagem original vira bitmap uma única vez; daí sai a versão reduzida com HALFTONE
  Src := TBitmap.Create;
  try
    Src.PixelFormat := pf24bit;
    Src.SetSize(G.Width, G.Height);
    Src.Canvas.Brush.Color := FImageBackground;
    Src.Canvas.FillRect(Rect(0, 0, G.Width, G.Height));
    Src.Canvas.Draw(0, 0, G);

    SR := Rect(0, 0, G.Width, G.Height);
    DR := Rect(0, 0, ADest.Width, ADest.Height);
    case FImageFit of
      cifFill:
        begin
          Scale := Max(ADest.Width / G.Width, ADest.Height / G.Height);
          W := Min(G.Width, Round(ADest.Width / Scale));
          H := Min(G.Height, Round(ADest.Height / Scale));
          SR := Rect((G.Width - W) div 2, (G.Height - H) div 2, (G.Width - W) div 2 + W, (G.Height - H) div 2 + H);
        end;
      cifFit:
        begin
          Scale := Min(ADest.Width / G.Width, ADest.Height / G.Height);
          W := Max(1, Round(G.Width * Scale));
          H := Max(1, Round(G.Height * Scale));
          DR := Rect((ADest.Width - W) div 2, (ADest.Height - H) div 2, (ADest.Width - W) div 2 + W, (ADest.Height - H) div 2 + H);
        end;
    end;

    SetStretchBltMode(ADest.Canvas.Handle, HALFTONE);
    SetBrushOrgEx(ADest.Canvas.Handle, 0, 0, nil);
    StretchBlt(ADest.Canvas.Handle, DR.Left, DR.Top, DR.Width, DR.Height,
      Src.Canvas.Handle, SR.Left, SR.Top, SR.Width, SR.Height, SRCCOPY);
  finally
    Src.Free;
  end;
end;

procedure TImageCarousel.PaintPlaceholder(C: TCanvas; const R: TRect);
var
  CX, CY, S: Integer;
begin
  C.Brush.Style := bsSolid;
  C.Brush.Color := FImageBackground;
  C.FillRect(R);
  // ícone simples de "imagem": moldura, sol e montanha
  CX := (R.Left + R.Right) div 2;
  CY := (R.Top + R.Bottom) div 2;
  S := Max(8, Min(R.Width, R.Height) div 6);
  C.Pen.Style := psSolid;
  C.Pen.Width := 2;
  C.Pen.Color := FIndicatorColor;
  C.Brush.Style := bsClear;
  C.RoundRect(CX - S * 3 div 2, CY - S, CX + S * 3 div 2, CY + S, 6, 6);
  C.Brush.Style := bsSolid;
  C.Brush.Color := FIndicatorColor;
  C.Ellipse(CX + S div 3, CY - S * 2 div 3, CX + S, CY);
  C.Polygon([Point(CX - S * 3 div 2 + 3, CY + S - 2), Point(CX - S div 3, CY - S div 4),
    Point(CX + S div 2, CY + S - 2)]);
  C.Pen.Width := 1;
end;

procedure TImageCarousel.PaintCard(C: TCanvas; AIndex: Integer; const ACard: TRect; AViewRgn: HRGN);
var
  Item: TCarouselItem;
  IR, LR: TRect;
  Rgn: HRGN;
  R: Integer;
  S: string;
begin
  if AIndex < FItems.Count then
    Item := FItems[AIndex]
  else
    Item := nil;
  R := FCardRadius * 2;

  // sombra
  C.Pen.Style := psClear;
  C.Brush.Style := bsSolid;
  C.Brush.Color := FShadowColor;
  C.RoundRect(ACard.Left + 2, ACard.Top + SHADOW, ACard.Right + 2, ACard.Bottom + SHADOW, R, R);

  // card e borda conforme o estado
  C.Pen.Style := psSolid;
  if AIndex = FItemIndex then
  begin
    C.Pen.Color := FAccentColor;
    C.Pen.Width := 3;
  end
  else if (FHoverHit = chCard) and (AIndex = FHoverIndex) then
  begin
    C.Pen.Color := FHoverColor;
    C.Pen.Width := 2;
  end
  else
  begin
    C.Pen.Color := FBorderColor;
    C.Pen.Width := 1;
  end;
  C.Brush.Color := FCardColor;
  C.RoundRect(ACard.Left + 1, ACard.Top + 1, ACard.Right, ACard.Bottom, R, R);
  C.Pen.Width := 1;

  // imagem, recortada com cantos arredondados
  IR := ImageRect(ACard);
  if (IR.Width > 0) and (IR.Height > 0) then
  begin
    Rgn := CreateRoundRectRgn(IR.Left, IR.Top, IR.Right + 1, IR.Bottom + 1, Max(0, R - 4), Max(0, R - 4));
    try
      CombineRgn(Rgn, Rgn, AViewRgn, RGN_AND);
      SelectClipRgn(C.Handle, Rgn);
      if (Item <> nil) and (Item.Picture.Graphic <> nil) and not Item.Picture.Graphic.Empty then
        BitBlt(C.Handle, IR.Left, IR.Top, IR.Width, IR.Height,
          GetCache(Item, IR.Width, IR.Height).Canvas.Handle, 0, 0, SRCCOPY)
      else
        PaintPlaceholder(C, IR);
      SelectClipRgn(C.Handle, AViewRgn);
    finally
      DeleteObject(Rgn);
    end;
  end;

  // legenda
  if FShowCaptions then
  begin
    LR := Rect(ACard.Left + 8, IR.Bottom, ACard.Right - 8, ACard.Bottom - 1);
    if Item <> nil then
      S := Item.Title
    else
      S := Format('Item %d', [AIndex + 1]);
    C.Font.Assign(Font);
    if AIndex = FItemIndex then
      C.Font.Color := FAccentColor;
    C.Brush.Style := bsClear;
    DrawText(C.Handle, PChar(S), Length(S), LR,
      DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS or DT_NOPREFIX);
    C.Brush.Style := bsSolid;
  end;
end;

procedure TImageCarousel.PaintArrow(C: TCanvas; ALeft: Boolean);
var
  VR, AR: TRect;
  CX, CY, S: Integer;
  CanGo, Hover: Boolean;
begin
  VR := ViewRect;
  if ALeft then
  begin
    AR := Rect(0, VR.Top, ArrowAreaWidth, VR.Bottom);
    CanGo := CanGoPrevious;
    Hover := FHoverHit = chPrev;
  end
  else
  begin
    AR := Rect(ClientWidth - ArrowAreaWidth, VR.Top, ClientWidth, VR.Bottom);
    CanGo := CanGoNext;
    Hover := FHoverHit = chNext;
  end;
  CX := (AR.Left + AR.Right) div 2;
  CY := (AR.Top + AR.Bottom) div 2;
  S := 8;

  if CanGo and Hover then
  begin
    C.Pen.Style := psClear;
    C.Brush.Style := bsSolid;
    C.Brush.Color := FShadowColor;
    C.Ellipse(CX - 16, CY - 16, CX + 17, CY + 17);
  end;

  C.Pen.Style := psSolid;
  C.Pen.Width := 3;
  if not CanGo then
    C.Pen.Color := FBorderColor
  else if Hover then
    C.Pen.Color := FAccentColor
  else
    C.Pen.Color := FArrowColor;
  if ALeft then
    C.Polyline([Point(CX + S div 2, CY - S), Point(CX - S div 2, CY), Point(CX + S div 2, CY + S)])
  else
    C.Polyline([Point(CX - S div 2, CY - S), Point(CX + S div 2, CY), Point(CX - S div 2, CY + S)]);
  C.Pen.Width := 1;
end;

procedure TImageCarousel.PaintIndicators(C: TCanvas);
var
  IRc, R: TRect;
  i, N, Total, X0, Y: Integer;
begin
  N := DisplayCount;
  if N = 0 then
    Exit;
  IRc := IndicatorRect;
  Total := N * DOT + (N - 1) * DOT_GAP;
  if Total > IRc.Width then
    Exit; // itens demais para caber os indicadores
  X0 := IRc.Left + (IRc.Width - Total) div 2;
  Y := (IRc.Top + IRc.Bottom - DOT) div 2;
  for i := 0 to N - 1 do
  begin
    R := Rect(X0 + i * (DOT + DOT_GAP), Y, X0 + i * (DOT + DOT_GAP) + DOT, Y + DOT);
    C.Pen.Style := psClear;
    C.Brush.Style := bsSolid;
    if (i >= FFirstVisible) and (i < FFirstVisible + FVisibleCount) then
      C.Brush.Color := FAccentColor
    else if (FHoverHit = chDot) and (FHoverIndex = i) then
      C.Brush.Color := FHoverColor
    else
      C.Brush.Color := FIndicatorColor;
    C.Ellipse(R.Left, R.Top, R.Right + 1, R.Bottom + 1);

    if i = FItemIndex then
    begin
      C.Pen.Style := psSolid;
      C.Pen.Color := FAccentColor;
      C.Brush.Style := bsClear;
      C.Ellipse(R.Left - 3, R.Top - 3, R.Right + 3, R.Bottom + 3);
      C.Brush.Style := bsSolid;
    end;
  end;
end;

procedure TImageCarousel.Paint;
var
  C: TCanvas;
  VR, CR: TRect;
  ViewRgn: HRGN;
  i: Integer;
begin
  // tudo é desenhado num buffer e copiado de uma vez: sem flicker
  if FBuffer = nil then
  begin
    FBuffer := TBitmap.Create;
    FBuffer.PixelFormat := pf24bit;
  end;
  if (FBuffer.Width <> ClientWidth) or (FBuffer.Height <> ClientHeight) then
    FBuffer.SetSize(ClientWidth, ClientHeight);
  C := FBuffer.Canvas;

  C.Brush.Style := bsSolid;
  C.Brush.Color := Color;
  C.FillRect(Rect(0, 0, ClientWidth, ClientHeight));

  VR := ViewRect;
  ViewRgn := CreateRectRgn(VR.Left, VR.Top, VR.Right, VR.Bottom);
  try
    SelectClipRgn(C.Handle, ViewRgn);
    for i := 0 to DisplayCount - 1 do
    begin
      CR := CardRect(i);
      if (CR.Right + SHADOW < VR.Left) or (CR.Left > VR.Right) then
        Continue;
      PaintCard(C, i, CR, ViewRgn);
    end;
    SelectClipRgn(C.Handle, 0);
  finally
    DeleteObject(ViewRgn);
  end;

  if FShowArrows then
  begin
    PaintArrow(C, True);
    PaintArrow(C, False);
  end;
  if FShowIndicators then
    PaintIndicators(C);

  Canvas.Draw(0, 0, FBuffer);
end;

procedure TImageCarousel.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

{ ---------------------------------------------------------------- estado }

procedure TImageCarousel.ItemsChanged;
begin
  if (csDestroying in ComponentState) or (FItems = nil) then
    Exit;
  if FItemIndex >= FItems.Count then
    FItemIndex := -1;
  if not (csLoading in ComponentState) then
  begin
    FFirstVisible := EnsureRange(FFirstVisible, 0, MaxFirstVisible);
    FTarget := FFirstVisible * StepSize;
    if not FAnimTimer.Enabled then
      FOffset := FTarget;
    UpdateAutoPlayTimer;
  end;
  Invalidate;
end;

procedure TImageCarousel.LayoutChanged;
begin
  if (FItems = nil) or (FAutoTimer = nil) then
    Exit;
  FFirstVisible := EnsureRange(FFirstVisible, 0, MaxFirstVisible);
  FTarget := FFirstVisible * StepSize;
  FOffset := FTarget;
  UpdateAutoPlayTimer;
  Invalidate;
end;

procedure TImageCarousel.InvalidateCaches;
var
  i: Integer;
begin
  for i := 0 to FItems.Count - 1 do
    FItems[i].InvalidateCache;
  Invalidate;
end;

procedure TImageCarousel.Resize;
begin
  inherited Resize;
  LayoutChanged; // os caches se refazem sozinhos no novo tamanho
end;

procedure TImageCarousel.UpdateAutoPlayTimer;
begin
  FAutoTimer.Enabled := FAutoPlay and not (csDesigning in ComponentState) and
    not (csLoading in ComponentState) and (FItems.Count > FVisibleCount);
end;

procedure TImageCarousel.RestartAutoPlay;
begin
  if FAutoTimer.Enabled then
  begin
    FAutoTimer.Enabled := False;
    FAutoTimer.Enabled := True;
  end;
end;

procedure TImageCarousel.AnimTimerTick(Sender: TObject);
begin
  // ease-out: anda 20% do que falta a cada passo
  FOffset := FOffset + (FTarget - FOffset) * 0.2;
  if Abs(FTarget - FOffset) < 0.5 then
  begin
    FOffset := FTarget;
    FAnimTimer.Enabled := False;
  end;
  Invalidate;
end;

procedure TImageCarousel.AutoTimerTick(Sender: TObject);
begin
  if FDragging or (FPauseOnHover and FMouseInside) then
    Exit;
  Next;
end;

procedure TImageCarousel.SetFirstVisible(Value: Integer);
begin
  Value := EnsureRange(Value, 0, MaxFirstVisible);
  FTarget := Value * StepSize;
  if (csDesigning in ComponentState) or (csLoading in ComponentState) then
  begin
    FOffset := FTarget;
    Invalidate;
  end
  else if Abs(FTarget - FOffset) >= 0.5 then
    FAnimTimer.Enabled := True;
  if Value <> FFirstVisible then
  begin
    FFirstVisible := Value;
    Invalidate;
    DoScroll;
  end;
end;

procedure TImageCarousel.SelectItem(AIndex: Integer; AByUser: Boolean);
begin
  if (AIndex < 0) or (AIndex >= FItems.Count) then
    Exit;
  if AIndex <> FItemIndex then
  begin
    FItemIndex := AIndex;
    Invalidate;
    DoChange;
  end;
  if FCenterOnClick or (AIndex < FFirstVisible) or (AIndex >= FFirstVisible + FVisibleCount) then
    ScrollTo(AIndex);
  if AByUser then
    DoItemClick(AIndex);
end;

procedure TImageCarousel.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TImageCarousel.DoItemClick(AIndex: Integer);
begin
  if Assigned(FOnItemClick) then
    FOnItemClick(Self, AIndex, FItems[AIndex]);
end;

procedure TImageCarousel.DoScroll;
begin
  if Assigned(FOnScroll) then
    FOnScroll(Self);
end;

{ ---------------------------------------------------------------- API pública }

function TImageCarousel.AddItem(const ATitle, ACategory, ADescription: string; AGraphic: TGraphic): TCarouselItem;
begin
  FItems.BeginUpdate;
  try
    Result := FItems.Add;
    Result.FTitle := ATitle;
    Result.FCategory := ACategory;
    Result.FDescription := ADescription;
    if AGraphic <> nil then
      Result.Picture.Assign(AGraphic);
  finally
    FItems.EndUpdate;
  end;
end;

function TImageCarousel.AddItemFromFile(const AFileName, ATitle, ACategory, ADescription: string): TCarouselItem;
var
  Title: string;
begin
  Title := ATitle;
  if Title = '' then
    Title := ChangeFileExt(ExtractFileName(AFileName), '');
  FItems.BeginUpdate;
  try
    Result := AddItem(Title, ACategory, ADescription);
    Result.Picture.LoadFromFile(AFileName);
  finally
    FItems.EndUpdate;
  end;
end;

function TImageCarousel.AddItemFromStream(AStream: TStream; const ATitle, ACategory,
  ADescription: string): TCarouselItem;
var
  Img: TWICImage;
begin
  Img := TWICImage.Create;
  try
    Img.LoadFromStream(AStream);
    Result := AddItem(ATitle, ACategory, ADescription, Img);
  finally
    Img.Free;
  end;
end;

procedure TImageCarousel.Clear;
begin
  FItems.Clear;
  FItemIndex := -1;
  FFirstVisible := 0;
  FOffset := 0;
  FTarget := 0;
  Invalidate;
end;

procedure TImageCarousel.Next;
begin
  if FFirstVisible < MaxFirstVisible then
    SetFirstVisible(FFirstVisible + 1)
  else if FWrap then
    SetFirstVisible(0);
end;

procedure TImageCarousel.Previous;
begin
  if FFirstVisible > 0 then
    SetFirstVisible(FFirstVisible - 1)
  else if FWrap then
    SetFirstVisible(MaxFirstVisible);
end;

procedure TImageCarousel.ScrollTo(AIndex: Integer);
begin
  SetFirstVisible(AIndex - FVisibleCount div 2);
end;

function TImageCarousel.HitTest(X, Y: Integer; out AIndex: Integer): TCarouselHit;
var
  VR, IRc, CR: TRect;
  N, Step, Pos, Total, X0: Integer;
begin
  Result := chNone;
  AIndex := -1;
  VR := ViewRect;
  N := FItems.Count;

  if FShowArrows and (Y >= VR.Top) and (Y < VR.Bottom) then
  begin
    if X < ArrowAreaWidth then
    begin
      if CanGoPrevious then
        Result := chPrev;
      Exit;
    end;
    if X >= ClientWidth - ArrowAreaWidth then
    begin
      if CanGoNext then
        Result := chNext;
      Exit;
    end;
  end;

  if FShowIndicators and (N > 0) and (Y >= VR.Bottom) then
  begin
    IRc := IndicatorRect;
    Total := N * DOT + (N - 1) * DOT_GAP;
    if Total <= IRc.Width then
    begin
      X0 := IRc.Left + (IRc.Width - Total) div 2;
      Pos := X - X0 + DOT_GAP div 2;
      if (Pos >= 0) and (Pos div (DOT + DOT_GAP) < N) then
      begin
        AIndex := Pos div (DOT + DOT_GAP);
        Result := chDot;
      end;
    end;
    Exit;
  end;

  if (N > 0) and PtInRect(VR, Point(X, Y)) then
  begin
    Step := StepSize;
    Pos := X - VR.Left + Round(FOffset);
    if (Pos >= 0) and (Pos mod Step < CardWidth) and (Pos div Step < N) then
    begin
      CR := CardRect(Pos div Step);
      if (Y >= CR.Top) and (Y <= CR.Bottom) then
      begin
        AIndex := Pos div Step;
        Result := chCard;
      end;
    end;
  end;
end;

function TImageCarousel.ItemAtPos(X, Y: Integer): Integer;
begin
  if HitTest(X, Y, Result) <> chCard then
    Result := -1;
end;

function TImageCarousel.GetSelectedItem: TCarouselItem;
begin
  if (FItemIndex >= 0) and (FItemIndex < FItems.Count) then
    Result := FItems[FItemIndex]
  else
    Result := nil;
end;

{ ---------------------------------------------------------------- entrada }

procedure TImageCarousel.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result := DLGC_WANTARROWS;
end;

procedure TImageCarousel.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  case Key of
    VK_LEFT: Previous;
    VK_RIGHT: Next;
    VK_HOME: SetFirstVisible(0);
    VK_END: SetFirstVisible(MaxFirstVisible);
  else
    Exit;
  end;
  RestartAutoPlay;
  Key := 0;
end;

function TImageCarousel.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
  Result := inherited DoMouseWheel(Shift, WheelDelta, MousePos);
  if not Result then
  begin
    if WheelDelta < 0 then
      Next
    else
      Previous;
    RestartAutoPlay;
    Result := True;
  end;
end;

procedure TImageCarousel.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if TabStop and CanFocus and not Focused then
    SetFocus;
  if Button = mbLeft then
  begin
    FMouseDown := True;
    FDragging := False;
    FDragStartX := X;
    FDragStartOffset := FOffset;
  end;
end;

procedure TImageCarousel.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Hit: TCarouselHit;
  Index: Integer;
begin
  inherited MouseMove(Shift, X, Y);
  FMouseInside := True;

  // arrastar para rolar
  if FMouseDown and not FDragging and (FItems.Count > FVisibleCount) and
    (Abs(X - FDragStartX) > DRAG_THRESHOLD) then
    FDragging := True;
  if FDragging then
  begin
    FAnimTimer.Enabled := False;
    FOffset := EnsureRange(FDragStartOffset - (X - FDragStartX), 0.0, 1.0 * MaxFirstVisible * StepSize);
    Invalidate;
    Exit;
  end;

  Hit := HitTest(X, Y, Index);
  if Hit = chNone then
    Cursor := crDefault
  else
    Cursor := crHandPoint;
  if (Hit <> FHoverHit) or (Index <> FHoverIndex) then
  begin
    FHoverHit := Hit;
    FHoverIndex := Index;
    Invalidate;
  end;
end;

procedure TImageCarousel.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Index: Integer;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if Button <> mbLeft then
    Exit;
  FMouseDown := False;

  if FDragging then
  begin
    // solta no card mais próximo
    FDragging := False;
    SetFirstVisible(Round(FOffset / StepSize));
    FAnimTimer.Enabled := Abs(FTarget - FOffset) >= 0.5;
    RestartAutoPlay;
    Exit;
  end;

  case HitTest(X, Y, Index) of
    chPrev: Previous;
    chNext: Next;
    chDot: ScrollTo(Index);
    chCard: SelectItem(Index, True);
  else
    Exit;
  end;
  RestartAutoPlay;
end;

procedure TImageCarousel.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FMouseInside := False;
  if FHoverHit <> chNone then
  begin
    FHoverHit := chNone;
    FHoverIndex := -1;
    Invalidate;
  end;
end;

{ ---------------------------------------------------------------- setters }

procedure TImageCarousel.SetItems(const Value: TCarouselItems);
begin
  FItems.Assign(Value);
end;

procedure TImageCarousel.SetItemIndex(Value: Integer);
begin
  if csLoading in ComponentState then
  begin
    FItemIndex := Value; // os itens podem ainda não ter sido lidos; Loaded valida
    Exit;
  end;
  if (Value < 0) or (Value >= FItems.Count) then
  begin
    if FItemIndex <> -1 then
    begin
      FItemIndex := -1;
      Invalidate;
      DoChange;
    end;
  end
  else
    SelectItem(Value, False);
end;

procedure TImageCarousel.SetVisibleCount(Value: Integer);
begin
  Value := Max(1, Value);
  if FVisibleCount <> Value then
  begin
    FVisibleCount := Value;
    LayoutChanged;
  end;
end;

procedure TImageCarousel.SetSpacing(Value: Integer);
begin
  Value := Max(0, Value);
  if FSpacing <> Value then
  begin
    FSpacing := Value;
    LayoutChanged;
  end;
end;

procedure TImageCarousel.SetCardRadius(Value: Integer);
begin
  Value := Max(0, Value);
  if FCardRadius <> Value then
  begin
    FCardRadius := Value;
    Invalidate;
  end;
end;

procedure TImageCarousel.SetCaptionHeight(Value: Integer);
begin
  Value := Max(0, Value);
  if FCaptionHeight <> Value then
  begin
    FCaptionHeight := Value;
    Invalidate;
  end;
end;

procedure TImageCarousel.SetShowCaptions(Value: Boolean);
begin
  if FShowCaptions <> Value then
  begin
    FShowCaptions := Value;
    Invalidate;
  end;
end;

procedure TImageCarousel.SetShowIndicators(Value: Boolean);
begin
  if FShowIndicators <> Value then
  begin
    FShowIndicators := Value;
    LayoutChanged;
  end;
end;

procedure TImageCarousel.SetShowArrows(Value: Boolean);
begin
  if FShowArrows <> Value then
  begin
    FShowArrows := Value;
    LayoutChanged;
  end;
end;

procedure TImageCarousel.SetImageFit(Value: TCarouselImageFit);
begin
  if FImageFit <> Value then
  begin
    FImageFit := Value;
    InvalidateCaches;
  end;
end;

procedure TImageCarousel.SetImageBackground(Value: TColor);
begin
  if FImageBackground <> Value then
  begin
    FImageBackground := Value;
    InvalidateCaches;
  end;
end;

function TImageCarousel.GetColorProp(Index: Integer): TColor;
begin
  case Index of
    0: Result := FAccentColor;
    1: Result := FHoverColor;
    2: Result := FBorderColor;
    3: Result := FShadowColor;
    4: Result := FCardColor;
    5: Result := FArrowColor;
  else
    Result := FIndicatorColor;
  end;
end;

procedure TImageCarousel.SetColorProp(Index: Integer; Value: TColor);
begin
  case Index of
    0: FAccentColor := Value;
    1: FHoverColor := Value;
    2: FBorderColor := Value;
    3: FShadowColor := Value;
    4: FCardColor := Value;
    5: FArrowColor := Value;
    6: FIndicatorColor := Value;
  end;
  Invalidate;
end;

procedure TImageCarousel.SetWrap(Value: Boolean);
begin
  if FWrap <> Value then
  begin
    FWrap := Value;
    Invalidate;
  end;
end;

procedure TImageCarousel.SetAutoPlay(Value: Boolean);
begin
  if FAutoPlay <> Value then
  begin
    FAutoPlay := Value;
    UpdateAutoPlayTimer;
  end;
end;

function TImageCarousel.GetAutoPlayInterval: Cardinal;
begin
  Result := FAutoTimer.Interval;
end;

procedure TImageCarousel.SetAutoPlayInterval(Value: Cardinal);
begin
  if Value < 500 then
    Value := 500;
  FAutoTimer.Interval := Value;
end;

end.
