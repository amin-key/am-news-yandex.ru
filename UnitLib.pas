unit UnitLib;

interface

uses
  SysUtils, Classes;

type
  EBigNumIO = class(Exception);

  TBigNumIO = class
  public
    // читает 2 строки (большие числа) из файла; пробелы по кра€м обрезаютс€
    class procedure ReadTwoStrict(const AFileName: string; out S1, S2: string);
    // записывает 3 строки (первые две Ч исходные, треть€ Ч результат) в файл
    class procedure WriteThreeStrict(const AFileName, S1, S2, S3: string);
  end;

// —ложение больших чисел, представленных строками (С0Т..С9Т), без лидирующих нулей
function AddBig(const A, B: string): string;

implementation

function IsDigitsOnly(const S: string): Boolean;
var
  i: Integer;
begin
  Result := (Length(S) > 0);
  for i := 1 to Length(S) do
    if (S[i] < '0') or (S[i] > '9') then
    begin
      Result := False;
      Exit;
    end;
end;

class procedure TBigNumIO.ReadTwoStrict(const AFileName: string; out S1, S2: string);
var
  SL: TStringList;
begin
  S1 := '';
  S2 := '';
  if not FileExists(AFileName) then
    raise EBigNumIO.CreateFmt('‘айл не найден: %s', [AFileName]);

  SL := TStringList.Create;
  try
    try
      SL.LoadFromFile(AFileName);
    except
      on E: Exception do
        raise EBigNumIO.CreateFmt('ќшибка чтени€ файла %s: %s', [AFileName, E.Message]);
    end;

    if SL.Count < 2 then
      raise EBigNumIO.Create('Ќедостаточно строк: ожидались хот€ бы две строки с числами');

    S1 := Trim(SL[0]);
    S2 := Trim(SL[1]);

    if (S1 = '') or (S2 = '') then
      raise EBigNumIO.Create('ѕуста€ строка числа');

    if (not IsDigitsOnly(S1)) or (not IsDigitsOnly(S2)) then
      raise EBigNumIO.Create('Ќеверный формат: допустимы только цифры 0Ц9 без знака');
  finally
    SL.Free;
  end;
end;

class procedure TBigNumIO.WriteThreeStrict(const AFileName, S1, S2, S3: string);
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    SL.Add(Trim(S1));
    SL.Add(Trim(S2));
    SL.Add(Trim(S3));
    try
      SL.SaveToFile(AFileName);
    except
      on E: Exception do
        raise EBigNumIO.CreateFmt('ќшибка записи файла %s: %s', [AFileName, E.Message]);
    end;
  finally
    SL.Free;
  end;
end;

function StripLeadingZeros(const S: string): string;
var
  i: Integer;
begin
  i := 1;
  while (i < Length(S)) and (S[i] = '0') do Inc(i);
  Result := Copy(S, i, MaxInt);
  if Result = '' then Result := '0';
end;

function AddBig(const A, B: string): string;
var
  i, j, k, carry, {da, db,} s, sm: Integer;
  sa, sb, res: string;
begin
  i := Length(A);
  j := Length(B);
  res := '';
  Result := res;
  if (i=0)and(j=0) then Exit;
  res := '';
  sa:=A;
  sb:=B;
  s:= i;
  carry := 0;
  if (i>j) then
     sb:= StringOfChar('0',i-j) + B
  else
  if (i<j) then
    begin
      sa:= StringOfChar('0',j-i) + A;
      s:= j;
    end;
   for k:=s downto 1 do
     begin
       sm :=StrToInt(sa[k]) + StrToInt(sb[k])+ carry;
       carry := sm div 10;
       sm:= sm mod 10;
       res:=IntToStr(sm)+ res;
       if (k=1)and(carry=1)
        then res:='1'+res;
     end;
   Result := res;
end;
end.
 