unit UnitFormMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.ExtCtrls,
  System.Threading, System.UITypes,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IdStack,
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
    LabelProgress: TLabel;
    Label3: TLabel;
    EditPastaDownload: TEdit;
    procedure ButtonIniciarClick(Sender: TObject);
    procedure ButtonPararClick(Sender: TObject);
    procedure ButtonExibirMsgClick(Sender: TObject);
    procedure EditURLExit(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
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
    FilePathName : String;
    ProgressCount: Integer;
    ProgressTotal: Integer;
    AbortDownload : Boolean;
    procedure IniciarDownload(const AURL, AFileName: String);
    procedure HTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
    procedure HTTPWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
    procedure HTTPWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
    procedure UpdateProgressBar;
    procedure SetMaxProgressBar;
  protected
    procedure Execute; override;
    procedure Disconnect;
  public
    constructor Create(const CreateSuspended: Boolean; const AURL, AFileName: String); reintroduce;
    destructor Destroy; override;
  end;

var
  FormMain: TFormMain;
  Download: TDownload;

const PastaPadraoDownload : String = 'C:\FastDownloads';

implementation

{$R *.dfm}

uses UnitDownloadFile;

procedure TFormMain.ButtonExibirMsgClick(Sender: TObject);
begin
  If not Assigned(Download) then Exit;

  If Download.Info.EmAndamento then
    MessageDlg('Download em andamento... Percentual conluído: (' + FloatToStr(Download.ProgressCount) + '%)', mtInformation, [mbOk], 0) else
    MessageDlg('Download conluído: (' + FloatToStr(Download.ProgressCount) + '%)', mtInformation, [mbOk], 0);
end;

procedure TFormMain.ButtonIniciarClick(Sender: TObject);
var URL,
    FileName: String;
begin
  URL := Trim(FormMain.EditURL.Text);
  FileName := EditPastaDownload.Text;
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
  FilePathName := AFileName;
  AbortDownload := False;

  Info := TInfoDownload.Create;
end;

destructor TDownload.Destroy;
begin
  If Assigned(HTTP) then HTTP.Free;
  If Assigned(Info) then Info.Free;
  inherited Destroy;
end;

procedure TDownload.Disconnect;
begin
  If Assigned(HTTP) and HTTP.Connected then HTTP.Disconnect;
end;

procedure TDownload.Execute;
var FileStream : TFileStream;
begin
  With Download do
  try
    If FileExists(FilePathName) then
      If not DeleteFile(FilePathName) then
        RaiseLastOSError;

    FileStream := TFileStream.Create(FilePathName, fmCreate);
    try
      HTTP.Get(URL, FileStream);
    finally
      FileStream.Free;
    end;
  except
    on E: EIdHTTPProtocolException do
      Case E.ErrorCode of
        404 : MessageDlg(Format('URL inexistente. Erro: %d', [E.ErrorCode]), mtError, [mbOk], 0);
        else  MessageDlg(Format('Erro: %d [%s]', [E.ErrorCode, E.Message]), mtError, [mbOk], 0);
      end;

    on E: EIdSocketError do
      Case E.LastError of
        10060 : MessageDlg(Format('Tempo de espera expirado. Erro: %d', [E.LastError]), mtError, [mbOk], 0);
        11004 : MessageDlg(Format('Conexão com a internet inexistene. Erro: %d', [E.LastError]), mtError, [mbOk], 0);
        else    MessageDlg(Format('Erro: %d [%s]', [E.LastError, E.Message]), mtError, [mbOk], 0);
      end;

    on E: Exception do MessageDlg(Format('Erro: %s', [E.Message]), mtError, [mbOk], 0);
  end;
end;

procedure TDownload.HTTPWork(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  If ProgressTotal = 0 then Exit;

  If Download.AbortDownload then
  begin
    FormMain.ProgressBar.Position := 0;
    FormMain.LabelProgress.Caption := 'Progresso do download (%)';
    Application.ProcessMessages;

    Download.Info.EmAndamento := False;
    Abort;
  end;

  ProgressCount := Round(AWorkCount / ProgressTotal * 100);
  Queue(UpdateProgressBar);

  FormMain.LabelProgress.Caption := 'Progresso do download (' + FloatToStr(ProgressCount) + '%)';

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

  FormMain.ButtonIniciar.Enabled := False;
end;

procedure TDownload.HTTPWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
begin
  FormMain.ButtonIniciar.Enabled := True;
  If AbortDownload then Exit;

  ProgressCount := 100;
  ProgressTotal := 0;
  FormMain.ProgressBar.Position := 100;

  Application.ProcessMessages;

  With Download do
  begin
    Info.DataFim := Now;
    Info.EmAndamento := False;
    Info.SalvarInfoDownload;
  end;
end;

procedure TDownload.IniciarDownload(const AURL, AFileName: String);
begin
  Download := TDownload.Create(True, AURL, AFileName);

  With Download do
  begin
    FreeOnTerminate := True;
    Execute;
  end;
end;

procedure TDownload.SetMaxProgressBar;
begin
  FormMain.ProgressBar.Max := 100;
end;

procedure TDownload.UpdateProgressBar;
begin
  FormMain.ProgressBar.Position := ProgressCount;
end;

procedure TFormMain.ButtonPararClick(Sender: TObject);
begin
  If not Assigned(Download) then Exit;

  If Download.Info.EmAndamento then
  If MessageDlg('Download em andamento. Deseja abortar?', TMsgDlgType.mtWarning, [mbOk, mbCancel], 0) = ID_OK then
  begin
    Download.AbortDownLoad := True;
  end;
end;

procedure TFormMain.EditURLExit(Sender: TObject);
var S : String;
    N : Integer;
    PosIni : Integer;
begin
  EditPastaDownload.Text := PastaPadraoDownload;

  S := Trim(EditURL.Text);
  If S = '' then Exit;

  PosIni := 0;
  For N := Length(S) downto 1 do
  begin
    If S[N] = '/' then
    begin
      PosIni := N;
      Break;
    end;
  end;
  If PosIni = 0 then Exit;

  S := Copy(S, PosIni+1, Length(S) - PosIni);

  EditPastaDownload.Text := PastaPadraoDownload + '\' + S;
end;

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  If not Assigned(Download) then Exit;

  If Download.Info.EmAndamento then
    CanClose := MessageDlg('Download em andamento. Aguarde a conclusão ou pare o download.', mtWarning, [mbOk], 0) = ID_OK;
end;

end.
