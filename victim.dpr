library victim;

{$IFDEF FPC}
{$mode objfpc}{$H+}
{$ENDIF FPC}

uses
  Classes, Windows;

function PrintLine(const AString: PAnsiChar; ASleep: DWORD): HRESULT; stdcall;
begin
  WriteLn('Sleeping ', ASleep, ' milliseconds');
  Sleep(ASleep);
  WriteLn(AString);
  Result := S_OK;
end;

exports
  PrintLine;
begin
end.

