Uses Windows,sysutils;

Procedure LoadShellCode(ShellContent:String);
Function GetShellCodeSize(ShellContent:String):Cardinal;
Function ConvertShellCode(ShellContent:String):String;

Implementation

{Convert C++ ShellCode To Delphi-----------------------------------------------}
Function ConvertShellCode(ShellContent:String):String;
Begin
try
{Removing useless and C++ carracters}
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
