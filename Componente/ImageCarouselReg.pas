unit ImageCarouselReg;

interface

procedure Register;

implementation

{$R ImageCarousel.dcr}

uses
  System.Classes, ImageCarousel;

procedure Register;
begin
  RegisterComponents('Carousel', [TImageCarousel]);
end;

end.
