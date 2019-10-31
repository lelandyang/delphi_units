(* ********************************************************************
  网页文本处理单元

  Author: http://www.delphitop.com/html/hanshu/2819.html
  Comment: Web text processing unit, pure text operation without the need
  of any 3rd party component.
  Usage:

  (1) Extracting all links in a web page.
  var
  Links : TStringList;
  LinkFound,i : Integer;
  begin
  Links := TStringList.Create;
  LinkFound := ExtractHtmlTagValues(HtmlText,'A','HREF',Links);
  for i:=0 to LinkFound-1 do
  begin
  //Add your own codes here
  end;
  Links.Free;
  end;

  (2) 取得页面中名为 Submit 的表单项的值.
  var
  InputValue : String;
  begin
  InputValue := GetValByName(HtmlText,'Submit');
  end;

  (3) Get value from a submitting form.
  FUserID := getStrFromHtml(reqStr, 'id="userID"', 'value="', '"');

  ******************************************************************** *)

unit WebTextUtils;

interface

uses
  Classes, StrUtils, System.SysUtils;

{ HTML 标签值攫取函数，任意标签哦，纯字符串分析，可以配合IDHTTP编程 }
function ExtractHtmlTagValues(const HtmlText: string;
  TagName, AttribName: string; var Values: TStringList): integer;

{ 表单元素值攫取函数，可以从HTML文本中按照给定的Input名称解析出其Value }
function GetValByName(S, Sub: string): string;

{ 取某两个字符串中间的字符 }
function getStrFromHtml(var Source: String; SbStr, bStr, eStr: String): String;

implementation

function FindFirstCharAfterSpace(const Line: string; StartPos: integer)
  : integer;
var
  i: integer;
begin
  Result := -1;
  for i := StartPos to Length(Line) do
  begin
    if (Line[i] <> ' ') then
    begin
      Result := i;
      exit;
    end;
  end;
end;

function FindFirstSpaceAfterChars(const Line: string;
  StartPos: integer): integer;
begin
  Result := PosEx(' ', Line, StartPos);
end;

function FindFirstSpaceBeforeChars(const Line: string;
  StartPos: integer): integer;
var
  i: integer;
begin
  Result := 1;
  for i := StartPos downto 1 do
  begin
    if (Line[i] = ' ') then
    begin
      Result := i;
      exit;
    end;
  end;
end;

{ HTML 标签值攫取函数，任意标签哦，纯字符串分析，可以配合IDHTTP编程 }
function ExtractHtmlTagValues(const HtmlText: string;
  TagName, AttribName: string; var Values: TStringList): integer;
var
  InnerTag: string;
  LastPos, LastInnerPos: integer;
  SPos, LPos, RPos: integer;
  AttribValue: string;
  ClosingChar: char;
  TempAttribName: string;
