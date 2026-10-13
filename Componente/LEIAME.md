# TImageCarousel

Carrossel de imagens clicáveis para VCL (Delphi 10.3 ou superior). Fica na paleta **Carousel**.

## Instalação

1. Abra `ImageCarouselPkg.dpk` no Delphi.
2. No Project Manager, clique com o botão direito no pacote e escolha **Install**.
3. Em **Tools > Options > Language > Delphi > Library > Library path**, adicione a pasta `Componente`.
   Sem isso, os projetos que usam o componente não acham a unit `ImageCarousel`.

Pronto: o `TImageCarousel` aparece na paleta **Carousel**.

Para testar sem instalar, abra `Demo\DemoImageCarousel.dpr`. A demo cria o componente em código.

## Uso

### Em design time

Arraste o componente para o form e edite `Items` no Object Inspector.
Cada item tem `Title`, `Category`, `Description`, `Picture` (PNG, JPG, BMP ou GIF) e `Tag`.

### Em código

```pascal
// a partir de arquivo (sem título, usa o nome do arquivo)
ImageCarousel1.AddItemFromFile('C:\Fotos\silo.jpg', 'Armazém', 'Logística', 'Silos da unidade 2');

// a partir de um campo blob do banco
var Stream: TStream;
Stream := Query.CreateBlobStream(Query.FieldByName('foto'), bmRead);
try
  ImageCarousel1.AddItemFromStream(Stream, Query.FieldByName('nome').AsString)
    .Tag := Query.FieldByName('id').AsInteger;  // guarda o ID para usar no clique
finally
  Stream.Free;
end;

// vários itens de uma vez: um único redesenho no final
ImageCarousel1.Items.BeginUpdate;
try
  ...
finally
  ImageCarousel1.Items.EndUpdate;
end;
```

### Clique

```pascal
procedure TForm1.ImageCarousel1ItemClick(Sender: TObject; AIndex: Integer; AItem: TCarouselItem);
begin
  lblTitulo.Caption := AItem.Title;
  lblDescricao.Caption := AItem.Description;
  Image1.Picture.Assign(AItem.Picture);
  // AItem.Tag ou AItem.Data para chegar no registro de origem
end;
```

## Propriedades principais

| Propriedade | Padrão | O que faz |
|---|---|---|
| `Items` | | Coleção de itens (título, categoria, descrição, imagem, tag). |
| `ItemIndex` | -1 | Item selecionado. `SelectedItem` devolve o item. |
| `VisibleCount` | 3 | Quantos cards aparecem por vez. |
| `ImageFit` | `cifFill` | `cifFill` preenche e corta, `cifFit` mostra inteira, `cifStretch` estica. |
| `AutoPlay` / `AutoPlayInterval` | False / 3500 | Avança sozinho; pausa com o mouse em cima se `PauseOnHover`. |
| `Wrap` | True | Do último volta ao primeiro. |
| `CenterOnClick` | True | Centraliza o card clicado. |
| `ShowArrows`, `ShowIndicators`, `ShowCaptions` | True | Liga e desliga setas, bolinhas e legendas. |
| `Spacing`, `CardRadius`, `CaptionHeight` | 16, 6, 26 | Espaço entre cards, arredondamento e altura da legenda. |
| `AccentColor`, `HoverColor`, `BorderColor`, `ShadowColor`, `CardColor`, `ArrowColor`, `IndicatorColor`, `ImageBackground` | | Cores. `Color` é o fundo e `Font` a fonte das legendas. |

## Métodos e eventos

- **Métodos:** `Next`, `Previous`, `ScrollTo(Index)`, `Clear`, `ItemAtPos(X, Y)`, `HitTest(X, Y, Index)`, `AddItem`, `AddItemFromFile` e `AddItemFromStream`.
- **Eventos:**
  - `OnItemClick`: clique num card.
  - `OnChange`: o `ItemIndex` mudou.
  - `OnScroll`: o carrossel rolou.

## Navegação

O carrossel responde a:
- setas laterais;
- bolinhas indicadoras;
- roda do mouse;
- teclado (← → Home End, com o componente focado);
- arrastar com o mouse.
