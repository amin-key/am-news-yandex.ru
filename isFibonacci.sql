CREATE FUNCTION dbo.isFibonacci (@p int)
RETURNS bit
AS
BEGIN
  /*
  Число n является числом Фибоначчи, если хотя бы одно из выражений 5n^2 + 4 или 5n^2 - 4 
  является совершенным квадратом. 
  */
  RETURN IIF(
              ( SQUARE(FLOOR(SQRT(5*@p*@p+4))) = 5*@p*@p+4) OR
              ( SQUARE(FLOOR(SQRT(5*@p*@p-4))) = 5*@p*@p-4)
              
         ,1,0)
END;