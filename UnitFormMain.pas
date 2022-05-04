unit UnitFormMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.ExtCtrls,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  UnitDB;

type
  TFormMain = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    EditURL: TEdit;
    ButtonIniciar: TButton;
    ButtonParar: TButton;
    ButtonExibirMsg: TButton;
    Panel1: TPanel;
    ProgressBar: TProgressBar;
    Label2: TLabel;
    Label3: TLabel;
    EditPastaDownload: TEdit;
    HTTP: TIdHTTP;
    procedure ButtonIniciarClick(Sender: TObject);
    procedure HTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure HTTPWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
    procedure HTTPStatus(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: string);
    procedure HTTPWork(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
  private
    { Private declarations }
  public
    { Public declarations }
    Info: TInfoDownload;
    ProgressCount: Integer;
    ProgressTotal: Integer;
    procedure DownloadFile(const URL, FileName: String);
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

uses UnitDownloadFile;

procedure TFormMain.ButtonIniciarClick(Sender: TObject);
var URL : String;
    FileName : String;
begin
  URL := Trim(EditURL.Text);
  FileName := 'C:\TEMP\TESTE.TMP';

  HTTP := TIdHTTP.Create;
  try
    DownloadFile(URL, FileName);
  finally
    HTTP.Free;
  end;
end;

procedure TFormMain.DownloadFile(const URL, FileName: String);
var FileStream : TFileStream;
begin
  FileStream := TFileStream.Create(FileName, fmCreate);
  try
    HTTP.Get(URL, FileStream);
  finally
    FileStream.Free;
  end;
end;

procedure TFormMain.HTTPStatus(ASender: TObject; const AStatus: TIdStatus;
  const AStatusText: string);
begin
  If AStatus = ftpAborted then Info.Cancelado := True;
end;

procedure TFormMain.HTTPWork(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  If ProgressTotal = 0 then Exit;

  ProgressCount := Round(AWorkCount / ProgressTotal) * 100;
  ProgressBar.Position := ProgressCount;
  Application.ProcessMessages;
end;

procedure TFormMain.HTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCountMax: Int64);
begin
  ProgressCount := 0;
  ProgressTotal := AWorkCountMax;

  With Info do
  begin
    URL := Trim(EditURL.Text);
    DataInicio := Now;
    EmAndamento := True;
  end;
end;

procedure TFormMain.HTTPWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
begin
  ProgressCount := 100;
  ProgressTotal := 0;
  ProgressBar.Position := 100;

  With Info do
  begin
    DataFim := Now;
  end;

  Info.SalvarInfoDownload;
end;

end.
