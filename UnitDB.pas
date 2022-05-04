unit UnitDB;

interface

type
  TInfoDownload = class(TObject)
  private
    FCodigo      : Double;
    FURL         : String;
    FDataInicio  : TDateTime;
    FDataFim     : TDateTime;
    FEmAndamento : Boolean;
    FCancelado   : Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    property Codigo      : Double     read FCodigo      write FCodigo;
    property URL         : String     read FURL         write FURL;
    property DataInicio  : TDateTime  read FDataInicio  write FDataInicio;
    property DataFim     : TDateTime  read FDataFim     write FDataFim;
    property EmAndamento : Boolean    read FEmAndamento write FEmAndamento;
    property Cancelado   : Boolean    read FCancelado   write FCancelado;
    function SalvarInfoDownload: Boolean;
  end;

implementation

uses System.SysUtils,
     Vcl.Dialogs,
     FireDac.Comp.Client,
     FireDac.Stan.Param,
     UnitDataModule;

function TInfoDownload.SalvarInfoDownload: Boolean;
var Query : TFDQuery;
begin
  Result := False;
  try
    DataSet.FDConnection.StartTransaction;

    Query := TFDQuery.Create(nil);
    With Query do
    try
      Connection := DataSet.FDConnection;

      Close;
      SQL.Clear;
      SQL.Add('INSERT INTO LOGDOWNLOAD(CODIGO, URL, DATAINICIO, DATAFIM)');
      SQL.Add('VALUES (:CODIGO, :URL, :DATAINICIO, :DATAFIM)');

      ParamByName('CODIGO').AsFloat := Codigo;
      ParamByName('URL').AsString := URL;
      ParamByName('DATAINICIO').AsDateTime := DataInicio;
      ParamByName('DATAFIM').AsDateTime := DataFim;
      ExecSQL;

      Result := RowsAffected > 0;
      DataSet.FDConnection.Commit;

    finally
      Query.Free;
    end;

  except
    On E : Exception do
    begin
      DataSet.FDConnection.Rollback;
      CreateMessageDialog('Erro crítico ao gravar registro de download: ' + E.Message, mtError, [mbOk], mbOk);
    end;
  end;
end;

{ TInfoDownload }

constructor TInfoDownload.Create;
begin
  inherited Create;
  FCodigo      := 0;
  FURL         := '';
  FDataInicio  := 0;
  FDataFim     := 0;
  FEmAndamento := False;
  FCancelado   := False;
end;

destructor TInfoDownload.Destroy;
begin
  inherited Destroy;
end;

end.
