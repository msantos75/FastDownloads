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
    procedure ButtonIniciarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TDownload = class(TThread)
  private
    HTTP: TIdHTTP;
    Info: TInfoDownload;
    URL : String;
    FileName : String;
    ProgressCount: Integer;
    ProgressTotal: Integer;
    procedure HTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
    procedure HTTPWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
    procedure HTTPWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
    procedure HTTPStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: String);
    procedure UpdateProgressBar;
    procedure SetMaxProgressBar;
  public
    procedure IniciarDownload(const AURL, AFileName: String);
    procedure DownloadFile;
    constructor Create(const CreateSuspended: Boolean; const AURL, AFileName: String);
    destructor Destroy; override;
  end;

var
  FormMain: TFormMain;
  Download: TDownload;

implementation

{$R *.dfm}

uses UnitDownloadFile;

procedure TFormMain.ButtonIniciarClick(Sender: TObject);
var URL,
    FileName: String;
begin
  URL := Trim(FormMain.EditURL.Text);
  FileName := 'C:\TEMP\TESTE.TMP';
  Download.IniciarDownload(URL, FileName);
end;

{ TDownload }

constructor TDownload.Create(const CreateSuspended: Boolean; const AURL, AFileName: String);
begin
  inherited Create(CreateSuspended);
  HTTP := TIdHTTP.Create(nil);
  HTTP.OnWorkBegin := HTTPWorkBegin;
  HTTP.OnWork := HTTPWork;
  HTTP.OnWorkEnd := HTTPWorkEnd;
  URL := AURL;
  FileName := AFileName;
  Info := TInfoDownload.Create;
end;

destructor TDownload.Destroy;
begin
  If Assigned(HTTP) then HTTP.Free;
  If Assigned(Info) then Info.Free;
  inherited Destroy;
end;

procedure TDownload.DownloadFile;
var FileStream : TFileStream;
begin
  FileStream := TFileStream.Create(FileName, fmCreate);
  try
    HTTP.Get(URL, FileStream);
  finally
    FileStream.Free;
  end;
end;

procedure TDownload.HTTPStatus(ASender: TObject; const AStatus: TIdStatus;
  const AStatusText: string);
begin
  If AStatus = ftpAborted then Info.Cancelado := True;
end;

procedure TDownload.HTTPWork(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  If ProgressTotal = 0 then Exit;

  ProgressCount := Round(AWorkCount / ProgressTotal) * 100;
  Queue(UpdateProgressBar);
  Application.ProcessMessages;
end;

procedure TDownload.HTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCountMax: Int64);
begin
  ProgressCount := 0;
  ProgressTotal := AWorkCountMax;
  Queue(SetMaxProgressBar);

  Info.URL := URL;
  With Info do
  begin
    DataInicio := Now;
    EmAndamento := True;
  end;
end;

procedure TDownload.HTTPWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
begin
  ProgressCount := 100;
  ProgressTotal := 0;
  FormMain.ProgressBar.Position := 100;
  Application.ProcessMessages;
end;

procedure TDownload.IniciarDownload(const AURL, AFileName: String);
begin
  Download := TDownload.Create(True, AURL, AFileName);
  Download.FreeOnTerminate := True;

  DownloadFile;

  With Info do
  begin
    DataFim := Now;
    SalvarInfoDownload;
  end;
end;

procedure TDownload.SetMaxProgressBar;
begin
  FormMain.ProgressBar.Max := ProgressTotal;
end;

procedure TDownload.UpdateProgressBar;
begin
  FormMain.ProgressBar.Position := ProgressCount;
end;

end.
