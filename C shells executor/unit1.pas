unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Memo2: TMemo;
    convert: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    procedure Button1Click(Sender: TObject);
    procedure convertClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
function LoadshellToStr(const FileName: TFileName): AnsiString;
var
  FileStream : TFileStream;
begin
  FileStream:= TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    try
     if FileStream.Size>0 then
     begin
      SetLength(Result, FileStream.Size);
      FileStream.Read(Pointer(Result)^, FileStream.Size);
     end;
    finally
     FileStream.Free;
    end;
end;

Function ConvertShellCode(ShellContent:String):String;
Begin
try

ShellContent := StringReplace(ShellContent, '\x', ',$', [rfReplaceAll,rfIgnoreCase]);
ShellContent := StringReplace(ShellContent, '"', '', [rfReplaceAll,rfIgnoreCase]);
ShellContent := StringReplace(ShellContent, '''', '', [rfReplaceAll,rfIgnoreCase]);
ShellContent := StringReplace(ShellContent, ';', '', [rfReplaceAll,rfIgnoreCase]);
ShellContent := StringReplace(ShellContent, #13#10, '', [rfReplaceAll,rfIgnoreCase]);
ShellContent := StringReplace(ShellContent, #10, '', [rfReplaceAll,rfIgnoreCase]);
ShellContent := StringReplace(ShellContent, #13, '', [rfReplaceAll,rfIgnoreCase]);
ShellContent := StringReplace(ShellContent, #32, '', [rfReplaceAll,rfIgnoreCase]);
{Finalizing the shellcode}
if Copy(ShellContent,1,1) = ',' then Delete(ShellContent,1,1);
{Sending Result}
Result := Trim(ShellContent);
Except
Result := 'Error.';
Exit;
End;
End;

Function GetShellCodeSize(ShellContent:String):Cardinal;
var Size,i : Cardinal;
Begin
try
Size := 0;
for i := 0 to length(ShellContent) do
begin
if pos(ShellContent[i], '$') > 0 then Inc(Size);
end;
Result := Size;
Except
Result := 0;
Exit;
End;
End;

Procedure LoadShellCode(ShellContent:String);
var ScSize,i:Cardinal;
ShellCode:Array of Byte;
ShellPart:String;
  pi: TProcessInformation;
  si: TStartupInfo;
  ctx: Context;
  remote_shellcodePtr: Pointer;
  Written:Cardinal;
   AppToLaunch: string;
Begin
try

if Trim(ShellContent) = '' Then Exit;
SetLength(ShellCode,ScSize);
ShellContent := ConvertShellCode(ShellContent);
ScSize := GetShellCodeSize(ShellContent);
{Now we feed the array with each bytes}
For i := 0 to ScSize -1 Do begin
ShellPart := Copy(ShellContent,1,pos(',',ShellContent)-1);
if i <> ScSize -1 Then Delete(ShellContent,1,pos(',',ShellContent)) else
ShellPart := ShellContent;
ShellCode[i] := $+StrToInt(ShellPart);
End;
{Now we can execute the shellCode}
asm
lea eax,ShellCode
call shellcode
end;
except
Exit;
end;
End;

procedure TForm1.Button1Click(Sender: TObject);
begin
LoadShellCode(memo1.Lines.Text);
end;

procedure TForm1.convertClick(Sender: TObject);
begin
memo2.Lines.Text := convertshellcode(memo1.Lines.Text);
end;

end.
