unit UnitDownloadFile;

interface

uses
  System.SysUtils, System.Classes, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP;

type
  TDataModuleDownload = class(TDataModule)
    IdHTTP: TIdHTTP;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataModuleDownload: TDataModuleDownload;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