begin
  Result := 0;
  LastPos := 1;
  while (true) do
  begin
    // find outer tags '<' & '>'
    LPos := PosEx('<', HtmlText, LastPos);
    if (LPos <= 0) then
      break;
    RPos := PosEx('>', HtmlText, LPos + 1);
    if (RPos <= 0) then
      LastPos := LPos + 1
    else
      LastPos := RPos + 1;

    // get inner tag
    InnerTag := Copy(HtmlText, LPos + 1, RPos - LPos - 1);
    InnerTag := Trim(InnerTag); // remove spaces
    if (Length(InnerTag) < Length(TagName)) then
      continue;

    // check tag name
    if (SameText(Copy(InnerTag, 1, Length(TagName)), TagName)) then
    begin
      // found tag
      AttribValue := '';
      LastInnerPos := Length(TagName) + 1;
      while (LastInnerPos < Length(InnerTag)) do
      begin
        // find first '=' after LastInnerPos
        RPos := PosEx('=', InnerTag, LastInnerPos);
        if (RPos <= 0) then
          break;

        // this way you can check for multiple attrib names and not a specific attrib
        SPos := FindFirstSpaceBeforeChars(InnerTag, RPos);
        TempAttribName := Trim(Copy(InnerTag, SPos, RPos - SPos));
        if (true) then
        begin
          // found correct tag
          LPos := FindFirstCharAfterSpace(InnerTag, RPos + 1);
          if (LPos <= 0) then
          begin
            LastInnerPos := RPos + 1;
            continue;
          end;
          LPos := FindFirstCharAfterSpace(InnerTag, LPos);
          // get to first char after '='
          if (LPos <= 0) then
            continue;
          if ((InnerTag[LPos] <> '"') and (InnerTag[LPos] <> '''')) then
          begin
            // AttribValue is not between '"' or ''' so get it
            RPos := FindFirstSpaceAfterChars(InnerTag, LPos + 1);
            if (RPos <= 0) then
              AttribValue := Copy(InnerTag, LPos, Length(InnerTag) - LPos + 1)
            else
              AttribValue := Copy(InnerTag, LPos, RPos - LPos + 1);
          end
          else
          begin
            // get url between '"' or '''
            ClosingChar := InnerTag[LPos];
            RPos := PosEx(ClosingChar, InnerTag, LPos + 1);
            if (RPos <= 0) then
              AttribValue := Copy(InnerTag, LPos + 1,
                Length(InnerTag) - LPos - 1)
            else
              AttribValue := Copy(InnerTag, LPos + 1, RPos - LPos - 1)
          end;

          if (SameText(TempAttribName, AttribName)) and (AttribValue <> '') then
          begin
            Values.Add(AttribValue);
            inc(Result);
          end;
        end;

        if (RPos <= 0) then
          LastInnerPos := Length(InnerTag)
        else
          LastInnerPos := RPos + 1;
      end;
    end;
  end;
end;

function FindEleRange(str: string; front: boolean; posi: integer): integer;
var
  i: integer;
begin
  if front then
  begin
    for i := posi - 1 downto 1 do
      if str[i] = '<' then
      begin
        Result := i;
        break;
      end;
  end
  else
  begin
    for i := posi + 1 to Length(str) do
      if str[i] = '>' then
      begin
        Result := i;
        break;
      end;
  end;
end;

function FindEnd(str: string; posi: integer): integer;
var
  i: integer;
begin
  for i := posi to Length(str) do
  begin
    if (str[i] = '"') or (str[i] = '''') or (str[i] = ' ') then
    begin
      Result := i - 1;
      break;
    end;
  end;
end;

{ 表单元素值攫取函数，可以从HTML文本中按照给定的Input名称解析出其Value }
function GetValByName(S, Sub: string): string;
var
  EleS, EleE, iPos: integer;
  ELeStr, ValSt: String;
  St, Ct: integer;
begin
  iPos := Pos('name="' + lowercase(Sub) + '"', lowercase(S));
  if iPos = 0 then
    iPos := Pos('name=' + lowercase(Sub), lowercase(S));
  if iPos = 0 then
    iPos := Pos('name=''' + lowercase(Sub) + '''', lowercase(S));
  if iPos = 0 then
    exit;
  EleS := FindEleRange(S, true, iPos);
  EleE := FindEleRange(S, FALSE, iPos);
  ELeStr := Copy(S, EleS, EleE - EleS + 1);
  ValSt := 'value="';
  iPos := Pos(ValSt, ELeStr);
  if iPos = 0 then
  begin
    ValSt := 'value=''';
    iPos := Pos(ValSt, ELeStr);
  end;
  if iPos = 0 then
  begin
    ValSt := 'value=';
    iPos := Pos(ValSt, ELeStr);
  end;
  St := iPos + Length(ValSt);
  Ct := FindEnd(ELeStr, St) - St + 1;
  Result := Copy(ELeStr, St, Ct);
end;

{ 取某两个字符串中间的字符 }
function getStrFromHtml(var Source: String; SbStr, bStr, eStr: String): String;
var
  i: integer;
  sbPos, bPos, ePos: integer;
  S: String;
begin
  S := Source;

  Result := '';
  if SbStr <> '' then
  Begin
    sbPos := Pos(UpperCase(SbStr), UpperCase(S));
    if sbPos > 0 then
      Delete(S, 1, sbPos - 1 + Length(SbStr))
    Else
      exit;
  End;

  bPos := Pos(UpperCase(bStr), UpperCase(S));
  if bPos > 0 then
    Delete(S, 1, bPos - 1 + Length(bStr))
  Else
    exit;

  ePos := Pos(UpperCase(eStr), UpperCase(S));
  if ePos > 0 then
    Delete(S, ePos, Length(S));

  Result := S;
end;

end.
