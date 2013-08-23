{$R-} {Range checking off}
{$B-} {Short-circuit Boolean evaluation}
{$S-} {Stack checking off}
{$I+} {I/O checking on}
{$N-} {Numeric coprocessor absent}
{$M 65500, 16384, 655360} {Turbo 3 default stack and heap}

program Hershey; {generates METAFONT source code from a Hershey character
  database in SoftCraft format}
const
  NMax = 157; {maximum number of plotter pen movement commands for one
    character in the databases}
  PenUp = $4000;
  EndOfChar = 0;
var
  H : file of integer; {Hershey database input}
  Log : text; {METAFONT source output}
  Code, Depth, EndChar, Height, I, J, K, N, StartChar, Width, XMax, XMin, Y0,
    YMax, YMin : integer;
  XY : array[0..NMax] of integer; {(x, y) coordinates}
  Z : array[1..NMax] of byte; {METAFONT variables}
  Database : string[7]; {database filename without extension}

procedure ReadH; {reads a plotter directive from the input file}
begin
  if Eof(H) then
  begin
    Writeln('End of file at char = ', Code);
    Close(H);
    Close(Log);
    Halt;
  end;
  Inc(N);
  Read(H, XY[N]);
end; {ReadH}

begin
  if ParamCount <> 3 then
  begin
    Writeln('Usage: HERSHEY database start end');
    Halt;
  end;
  Database := ParamStr(1);
  for Code := 1 to 7 do
    Database[Code] := UpCase(Database[Code]);
  Val(ParamStr(2), StartChar, Code);
  if Code <> 0 then
  begin
    Writeln('Starting character not an integer');
    Halt;
  end;
  Val(ParamStr(3), EndChar, Code);
  if Code <> 0 then
  begin
    Writeln('Ending character not an integer');
    Halt;
  end;
  Assign(H, Database + '.CHR');
  Reset(H);
  Assign(Log, Database + '.LOG');
  Rewrite(Log);
  Writeln(Log, '% ', Database + '.CHR  ', StartChar, ' to ', EndChar);
  for Code := 0 to StartChar do
  begin
    N := -1;
    repeat
      ReadH;
    until XY[N] = EndOfChar;
  end; {skip forward to specified start character}
  Z[1] := 1;
  for Code := StartChar to EndChar do
  begin
    Writeln(Log);
    Writeln(Log, 'cmchar "', Database, ' ', Code, '";');
    N := -1;
    ReadH; {the width bytes}
    XMin := Lo(XY[0]); {minimum x coordinate}
    XMax := Hi(XY[0]); {maximum x coordinate}
    Width := XMax - XMin; {width of character}
    Y0 := 73; {default y bias}
    if Database = 'HERSHEY' then
      case Code of
        0..88: Y0 := 68;
        397..672: Y0 := 70;
      end;
    {Find minimum and maximum y values.}
    YMax := 0;
    YMin := 256;
    repeat
      ReadH;
      if (XY[N] <> PenUp) and (XY[N] <> EndOfChar) then
      begin
        if Hi(XY[N]) > YMax then
          YMax := Hi(XY[N]);
        if Hi(XY[N]) < YMin then
          YMin := Hi(XY[N]);
      end; {if a real coordinate}
    until XY[N] = EndOfChar;
    Height := Y0 - YMin; 
    if YMax > Y0 then
      Depth := YMax - Y0
    else
      Depth := 0;
    Writeln(Log, 'beginchar(', Code mod 128, ', ', Width, 'u#, ', Height,
      'u#, ', Depth, 'u#);');
    Writeln(Log, 'adjust_fit(0, 0);');
    Writeln(Log, 'pickup plotter_pen;');
    for I := 2 to Pred(N) do
    begin {enumerate unique coordinates}
      Z[I] := 0;
      if XY[I] <> PenUp then
      begin
        for J := Pred(I) downto 1 do
          if XY[I] = XY[J] then
            Z[I] := J;
        if Z[I] = 0 then
          Z[I] := I;
      end;
    end;
    for I := 1 to Pred(N) do
      if Z[I] = I then
    Writeln(Log, 'z', I, ' = (', Lo(XY[I]) - XMin, 'u, ', Y0 - Hi(XY[I]),
      'u);');
    I := 0;
    J := 1;
    repeat
      Inc(I);
      if (XY[I] = PenUp) or (XY[I] = EndOfChar) then
      begin
        case I - J of {number of points joined by consecutive line segments}
          0: ;
          1: Writeln(Log, 'drawdot z', Z[J], ';');
          2: if Z[J] = Z[Succ(J)] then
               Writeln(Log, 'drawdot z', Z[J], ';')
             else
               Writeln(Log, 'draw z', Z[J], '--z', Z[Succ(J)], ';');
          else
          begin
            Write(Log, 'draw z', Z[J]);
            for K := Succ(J) to Pred(I) do
              Write(Log, '--z', Z[K]);
            Writeln(Log, ';');
          end; {3 or more}
        end; {case}
        J := Succ(I);
      end; {if a real coordinate}
    until I = N;
    Writeln(Log, 'endchar;');
  end; {specified range of characters}
  Close(H);
  Close(Log);
end.

