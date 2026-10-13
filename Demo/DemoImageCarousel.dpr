program DemoImageCarousel;

uses
  Vcl.Forms,
  ImageCarousel in '..\Componente\ImageCarousel.pas',
  UDemoImageCarousel in 'UDemoImageCarousel.pas' {fmDemoImageCarousel};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmDemoImageCarousel, fmDemoImageCarousel);
  Application.Run;
end.
