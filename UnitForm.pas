unit UnitForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    OpenDialog1: TOpenDialog;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses UnitLib;

procedure TForm1.Button1Click(Sender: TObject);
var
  InFile, OutFile: string;
  A, B, C: string;
begin
  OpenDialog1.Title := 'Выберите входной файл (2 строки с числами)';
  OpenDialog1.Filter := 'Текстовые файлы (*.txt)|*.txt|Все файлы (*.*)|*.*';
  OpenDialog1.Options := OpenDialog1.Options + [ofFileMustExist, ofPathMustExist];
  if not OpenDialog1.Execute then
    Exit;

  InFile := OpenDialog1.FileName;
  // По умолчанию пишем рядом, в тот же каталог
 // OutFile := ChangeFileExt(InFile, '') + '_out.txt';
  OutFile := ChangeFileExt(InFile, '') + '.txt';

  try
    // читаем 2 строки, считаем, пишем 3 строки
    TBigNumIO.ReadTwoStrict(InFile, A, B);
    C := AddBig(A, B);
    TBigNumIO.WriteThreeStrict(OutFile, A, B, C);
    ShowMessage(Format('Готово! Результат записан в: %s'#13#10'%s + %s = %s',
      [OutFile, A, B, C]));
  except
    on E: EBigNumIO do
      ShowMessage('Ошибка ввода/вывода: ' + E.Message);
    on E: Exception do
      ShowMessage('Неожиданная ошибка: ' + E.Message);
  end;
end;
end.
