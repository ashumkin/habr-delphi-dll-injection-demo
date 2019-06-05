program DLLInjectionDemo;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, Windows, CustApp
  { you can add units after this };

type

  { TDLLInjectionDemo }

  TDLLInjectionDemo = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

{ TDLLInjectionDemo }

function PrintLine(const AString: PAnsiChar): HRESULT; stdcall; external 'victim.dll';
type
  TTryToInjectProc = function: Boolean; stdcall;

procedure TDLLInjectionDemo.DoRun;
var
  LLibraries: TStringArray;
  LLibrary: string;
  LLib: HMODULE;
  LTryToInjectProc: Pointer;
begin
  // parse parameters
  if HasOption('h', 'help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  LLibraries := GetNonOptions('hi', ['help', 'interactive']);
  for LLibrary in LLibraries do
  begin
    WriteLn('Loading ', LLibrary);
    LLib := SafeLoadLibrary(LLibrary);
    if LLib > 0 then
    begin
      LTryToInjectProc := GetProcAddress(LLib, 'TryToInject');
      if @LTryToInjectProc <> nil then
        TTryToInjectProc(LTryToInjectProc)();
    end;
  end;

  PrintLine('Any string printed');

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

