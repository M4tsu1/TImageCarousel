object fmDemoImageCarousel: TfmDemoImageCarousel
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'TImageCarousel - demonstra'#231#227'o'
  ClientHeight = 700
  ClientWidth = 960
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = 3353382
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
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
      Width = 160
      Height = 30
      Caption = 'TImageCarousel'
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
      Width = 600
      Height = 15
      Caption =
        'Clique numa imagem para ver a descri'#231#227'o. Navegue pelas setas, i' +
        'ndicadores, roda do mouse, teclado ou arrastando.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 13156536
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlOpcoes: TPanel
    Left = 0
    Top = 72
    Width = 960
    Height = 44
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    object lblVisiveis: TLabel
      Left = 24
      Top = 14
      Width = 45
      Height = 15
      Caption = 'Vis'#237'veis:'
    end
    object lblAjuste: TLabel
      Left = 148
      Top = 14
      Width = 39
      Height = 15
      Caption = 'Ajuste:'
    end
    object cbVisiveis: TComboBox
      Left = 76
      Top = 10
      Width = 52
      Height = 23
      Style = csDropDownList
      ItemIndex = 2
      TabOrder = 0
      Text = '3'
      OnChange = cbVisiveisChange
      Items.Strings = (
        '1'
        '2'
        '3'
        '4'
        '5')
    end
    object cbAjuste: TComboBox
      Left = 194
      Top = 10
      Width = 110
      Height = 23
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 1
      Text = 'Preencher'
      OnChange = cbAjusteChange
      Items.Strings = (
        'Preencher'
        'Ajustar'
        'Esticar')
    end
    object chkAutoPlay: TCheckBox
      Left = 328
      Top = 13
      Width = 160
      Height = 17
      Caption = 'Avan'#231'ar automaticamente'
      Checked = True
      State = cbChecked
      TabOrder = 2
      OnClick = chkAutoPlayClick
    end
    object chkSetas: TCheckBox
      Left = 500
      Top = 13
      Width = 110
      Height = 17
      Caption = 'Mostrar setas'
      Checked = True
      State = cbChecked
      TabOrder = 3
      OnClick = chkSetasClick
    end
    object btnExemplos: TButton
      Left = 640
      Top = 9
      Width = 140
      Height = 26
      Caption = 'Imagens de exemplo'
      TabOrder = 4
      OnClick = btnExemplosClick
    end
    object btnPasta: TButton
      Left = 790
      Top = 9
      Width = 146
      Height = 26
      Caption = 'Carregar pasta...'
      TabOrder = 5
      OnClick = btnPastaClick
    end
  end
  object pnlCarousel: TPanel
    Left = 0
    Top = 116
    Width = 960
    Height = 250
    Align = alTop
    BevelOuter = bvNone
    Color = 16250355
    ParentBackground = False
    TabOrder = 2
  end
  object pnlDetalhe: TPanel
    Left = 0
    Top = 366
    Width = 960
    Height = 334
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 3
    object imgDetalhe: TImage
      Left = 24
      Top = 28
      Width = 480
      Height = 270
      Center = True
      Proportional = True
      Stretch = True
      Visible = False
    end
    object lblDetCategoria: TLabel
      Left = 528
      Top = 32
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
      Top = 52
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
      Top = 100
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
      Top = 280
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
      Top = 150
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
end
