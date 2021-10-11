 {$A-,H-}
 {$ALIGN OFF}
 {$MINENUMSIZE 4}
 unit unrars;
 interface
 uses Windows;
 const
   ERAR_END_ARCHIVE    = 10;
   ERAR_NO_MEMORY      = 11;
   ERAR_BAD_DATA       = 12;
   ERAR_BAD_ARCHIVE    = 13;
   ERAR_UNKNOWN_FORMAT = 14;
   ERAR_EOPEN          = 15;
   ERAR_ECREATE        = 16;
   ERAR_ECLOSE         = 17;
   ERAR_EREAD          = 18;
   ERAR_EWRITE         = 19;
   ERAR_SMALL_BUF      = 20;
 
   RAR_OM_LIST         =  0;
   RAR_OM_EXTRACT      =  1;
 
   RAR_SKIP            =  0;
   RAR_TEST            =  1;
   RAR_EXTRACT         =  2;
 
   RAR_VOL_ASK         =  0;
   RAR_VOL_NOTIFY      =  1;
 
 type
   RARHeaderData=record
     ArcName  :array [0..259] of char;
     FileName :array [0..259] of char;
     Flags,
     PackSize,
     UnpSize,
     HostOS,
     FileCRC,
     FileTime,
     UnpVer,
     Method,
     FileAttr: UINT;
     CmtBuf:PChar;
     CmtBufSize,
     CmtSize,
     CmtState: UINT;
   end;

   RAROpenArchiveData=record
     ArcName   :PChar;
     OpenMode  :UINT;
     OpenResult:UINT ;
     CmtBuf    :PChar;
     CmtBufSize:UINT;
     CmtSize   :UINT;
     CmtState  :UINT;
   end;

   TChangeVolProc  =function(ArcName:PChar;Mode:integer):integer cdecl export;
   TProcessDataProc=function(Addr:PUCHAR;Size:integer):integer cdecl export;

 function RAROpenArchive(var ArchiveDate:RAROpenArchiveData):THandle;
          stdcall; external 'Pack.DLL';

 function RARCloseArchive(hArcData : THandle):integer;
          stdcall; external 'Pack.dll';

 function RARReadHeader(hArcData:THandle;var HeaderData:RARHeaderData):integer;
          stdcall; external 'Pack.dll';

 function RARProcessFile(hArcData:THandle;Operation:integer;DestPath,DestName:PChar):integer;
          stdcall; external 'Pack.dll';

 procedure RARSetChangeVolProc(hArcData:THandle;ChangeVolProc:TChangeVolProc);
           stdcall; external 'Pack.dll';

 procedure RARSetProcessDataProc(hArcData:THandle;ProcessDataProc:TProcessDataProc);
           stdcall; external 'Pack.dll';

 procedure RARSetPassword(hArcData:THandle;Password:PChar);
           stdcall; external 'Pack.dll';

 implementation

 end.

