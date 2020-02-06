library victim;

{$IFDEF FPC}
{$mode objfpc}{$H+}
{$ENDIF FPC}

uses
  Classes
{$IFDEF MSWINDOWS}
  , Windows
{$ENDIF}
  ;

type
  TExClass = class
  private
    FField: Integer;
  public
    property Field: Integer read FField write FField;
  end;

function PrintLine(const AString: PAnsiChar; ASleep: DWORD): HRESULT; stdcall;
{$IFNDEF MSWINDOWS}
var
  E: TExClass;
{$ENDIF !MSWINDOWS}
begin
{$IFNDEF MSWINDOWS}
  E := nil;
{$ENDIF !MSWINDOWS}
  WriteLn('Sleeping ', ASleep, ' milliseconds');
{$IFDEF MSWINDOWS}
  Sleep(ASleep);
{$ELSE MSWINDOWS}
  E.Field := $123;
{$ENDIF}
  WriteLn(AString);
  Result := S_OK;
end;

exports
  PrintLine;
begin
end.

