program DLLInjectionDemo;

{$IFDEF FPC}
{$mode objfpc}{$H+}
{$ENDIF FPC}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, Windows, CustApp
{$IFNDEF FPC}
  , System.Generics.Collections
{$ENDIF !FPC}
  ;

type

  { TDLLInjectionDemo }

  TDLLInjectionDemo = class(TCustomApplication)
  private
    procedure CrashOnException(Sender : TObject; E : Exception);
  protected
    procedure HandleException(Sender: TObject); override;
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

{ TDLLInjectionDemo }

function PrintLine(const AString: PAnsiChar; ASleep: DWORD): HRESULT; stdcall; external 'victim.dll';
type
  TTryToInjectProc = function: Boolean; stdcall;

procedure TDLLInjectionDemo.CrashOnException(Sender: TObject; E: Exception);
begin
  raise E;
end;

procedure TDLLInjectionDemo.HandleException(Sender: TObject);
var
  LExceptObject: TObject;
begin
  LExceptObject := ExceptObject;
  raise Exception(LExceptObject);
end;

procedure TDLLInjectionDemo.DoRun;
var
  LLibraries: TStringArray;
  LLibrary: string;
  LLib: HMODULE;
  LTryToInjectProc: Pointer;
  LTimeout: Integer;
  LTempTimeout: Integer;
begin
  // parse parameters
  if HasOption('h', 'help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  LLibraries := GetNonOptions('hi', ['help', 'interactive']);
  LTimeout := 100;
  for LLibrary in LLibraries do
  begin
    if TryStrToInt(LLibrary, LTempTimeout) then
    begin
      LTimeout := LTempTimeout;
      WriteLn('Setting timeout ', LTimeout);
      Continue;
    end;
    WriteLn('Loading ', LLibrary);
    LLib := LoadLibrary(PChar(LLibrary));
    if LLib > 0 then
    begin
      LTryToInjectProc := GetProcAddress(LLib, 'TryToInject');
      if @LTryToInjectProc <> nil then
        TTryToInjectProc(LTryToInjectProc)();
    end;
  end;

  PrintLine('Any string printed', DWORD(LTimeout));

  if HasOption('i', 'interactive') then
  begin
    WriteLn('Press ENTER');
    ReadLn;
  end;
  // stop program loop
  Terminate;
end;

constructor TDLLInjectionDemo.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
  OnException := CrashOnException;
end;

destructor TDLLInjectionDemo.Destroy;
begin
  inherited Destroy;
end;

procedure TDLLInjectionDemo.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ', ExeName, ' -h');
end;

var
  Application: TDLLInjectionDemo;
begin
  Application:=TDLLInjectionDemo.Create(nil);
  Application.Title:='DLL injection demo';
  Application.Run;
  Application.Free;
end.

