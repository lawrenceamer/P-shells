program Project1;
//credits by : Lawrence Amer  
{$APPTYPE CONSOLE}

uses
  SysUtils,windows,WinSvc;
  const
  SERVICE_KERNEL_DRIVER       = $00000001;
  SERVICE_FILE_SYSTEM_DRIVER  = $00000002;
  SERVICE_ADAPTER             = $00000004;
  SERVICE_RECOGNIZER_DRIVER   = $00000008;

  SERVICE_DRIVER              =
    (SERVICE_KERNEL_DRIVER or
     SERVICE_FILE_SYSTEM_DRIVER or
     SERVICE_RECOGNIZER_DRIVER);

  SERVICE_WIN32_OWN_PROCESS   = $00000010;
  SERVICE_WIN32_SHARE_PROCESS = $00000020;
  SERVICE_WIN32               =
    (SERVICE_WIN32_OWN_PROCESS or
     SERVICE_WIN32_SHARE_PROCESS);

  SERVICE_INTERACTIVE_PROCESS = $00000100;

  SERVICE_TYPE_ALL            =
    (SERVICE_WIN32 or
     SERVICE_ADAPTER or
     SERVICE_DRIVER  or
     SERVICE_INTERACTIVE_PROCESS);
 var
  hLib : Cardinal;

type
  PENUM_SERVICE_STATUS = ^ENUM_SERVICE_STATUS;
  ENUM_SERVICE_STATUS =
    packed record
      lpServiceName : pchar;
      lpDisplayName : pansichar;
      ServiceStatus : SERVICE_STATUS;
    end;

type
  TcsEnumServicesStatus = function(
    const hSCManager         : DWord;                // handle to SCM database
    const dwServiceType      : DWord;                // service type
    const dwServiceState     : DWord;                // service state
    const lpServices         : PENUM_SERVICE_STATUS; // status buffer
    const cbBufSize          : DWord;                // size of status buffer
    const pcbBytesNeeded     : PDWORD;               // buffer size needed
    const lpServicesReturned : PDWord;               // number of entries returned
    const lpResumeHandle     : PDWord                // next entry
    ) : Boolean; stdcall;


  TcsOpenSCManager = function(
    const lpMachineName   : PChar;
    const lpDatabaseName  : PChar;
    const dwDesiredAccess : DWord
    ) : DWord; stdcall;


var
  EnumServicesStatus    : TcsEnumServicesStatus;
  OpenSCManager         : TcsOpenSCManager;

  procedure enumservices;
  var
  hSC: Cardinal;
  pStatus            : PENUM_SERVICE_STATUS;
  pWork              : PENUM_SERVICE_STATUS;
  cbBufSize          : DWord;
  pcbBytesNeeded     : DWord;
  lpServicesReturned : DWord;
  lpResumeHandle     : DWord;
  i                  : integer;
  s                  : ansistring;
  name :ansistring ;
begin
  //hSC := OpenSCManager(nil, nil, SC_MANAGER_ENUMERATE_SERVICE);
  hSc := OpenSCManager(nil,nil,
  SC_MANAGER_ENUMERATE_SERVICE);
  if hSC <> 0 then
  begin
    try
      cbBufSize      := 0;
      pStatus        := nil;
      lpResumeHandle := 0;
      EnumServicesStatus(hSC,SERVICE_WIN32,SERVICE_STATE_ALL,pStatus,
        cbBufSize,@pcbBytesNeeded,@lpServicesReturned,@lpResumeHandle);
      pStatus := AllocMem(pcbBytesNeeded);
      try
        cbBufSize := pcbBytesNeeded;
        EnumServicesStatus(hSC,SERVICE_WIN32,SERVICE_STATE_ALL,pStatus,
          cbBufSize,@pcbBytesNeeded,@lpServicesReturned,@lpResumeHandle);
        pWork := pStatus;
        for i := 1 to lpServicesReturned do
        begin
          s := pWork.lpDisplayName;
          case pWork.ServiceStatus.dwCurrentState of
            SERVICE_CONTINUE_PENDING : s := s+' (to be continued';
            SERVICE_PAUSED : s := s+' (pause';
            SERVICE_RUNNING: s := s+' (started';
            SERVICE_START_PENDING: s := s+' (is started';
            SERVICE_STOP_PENDING: s := s+' (is stopped';
            SERVICE_STOPPED: s := s+' (stopped';
          end;
          case pWork.ServiceStatus.dwServiceType of
            SERVICE_FILE_SYSTEM_DRIVER : s := s+', file driver)';
            SERVICE_KERNEL_DRIVER      : s := s+', Kernel Driver)';
            SERVICE_WIN32_OWN_PROCESS  : s := s+', own process)';
            SERVICE_WIN32_SHARE_PROCESS: s := s+', shares process)'
          else
            s := s+')';

          end;
          Writeln(s + name);
          readln(name);
          inc(pWork);
        end;
      finally
        if Assigned(pStatus) then
        begin
          FreeMem(pStatus,pcbBytesNeeded);
        end;
      end;
    finally
      CloseServiceHandle(hSC);
    end;
  end
  else
    RaiselastOSError();
end;

//initialization
begin
  hLib := LoadLibrary('ADVAPI32.DLL');
  if hLib <> 0 then
  begin
    @EnumServicesStatus := GetProcAddress(hLib,'EnumServicesStatusA');
    if @EnumServicesStatus = nil then raise Exception.Create('EnumServicesStatusA');
    @OpenSCManager := GetProcAddress(hLib,'OpenSCManagerA');
    if @OpenSCManager = nil then raise Exception.Create('OpenSCManagerA');
  end;
//end;

//finalization
begin
  if hLib <> 0 then
  begin
    FreeLibrary(hLib);
  end;
end;
begin
  try
    enumservices;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end;
end.
