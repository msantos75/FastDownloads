unit UnitDataModule;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Data.SqlExpr, Data.DbxSqlite,
  Data.FMTBcd, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TDataSet = class(TDataModule)
    DataSource: TDataSource;
    FDConnection: TFDConnection;
    FDTable: TFDTable;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataSet: TDataSet;

implementation

{$R *.dfm}

end.
