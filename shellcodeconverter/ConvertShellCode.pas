program Project1;

{$APPTYPE CONSOLE}

uses
  SysUtils,classes;


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
var
content : string;
converted : widestring;
F: TextFile;
begin
  try
  content := loadshelltostr('C:\sh\c-shell.txt');
  converted := convertshellcode(content);
  AssignFile(F, 'C:\sh\pascalshell.txt');
  Rewrite(F);
  WriteLn(F, converted);
  CloseFile(F);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
