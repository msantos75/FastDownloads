program ProjectFastDownloads;

uses
  Vcl.Forms,
  UnitFormMain in 'UnitFormMain.pas' {FormMain},
  UnitDataModule in 'UnitDataModule.pas' {DataSet: TDataModule},
  UnitDB in 'UnitDB.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TDataSet, DataSet);
  Application.Run;
end.
