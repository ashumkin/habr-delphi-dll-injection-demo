library injector;

{$IFDEF FPC}
{$mode objfpc}{$H+}
{$ENDIF FPC}

uses
  Windows, StrUtils, SysUtils;

type
  PImageThunkData = ^TImageThunkData;
  _IMAGE_THUNK_DATA = packed record
    case byte of
      0: (ForwarderString: PByte);
      1: (FFunction: Pointer);
      2: (Ordinal: DWORD);
      3: (AddressOfData: Pointer)
  end;
  IMAGE_THUNK_DATA = _IMAGE_THUNK_DATA;
  PIMAGE_THUNK_DATA = ^IMAGE_THUNK_DATA;
  TImageThunkData = _IMAGE_THUNK_DATA;

  PImageImportDescriptor = ^TImageImportDescriptor;
  _IMAGE_IMPORT_DESCRIPTOR = packed record
    OriginalFirstThunk: DWord; // = DWORD
    TimeDateStamp: DWORD;
    ForwarderChain: DWORD;
    Name: DWORD;
    FirstThunk: DWord;
  end;
  IMAGE_IMPORT_DESCRIPTOR = _IMAGE_IMPORT_DESCRIPTOR;
  PIMAGE_IMPORT_DESCRIPTOR = ^IMAGE_IMPORT_DESCRIPTOR;
  TImageImportDescriptor = _IMAGE_IMPORT_DESCRIPTOR;

  ESleepException = class(Exception);

function ImageDirectoryEntryToData(Base: Pointer; MappedAsImage: Boolean;
  DirectoryEntry: Word; var Size: NativeUInt): Pointer; stdcall; external 'imagehlp.dll';

procedure NewSleep(dwMilliseconds:DWORD); stdcall;
var
  LCrashPointer: PInteger;
begin
  WriteLn('New sleep instead of ', dwMilliseconds);
  if dwMilliseconds = 5 then
  begin
    WriteLn('Now we crash');
    LCrashPointer := nil;
    LCrashPointer^ := 0;
  end;
end;

function Inject: Boolean;
var
  LVictim: HINST;
  iid: PImageImportDescriptor;
  LSize: NativeUInt;
  S: PAnsiChar;
  Thunk: PImageThunkData;
  LSleepAddress: Pointer;
  Op: DWORD;
  NewSleepPointer: Pointer;
begin
  LVictim := LoadLibrary('victim.dll');
  if LVictim = 0 then
    Exit(False);
  Result := False;
  LSleepAddress := GetProcAddress(GetModuleHandle('kernel32'), 'Sleep');
  iid := ImageDirectoryEntryToData(Pointer(LVictim), True, IMAGE_DIRECTORY_ENTRY_IMPORT, LSize);
  // Пробегаем по всем элементам таблицы и ищем нашу функцию
  WriteLn('Searching...');
  while iid^.Name <> 0 do
  begin
    // Получаем имя модуля для элемента таблицы импорта
    S := PAnsiChar(Int64(LVictim) + iid^.Name);
    WriteLn(S);
    // Если имя модуля совпадает с требуемым, то продолжаем проверку элемента
    if S = 'kernel32.dll' then
    begin
      Thunk := PImageThunkData(Int64(LVictim) + iid^.FirstThunk);

      // Если адрес метода указан, то проверяем его на соответствие адресу искомого метода
      while Thunk^.FFunction <> nil do
      begin
        // Если это точка входа в искомый метод
        if (Thunk^.FFunction = LSleepAddress) then
        begin
          // Устанавливаем переход на нашу функцию
          // Запоминаем оригинальное значение адреса
          // Снимаем защиту от записи
          VirtualProtect(Thunk, SizeOf(Pointer), PAGE_READWRITE, Op);
          // Записываем адрес нашей функции в таблицу переходов
          NewSleepPointer := @NewSleep;
          WriteProcessMemory(GetCurrentProcess, Thunk, @NewSleepPointer, SizeOf(Pointer), LSize);
          // Возвращаем защиту от записи
          VirtualProtect(Thunk, SizeOf(Pointer), Op, Op);
          Result := True;
        end;
        // Переходим к следующему элементу таблицы импорта
        Inc(PAnsiChar(Thunk), SizeOf(TImageThunkData));
      end;
    end;
    // Переходим к следующей таблице импорта
    iid := PImageImportDescriptor(Int64(iid) + SizeOf(TImageImportDescriptor));
  end;
end;

function TryToInject: BOOL; stdcall;
begin
  Result := Inject;
  if Result then
    WriteLn('Injected');
end;

exports TryToInject;
begin
end.

