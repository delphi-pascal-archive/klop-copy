unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,unrars, StdCtrls, Gauges, ExtCtrls, Buttons, FileCtrl, registry;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Label1: TLabel;
    Button1: TButton;
    Bevel1: TBevel;
    Gauge1: TGauge;
    DriveCB: TDriveComboBox;
    Bevel2: TBevel;
    DIRLB: TDirectoryListBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    ListBox1: TListBox;
    Bevel3: TBevel;
    Button2: TButton;
    Timer1: TTimer;
    Button3: TButton;
    Timer2: TTimer;
    Label2: TLabel;
    Bevel4: TBevel;
    Image1: TImage;
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure DriveCBChange(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
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

function GetProgramFilesDir: string;
var
reg: TRegistry;
begin
reg := TRegistry.Create;
try
reg.RootKey := HKEY_LOCAL_MACHINE;
reg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion', False);
Result := reg.ReadString('ProgramFilesDir');
finally
reg.Free;
end;
end;


procedure unrarss(ArcName,path:Pchar);
var
st1:string;
OperBegin, OperEnd: TTimeStamp;
Total: LongWord;
hArcData:THandle;
RHCode,PFCode :integer;
CmtBuf:array [0..16384] of char;
HeaderData: RARHeaderData;
OpenArchiveData: RAROpenArchiveData;
begin
if not fileexists(ArcName) then begin
ShowMessage ('Нет Файла '+ArcName);
Exit;
end;
OpenArchiveData.ArcName:=ArcName;
OpenArchiveData.CmtBuf:=CmtBuf;
OpenArchiveData.CmtBufSize:=sizeof(CmtBuf);
OpenArchiveData.OpenMode:=RAR_OM_EXTRACT;
hArcData:=RAROpenArchive(OpenArchiveData);
OperBegin:=DateTimeToTimeStamp(Now);
RHCode := 0;
while (RHCode = 0) do begin
PFCode:=RARProcessFile(hArcData,RAR_EXTRACT,path,nil);
RHCode:=RARReadHeader(hArcData,HeaderData);

form1.Gauge1.Progress:=form1.Gauge1.Progress+20;
Form1.Listbox1.Items.Add(HeaderData.FileName);
Form1.ListBox1.ItemIndex:=Form1.ListBox1.Items.Count-1;

OperEnd:=DateTimeToTimeStamp(Now);
Total := OperEnd.Time - OperBegin.Time;
if Total=0 then Total:=1;
Application.ProcessMessages;
end;
form1.listbox1.Items.Delete(form1.ListBox1.Items.Count-1);
Str(RHCode,st1);
if RhCode<>10 then ShowMessage('Ошибка распаковки Код:'+St1+#10+#13+'Файл:'+ArcName);
RARCloseArchive(hArcData);
end;

procedure TForm1.Button2Click(Sender: TObject);
Var reg:tregistry;
begin
Edit1.Visible:=false;
button1.Visible:=false;
Label1.Caption:='Прогресс установки:';
ListBox1.Clear;
unrarss(pchar(Extractfilepath(paramstr(0))+'Data.dat'),pchar(edit1.Text+'\klopCopy'));
Listbox1.Items.Add('Запись значений в реестр.');
//////////////////Контекстное меню
addmenu('klopCopy',edit1.Text+'\klopCopy\klopCopy.exe',true);

form1.Gauge1.Progress:=form1.Gauge1.Progress+20;

Listbox1.Items.Add('Установка завершена!');
gauge1.Progress:=100;
Showmessage('Установка завершена!');
Close;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
edit1.Text:=GetProgramFilesDir;
form1.Width:=408;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
If form1.Width<=640 then begin
form1.Width:=form1.Width+2;
form1.Left:=form1.Left-1;
end else timer1.Enabled:=false;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
timer1.Enabled:=true;
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
begin
timer2.Enabled:=true;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
If form1.Width>=411 then begin
form1.Width:=form1.Width-2;
form1.Left:=form1.Left+1;
end else timer2.Enabled:=false;
end;

procedure TForm1.DriveCBChange(Sender: TObject);
begin
dirlb.Drive:=drivecb.Drive;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
timer2.Enabled:=true;
edit1.Text:=DirLb.Directory;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
close;
end;

end.
