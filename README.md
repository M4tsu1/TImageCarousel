# TImageCarousel

Carrossel de imagens clicáveis para **Delphi VCL** (10.3 Rio ou superior), desenhado inteiro no Canvas.
Não usa um componente por imagem nem depende de bibliotecas de terceiros.

- Cards com cantos arredondados, sombra, legenda e destaque de hover e de seleção.
- Animação suave, sem flicker (double buffer próprio).
- Navegação por setas, indicadores, roda do mouse, teclado (← → Home End) e arrastar com o mouse.
- Itens editáveis em design time: título, categoria, descrição, imagem PNG/JPG/BMP/GIF e tag.
- Carga em código a partir de arquivo ou de stream (campo blob do banco).
- Três modos de ajuste da imagem: preencher, ajustar e esticar.
- Avanço automático com pausa quando o mouse está em cima.
- Evento `OnItemClick` com o índice e o item clicado.

## Estrutura

| Pasta | Conteúdo |
|---|---|
| `Componente/` | Unit do componente, pacote instalável (`ImageCarouselPkg.dpk`), ícone da paleta e o [guia completo](Componente/LEIAME.md). |
| `Demo/` | Projeto de demonstração. Compila sem instalar o pacote, porque cria o componente em código. |
| `UCarousel.pas/.dfm` | Versão original em formulário único, sem componente: um bom ponto de partida para entender a técnica. |

## Instalação rápida

1. Abra `Componente/ImageCarouselPkg.dpk` no Delphi.
2. No Project Manager, clique com o botão direito no pacote e escolha **Install**.
3. Adicione a pasta `Componente` em **Tools > Options > Language > Delphi > Library > Library path**.

O `TImageCarousel` aparece na paleta **Carousel**.

## Exemplo

```pascal
ImageCarousel1.AddItemFromFile('C:\Fotos\silo.jpg', 'Armazém', 'Logística', 'Silos da unidade 2');

procedure TForm1.ImageCarousel1ItemClick(Sender: TObject; AIndex: Integer; AItem: TCarouselItem);
begin
  lblTitulo.Caption := AItem.Title;
  lblDescricao.Caption := AItem.Description;
  Image1.Picture.Assign(AItem.Picture);
end;
```

Propriedades, métodos e mais exemplos (inclusive carregar de campo blob) estão em [Componente/LEIAME.md](Componente/LEIAME.md).

## Licença

[Apache 2.0](LICENSE)
