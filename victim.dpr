library victim;

{$IFDEF FPC}
{$mode objfpc}{$H+}
{$ENDIF FPC}

uses
  Classes, Windows;

function PrintLine(const AString: PAnsiChar): HRESULT; stdcall;
begin
  WriteLn('Sleeping');
  Sleep(100);
  WriteLn(AString);
  Result := S_OK;
end;

exports
  PrintLine;
begin
end.

