object DataSet: TDataSet
  Height = 109
  Width = 316
  object DataSource: TDataSource
    DataSet = FDTable
    Left = 40
    Top = 24
  end
  object FDConnection: TFDConnection
    Params.Strings = (
      'Database=C:\CVSoft\Marcio\FastDownloads\DataBaseFastDownloads.db'
      'LockingMode=Normal'
      'DriverID=SQLite')
    Connected = True
    Left = 144
    Top = 24
  end
  object FDTable: TFDTable
    Active = True
    IndexFieldNames = 'CODIGO'
    Connection = FDConnection
    TableName = 'LOGDOWNLOAD'
    Left = 240
    Top = 24
  end
end
