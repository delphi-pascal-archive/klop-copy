unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Gauges,clipbrd,shellapi, ExtCtrls,mmsystem;

type
  TForm1 = class(TForm)
    ListBox1: TListBox;
    SpeedButton1: TSpeedButton;
    Gauge1: TGauge;
    Gauge2: TGauge;
    Label1: TLabel;
    Label2: TLabel;
    OpenDialog1: TOpenDialog;
    Label4: TLabel;
    Edit1: TEdit;
    CheckBox1: TCheckBox;
    Label5: TLabel;
    Bevel1: TBevel;
    Gauge3: TGauge;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    Timer1: TTimer;
    Bevel2: TBevel;
    Bevel3: TBevel;
    CheckBox2: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

klopik = class (TThread)
procedure Execute; override;
end;

var klop:klopik; //Поток копирования
F1,F2: file;
kill:boolean; //Метка выхода из потока
go:shortint;    //Для раскрытия - закрытия настроек.
mode:boolean;//Режим копирования true-дозапись
ToPath,from,clip:string;
curcrc:int64;
Form1: TForm1;

implementation

uses Unit2, Unit3;

{$R *.dfm}

var
 CRCtable: array[0..255] of cardinal;

/////////////////////////////////////////////CRC
function GetNewCRC(OldCRC: cardinal; StPtr: pointer; StLen: integer): cardinal;
asm
test edx,edx;
jz @ret;
neg ecx;
jz @ret;
sub edx,ecx; // Address after last element
push ebx;
mov ebx,0; // Set ebx=0 & align @next
@next:
mov bl,al;
xor bl,byte [edx+ecx];
shr eax,8;
xor eax,cardinal [CRCtable+ebx*4];
inc ecx;
jnz @next;
pop ebx;
@ret:
end;

function GetFileCRC(const FileName: string;max:int64): cardinal;
const
BufSize = 64 * 1024;
var
Fi: file;
pBuf: PChar;
Count: integer;
begin
Assign(Fi, FileName);
Reset(Fi, 1);
GetMem(pBuf, BufSize);
Result := $FFFFFFFF;
repeat
if kill=true then
exit;
BlockRead(Fi, pBuf^, BufSize, Count);
curcrc:=curcrc+count;
form1.Gauge3.Progress:=(100*curcrc) div max;
if Count = 0 then
break;
Result := GetNewCRC(Result, pBuf, Count);
until false;
Result := not Result;
FreeMem(pBuf);
CloseFile(Fi);
end;
///////////////////////////////////////////////// end CRC

///////////
function klopCRC(file1:string;file2:string;max:int64):boolean;
begin
if GetFileCRC(file1,max)=GetFileCRC(file2,max) then
result:=true else
result:=false;
end;
////////////////Конец официальной проверки контрольной суммы

procedure GetFile(path: string);
var
  sr: TSearchRec;
