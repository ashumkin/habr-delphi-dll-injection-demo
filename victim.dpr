library victim;

{$IFDEF FPC}
{$mode objfpc}{$H+}
{$ENDIF FPC}

uses
  Classes
{$IFDEF MSWINDOWS}
  , Windows
{$ELSE MSWINDOWS}
  , SysUtils
{$ENDIF}
  ;

function PrintLine(const AString: PAnsiChar; ASleep: DWORD): HRESULT; stdcall;
begin
  WriteLn('Sleeping ', ASleep, ' milliseconds');
  Sleep(ASleep);
  WriteLn(AString);
  Result := S_OK;
end;

exports
{$IFDEF MSWINDOWS}
  PrintLine name 'PrintLine@8',
{$ENDIF MSWINDOWS}
  PrintLine;
begin
end.

