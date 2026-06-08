program BigSum;

uses
  Forms,
  UnitForm in 'UnitForm.pas' {Form1},
  UnitLib in 'UnitLib.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
