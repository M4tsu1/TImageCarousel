object fmCarousel: TfmCarousel
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Carrossel de imagens'
  ClientHeight = 650
  ClientWidth = 960
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = 3353382
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 15
  object pnlTopo: TPanel
    Left = 0
    Top = 0
    Width = 960
    Height = 72
    Align = alTop
    BevelOuter = bvNone
    Color = 3353382
    ParentBackground = False
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 24
      Top = 12
      Width = 182
      Height = 30
      Caption = 'Galeria de imagens'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -21
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSubtitulo: TLabel
      Left = 24
      Top = 44
      Width = 380
      Height = 15
      Caption =
        'Clique em uma imagem para ver a descri'#231#227'o. Use as setas do tecl' +
        'ado para navegar.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 13156536
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlCarousel: TPanel
    Left = 0
    Top = 72
    Width = 960
    Height = 254
    Align = alTop
    BevelOuter = bvNone
    Color = 16250355
    DoubleBuffered = True
    ParentBackground = False
    ParentDoubleBuffered = False
    TabOrder = 1
    object btnAnterior: TSpeedButton
      Left = 16
      Top = 60
      Width = 40
      Height = 64
      Cursor = crHandPoint
      Caption = #8249
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 3353382
      Font.Height = -32
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      OnClick = btnAnteriorClick
    end
    object btnProximo: TSpeedButton
      Left = 904
      Top = 60
      Width = 40
      Height = 64
      Cursor = crHandPoint
      Caption = #8250
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 3353382
      Font.Height = -32
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      OnClick = btnProximoClick
    end
    object pbIndicadores: TPaintBox
      Left = 68
      Top = 202
      Width = 824
      Height = 20
      Cursor = crHandPoint
      OnMouseUp = pbIndicadoresMouseUp
      OnPaint = pbIndicadoresPaint
    end
    object lblPosicao: TLabel
      Left = 68
      Top = 228
      Width = 120
      Height = 15
      Caption = 'Exibindo 1 a 3 de 10'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 8421504
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object pnlViewport: TPanel
      Left = 68
      Top = 14
      Width = 824
      Height = 182
      BevelOuter = bvNone
      Color = 16250355
      DoubleBuffered = True
      ParentBackground = False
      ParentDoubleBuffered = False
      TabOrder = 0
      object pbCarousel: TPaintBox
        Left = 0
        Top = 0
        Width = 824
        Height = 182
        Align = alClient
        OnMouseLeave = pbCarouselMouseLeave
        OnMouseMove = pbCarouselMouseMove
        OnMouseUp = pbCarouselMouseUp
        OnPaint = pbCarouselPaint
      end
    end
    object chkAutoPlay: TCheckBox
      Left = 740
      Top = 227
      Width = 152
      Height = 17
      Caption = 'Avan'#231'ar automaticamente'
      Checked = True
      State = cbChecked
      TabOrder = 1
      OnClick = chkAutoPlayClick
    end
  end
  object pnlDetalhe: TPanel
    Left = 0
    Top = 326
    Width = 960
    Height = 324
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 2
    object imgDetalhe: TImage
      Left = 24
      Top = 24
      Width = 480
      Height = 270
      Visible = False
    end
    object lblDetCategoria: TLabel
      Left = 528
      Top = 28
      Width = 63
      Height = 15
      Caption = 'CATEGORIA'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 13331211
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      Visible = False
    end
    object lblDetTitulo: TLabel
      Left = 528
      Top = 48
      Width = 408
      Height = 32
      AutoSize = False
      Caption = 'T'#237'tulo'
      EllipsisPosition = epEndEllipsis
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 3353382
      Font.Height = -24
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      Visible = False
    end
    object lblDetDescricao: TLabel
      Left = 528
      Top = 96
      Width = 408
      Height = 160
      AutoSize = False
      Caption = 'Descri'#231#227'o'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 5263440
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      Visible = False
      WordWrap = True
    end
    object lblDetContador: TLabel
      Left = 528
      Top = 276
      Width = 80
      Height = 15
      Caption = 'Imagem 1 de 10'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 8421504
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      Visible = False
    end
    object lblDica: TLabel
      Left = 0
      Top = 140
      Width = 960
      Height = 21
      Alignment = taCenter
      AutoSize = False
      Caption = 'Clique em uma imagem do carrossel para ver a descri'#231#227'o.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 8421504
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object tmrAnimacao: TTimer
    Enabled = False
    Interval = 15
    OnTimer = tmrAnimacaoTimer
    Left = 856
    Top = 384
  end
  object tmrAutoPlay: TTimer
    Enabled = False
    Interval = 3500
    OnTimer = tmrAutoPlayTimer
    Left = 904
    Top = 384
  end
end
