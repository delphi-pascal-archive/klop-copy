unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons;

type
  TForm2 = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    SpeedButton1: TSpeedButton;
    ListBox1: TListBox;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    Bevel1: TBevel;
    Label2: TLabel;
    Label3: TLabel;
    Bevel2: TBevel;
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses Unit1;

{$R *.dfm}

function GetFileDate(FileName: string): string;
var FHandle: Integer;
begin
FHandle := FileOpen(FileName, 0);
try
Result := DateTimeToStr(FileDateToDateTime(FileGetDate(FHandle)));
finally
FileClose(FHandle);
end;
end;


Function getSourceFile(ToP:string):string;
var i:integer;
begin
for i:=0 to form1.ListBox1.Items.Count-1 do
if copy(form1.ListBox1.Items[i],length(Clip),length(form1.ListBox1.Items[i]))=
copy(ToP,length(topath)+1,length(ToP)) then begin
result:=form1.ListBox1.Items[i];
exit;
end;
end;

function klopFilesize(Ss:string):int64;
var ts:tsearchrec;
begin
FindFirst(ss, faAnyFile, ts);
result:=ts.FindData.nFileSizeHigh*4294967296+ts.FindData.nFileSizeLow;
end;

procedure TForm2.SpeedButton4Click(Sender: TObject);
begin
application.Terminate;
end;

procedure TForm2.SpeedButton1Click(Sender: TObject);
begin
mode:=false;
klop:=klopik.Create(false);
klop.Resume;
form2.Hide;
form1.Show;
Exit;
end;

procedure TForm2.SpeedButton3Click(Sender: TObject);
begin
mode:=true;
klop:=klopik.Create(false);
klop.Resume;
form1.Show;
form2.Hide;
Exit;
end;

procedure TForm2.ListBox1Click(Sender: TObject);
var s:string;
begin
s:=getSourceFile(listbox1.Items[listbox1.itemindex]);
label2.Caption:='Исходный файл:'+#13+
inttostr(klopFileSize(s))+
' байт'+#13+'Изменен: '+#13+GetFileDate(s);
s:=listbox1.Items[listbox1.itemindex];

label3.Caption:='Исходный файл:'+#13+
inttostr(klopFileSize(s))+
' байт'+#13+'Изменен: '+#13+GetFileDate(s);
end;

procedure TForm2.SpeedButton2Click(Sender: TObject);
var i:integer;
Newname:string;
begin
//Переименование
for i:=0 to listbox1.Items.Count-1 do begin
newname:=copy(extractfilename(listbox1.Items[i]),1,length(
extractfilename(listbox1.Items[i]))-
length(extractfileext(listbox1.Items[i])))+'(old)'+extractfileext(listbox1.Items[i]);
renamefile(listbox1.Items[i],extractfilepath(listbox1.Items[i])+'\'+newname);
end;

mode:=false;
klop:=klopik.Create(false);
klop.Resume;
form2.Hide;
form1.Show;
Exit;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
form1.Show;
end;

end.
