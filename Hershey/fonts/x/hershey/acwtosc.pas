{$R-} {Range checking off}
{$B-} {Short-circuit Boolean evaluation}
{$S-} {Stack checking off}
{$I+} {I/O checking on}
{$N-} {No numeric coprocessor}
{$M 65500, 16384, 655360} {Turbo 3 default stack and heap}

program ACWtoSC; {converts the Hershey font tables distributed by The Austin
  Code Works to the format expected by the Cfont program of SoftCraft, Inc.}
const
  PenUp : integer = $4000;
type
  S3 = string[3];
var
  Buf1 : array[1..$2000] of char;
  F1 : text;
  H : file of integer;
  L1 : string[80];
  Fn : array[1..2] of string[64];
  Code, I, L, M, XY : integer;
  X, Y : array[1..144] of integer;
  Eoc : boolean;

function V(S : S3) : integer;
var
  I : integer;
begin
  Val(S, I, Code);
  if (Code <> 0) or ((I < -49) and (I <> -64)) or (I > 49) then
  begin
    Writeln(L1);
    Writeln('Code = ', Code);
    Halt(3);
  end;
  V := I;
end;

begin
  if ParamCount <> 2 then
  begin
    Writeln('Usage: ACWTOSC file1 file2');
    Halt(3);
  end;
  for L := 1 to 2 do
  begin
    Fn[L] := ParamStr(L);
    for M := 1 to Length(Fn[L]) do
      Fn[L][M] := UpCase(Fn[L][M]);
  end;
  Assign(F1, Fn[1]);
  SetTextBuf(F1, Buf1);
  {$I-} Reset(F1); {$I+}
  if IOResult <> 0 then
  begin
    Writeln('Cannot open ', Fn[1]);
    Halt(3);
  end;
  Assign(H, Fn[2]);
  {$I-} Rewrite(H); {$I+}
  if IOResult <> 0 then
  begin
    Writeln('Cannot open ', Fn[2]);
    Close(F1);
    Halt(3);
  end;
  while not Eof(F1) do
  begin
    Readln(F1, L1);
    if Copy(L1, 5, 1) <> ' ' then
    begin
      M := 0;
      Eoc := false;
    end;
    L := 0;
    repeat
      Inc(L);
      Inc(M);
      X[M] := V(Copy(L1, 8 * L + 1, 3));
      Y[M] := V(Copy(L1, 8 * L + 5, 3));
      if (X[M] = -64) and (Y[M] = -64) then
      begin
        Eoc := true;
        Write(H, Code); {two bytes of zeros before each character}
        XY := 256 * (Y[1] + 64) + X[1] + 64; {width of character}
        Write(H, XY);
        for I := 2 to Pred(M) do
          if X[I] = -64 then
            Write(H, PenUp)
          else
          begin
            XY := 256 * (73 + Y[I]) + X[I] + 64;
            Write(H, XY);
          end;
      end;
    until (L = 8) or Eoc;
  end;
  Write(H, Code); {two bytes of zeros at end of file}
  Close(F1);
  Close(H);
end.
