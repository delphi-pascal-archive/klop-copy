unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms,
  StdCtrls,registry;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
    BatchFile: TextFile;
    BatchFileName : string;
    TM : Cardinal;
    TempMem : PChar;
  Form1: TForm1;

implementation

{$R *.dfm}

Procedure addmenu(name:string;path:string;p:boolean);
var hr:tregistry;
begin
//Папки
hr:=tregistry.Create;
hr.RootKey:= HKEY_CLASSES_ROOT;
 //
if p then begin
hr.OpenKey('Directory\shell',true);
hr.CreateKey(name);
hr.CloseKey;
//
hr.OpenKey('Directory\shell\'+name+'\command',true);
hr.WriteString('',path+' "%1"');
hr.CloseKey;
end else begin
hr.DeleteKey('Directory\shell\'+name);
hr.CloseKey;
end;

// Диски
if p then begin
hr.OpenKey('Drive\shell',true);
hr.CreateKey(name);
hr.CloseKey;
//
hr.OpenKey('Drive\shell\'+name+'\command',true);
hr.WriteString('',path+' "%1"');
hr.CloseKey;
end else begin
hr.DeleteKey('Drive\shell\'+name);
hr.CloseKey;
end;

hr.Free;
end;

function StrAnsiToOem(const S: AnsiString): AnsiString;
begin
  SetLength(Result, Length(S));
  AnsiToOemBuff(@S[1], @Result[1], Length(S));
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
Close;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
addmenu('klopCopy',paramstr(0),false);

deletefile(extractfilepath(paramstr(0))+'\klopCopy.exe');
deletefile(extractfilepath(paramstr(0))+'\set.ini');
deletefile(extractfilepath(paramstr(0))+'\Ready.wav');

BatchFileName:=ExtractFilePath(ParamStr(0))+ '$$336699.bat';

AssignFile(BatchFile, BatchFileName);
Rewrite(BatchFile);
Writeln(BatchFile,':try');
Writeln(BatchFile,'del "' + StrAnsiToOem(ParamStr(0)) + '"');
Writeln(BatchFile,'if exist "' + StrAnsiToOem(ParamStr(0)) + '" goto try');
Writeln(BatchFile,'del "' + StrAnsiToOem(BatchFileName) + '"');
writeln(BatchFile,'rd "' + StrAnsiToOem(copy(ExtractFilePath(ParamStr(0)),0,
length(extractfilepath(paramstr(0)))-1)) + '"');
CloseFile(BatchFile);

TM:=70;
GetMem (TempMem,TM);
GetShortPathName (pchar(BatchFileName), TempMem, TM);
BatchFileName:=TempMem;
FreeMem(TempMem);
winexec(Pchar('cmd.exe /c ' + BatchFileName),sw_hide);
    //winexec(Pchar(BatchFileName),sw_hide);
halt;

end;

end.
