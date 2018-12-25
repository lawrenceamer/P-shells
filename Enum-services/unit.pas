//Credit: Michael Puff

uses
  WinSvc;

var
  hLib : Cardinal;

type
  PENUM_SERVICE_STATUS = ^ENUM_SERVICE_STATUS;
  ENUM_SERVICE_STATUS =
    packed record
      lpServiceName : PChar;
      lpDisplayName : PChar;
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

procedure TForm1.Button1Click(Sender: TObject);
var
  hSC: Cardinal;
  pStatus            : PENUM_SERVICE_STATUS;
  pWork              : PENUM_SERVICE_STATUS;
  cbBufSize          : DWord;
  pcbBytesNeeded     : DWord;
  lpServicesReturned : DWord;
  lpResumeHandle     : DWord;
  i                  : integer;
  s                  : String;
begin
  hSC := OpenSCManager(nil, nil, SC_MANAGER_ENUMERATE_SERVICE);
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
            SERVICE_CONTINUE_PENDING : s := s+' (wird fortgesetzt';
            SERVICE_PAUSED : s := s+' (pausiert';
            SERVICE_RUNNING: s := s+' (gestartet';
            SERVICE_START_PENDING: s := s+' (wird gestartet';
            SERVICE_STOP_PENDING: s := s+' (wird gestoppt';
            SERVICE_STOPPED: s := s+' (gestoppt';
          end;
          case pWork.ServiceStatus.dwServiceType of
            SERVICE_FILE_SYSTEM_DRIVER : s := s+', Dateitreiber)';
            SERVICE_KERNEL_DRIVER      : s := s+', GerÃ¤tetreiber)';
            SERVICE_WIN32_OWN_PROCESS  : s := s+', eigener Prozess)';
            SERVICE_WIN32_SHARE_PROCESS: s := s+', teilt Prozess)'
          else
            s := s+')';
          end;
          Memo1.Lines.Add(s);
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

initialization
begin
  hLib := LoadLibrary('ADVAPI32.DLL');
  if hLib <> 0 then
  begin
    @EnumServicesStatus := GetProcAddress(hLib,'EnumServicesStatusA');
    if @EnumServicesStatus = nil then raise Exception.Create('EnumServicesStatusA');
    @OpenSCManager := GetProcAddress(hLib,'OpenSCManagerA');
    if @OpenSCManager = nil then raise Exception.Create('OpenSCManagerA');
  end;
end;

finalization
begin
  if hLib <> 0 then
  begin
    FreeLibrary(hLib);
  end;
end;