begin
if FindFirst(path + '\*.*', faAnyFile, sr) = 0 then
begin
repeat
if sr.Attr and faDirectory = 0 then
begin
Form1.ListBox1.Items.Add(path + '\' + sr.name);
end
else
begin
if pos('.', sr.name) <= 0 then
GetFile(path + '\' + sr.name);
end;
until
FindNext(sr) <> 0;
end;
FindClose(sr);
end;

function klopFilesize(Ss:string):int64;
var ts:tsearchrec;
begin
FindFirst(ss, faAnyFile, ts);
result:=ts.FindData.nFileSizeHigh*4294967296+ts.FindData.nFileSizeLow;
end;

procedure getbuffer;
var
f: THandle;
buffer: array [0..MAX_PATH] of Char;
i, numFiles: Integer;
begin
if not Clipboard.HasFormat(CF_HDROP) then Exit;
Clipboard.Open;
try
f := Clipboard.GetAsHandle(CF_HDROP);
if f <> 0 then begin
numFiles := DragQueryFile(f, $FFFFFFFF, nil, 0);
form1.listbox1.Clear;
for i := 0 to numfiles - 1 do begin
buffer[0] := #0;
DragQueryFile(f, i, buffer, SizeOf(buffer));
if clip='' then
clip:= extractfilepath(buffer);
if fileexists(buffer) then
form1.listbox1.Items.Add(buffer) else
GetFile(buffer);
end;
end;
finally
Clipboard.Close;
end;
end;

Function getpath(fromP:string):string;
begin
Result:=topath+copy(fromP,length(clip),length(fromP));//-lp-length(fn)
end;

///////////////Копирование
Procedure klopik.execute;
var
i,lp:integer;
NumRead,NumWritten: longint;
Buf: pointer;
BufSize,TotalRead,allfiles: int64;
Totalbytes,mainttl:int64;
SS,topath1,fn:string;
begin
inherited;
allfiles:=0;
mainttl:=0;
lp:=length(Clip);
Form1.Label2.Caption:='Копирование...';
for i:=0 to form1.ListBox1.Items.Count-1 do              //Определение общего
allfiles:=allfiles+klopFilesize(form1.listbox1.Items[i]);// размера
for i:=0 to form1.ListBox1.Items.Count-1 do begin
from:=form1.listbox1.Items[i];
fn:=extractfilename(from);
ss:=copy(from,length(clip),length(from)-lp-length(fn));
ForceDirectories(topath+ss);
ToPath1:=ToPath+'\'+ss+'\'+fn;
form1.Label1.Caption:= ToPath1;
Assignfile(f1, From);
Assignfile(F2, ToPath1);
reset(F1, 1);
TotalBytes := klopFilesize(From);

//Дозапись
if mode=true then
if fileexists(ToPath1) then begin
Reset(F2, 1);
TotalRead := klopfilesize(ToPath1);  //Уже записанный файл
seek(f2,totalread);
seek(f1,totalread);
mainttl:=mainttl+TotalRead;

end;
//Простое копирнование
if (mode=false) or (fileexists(ToPath1)=false) then begin
Rewrite(F2, 1);
TotalRead := 0;
end;

BufSize := strtoint(form1.Edit1.Text);
GetMem(buf, BufSize);

repeat
if kill=true then
exit;
BlockRead(F1, Buf^, BufSize, NumRead);
inc(TotalRead, NumRead);
BlockWrite(F2, Buf^, NumRead, NumWritten);
form1.Gauge1.Progress:=(100*TotalRead) div TotalBytes;
mainttl:=mainttl+numwritten;
form1.Gauge2.Progress:=(100*mainttl) div allfiles;
until (NumRead = 0) or (NumWritten <> NumRead);
if (NumWritten <> NumRead) then begin
//Надо чтото сделать с ошибкой
//Но надеюсь ошибок не будет, т.к. сервер работает постоянно)))
end;
Closefile(f1);
Closefile(f2);
form1.Gauge1.Progress:=0;
end;

form1.Gauge2.Progress:=0;
form1.Label1.Caption:='klopCopy!!!';
//Проверка контрольных сумм
if form1.checkbox1.Checked then begin
klop.Synchronize(unit3.Form3.Show);
form3.Close;

Form1.Label2.Caption:='Проверка контрольных сумм...';
curcrc:=0;
for i:=0 to form1.ListBox1.Items.Count-1 do begin
if kill=true then
exit;
if klopCRC(form1.listbox1.Items[i],getpath(form1.listbox1.Items[i]),allfiles*2)
=false then
form3.ListBox1.Items.Add(getpath(form1.listbox1.Items[i]));

end;

end;
Form1.Label2.Caption:='Копировние завершено';
if form1.CheckBox2.Checked then
PlaySound(pchar(extractfilepath(paramstr(0))+'\ready.wav'), 0, SND_SYNC);

if form3.ListBox1.Items.Count>0 then begin
form3.Show;
end else begin

TerminateProcess(GetCurrentProcess, 0);
//klop.Terminate;
//klop.Free;
end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var ff:textfile;
sss:string;
i:integer;
begin
Application.CreateForm(TForm2, Form2);
Application.CreateForm(TForm3, Form3);
//Загрузка настроек
assignfile(ff,extractfilepath(paramstr(0))+'\set.ini');
reset(ff);
readln(ff,sss);
edit1.text:=sss;
readln(ff,sss);
if sss='1' then
checkbox1.Checked:=true else
checkbox1.Checked:=false;
readln(ff,sss);
if sss='1' then
checkbox2.Checked:=true else
checkbox2.Checked:=false;
closefile(ff);

form1.Height:=140;
clip:='';
kill:=false;
getbuffer;
if listbox1.Items.Count=0 then begin
application.Terminate;
exit;
end;
//ToPath:='d:\test';
ToPath:=paramstr(1);
//Проверка совпадений
For i:=0 to listbox1.Items.Count-1 do
if fileexists(getpath(listbox1.Items[i])) then
form2.ListBox1.Items.Add(getpath(listbox1.Items[i]));
if form2.ListBox1.Items.Count>0 then
form2.Show
else begin
//Копирование
Mode:=false;
klop:=klopik.Create(false);
klop.Resume;
end;

end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
if klop.Suspended then
klop.Resume else
klop.Suspend;
Exit;
end;

procedure TForm1.SpeedButton3Click(Sender: TObject);
begin
kill:=true;
if klop.Suspended then
klop.Resume;
//klop.Priority:=tpIdle;
klop.Free;
//klop.Terminate;
//klop.Destroy;
{$i-}
closefile(f2);
closefile(f1);
{$i+}
deletefile(label1.Caption);
application.Terminate;
close;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
go:=1;
timer1.Enabled:=true;
speedbutton2.Enabled:=false;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
form1.Height:=form1.Height+go;
if form1.Height=140 then
timer1.Enabled:=false else
if form1.Height=190 then
timer1.Enabled:=false;

end;

procedure TForm1.SpeedButton4Click(Sender: TObject);
var ff:textfile;
begin
//Сххранение в файл
assignfile(ff,extractfilepath(paramstr(0))+'\set.ini');
rewrite(ff);
writeln(ff,edit1.text);
if checkbox1.Checked=true then
writeln(ff,'1') else
writeln(ff,'0');
if checkbox2.Checked=true then
writeln(ff,'1') else
writeln(ff,'0');

closefile(ff);
go:=-1;
timer1.Enabled:=true;
speedbutton2.Enabled:=true;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
canclose:=false;
end;

procedure CRCInit;
var
c: cardinal;
i, j: integer;
begin
for i := 0 to 255 do begin
c := i;
for j := 1 to 8 do
if odd(c) then
c := (c shr 1) xor $EDB88320
else
c := (c shr 1);
CRCtable[i] := c;
end;
end;

initialization
  CRCinit;
end.
