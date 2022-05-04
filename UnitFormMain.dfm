object FormMain: TFormMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'FastDownloads'
  ClientHeight = 216
  ClientWidth = 730
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 730
    Height = 216
    Align = alClient
    TabOrder = 0
    ExplicitHeight = 250
    object Label1: TLabel
      Left = 16
      Top = 32
      Width = 106
      Height = 15
      Caption = 'URL para download:'
    end
    object Label3: TLabel
      Left = 16
      Top = 61
      Width = 113
      Height = 15
      Caption = 'Pasta para download:'
    end
    object EditURL: TEdit
      Left = 152
      Top = 29
      Width = 553
      Height = 23
      Align = alCustom
      MaxLength = 600
      TabOrder = 0
      Text = 
        'https://downloadirpf.receita.fazenda.gov.br/irpf/2022/irpf/arqui' +
        'vos/IRPF2022Win32v1.4.exe'
    end
    object ButtonIniciar: TButton
      Left = 16
      Top = 106
      Width = 120
      Height = 25
      Caption = 'Iniciar download'
      TabOrder = 1
      OnClick = ButtonIniciarClick
    end
    object ButtonParar: TButton
      Left = 16
      Top = 137
      Width = 120
      Height = 25
      Caption = 'Parar download'
      TabOrder = 2
    end
    object ButtonExibirMsg: TButton
      Left = 16
      Top = 168
      Width = 120
      Height = 25
      Caption = 'Exibir mensagem'
      TabOrder = 3
    end
    object Panel1: TPanel
      Left = 152
      Top = 105
      Width = 553
      Height = 87
      TabOrder = 4
      object Label2: TLabel
        Left = 16
        Top = 14
        Width = 146
        Height = 15
        Alignment = taCenter
        Caption = 'Progresso do download (%)'
      end
      object ProgressBar: TProgressBar
        Left = 16
        Top = 35
        Width = 521
        Height = 33
        TabOrder = 0
      end
    end
    object EditPastaDownload: TEdit
      Left = 152
      Top = 58
      Width = 553
      Height = 23
      Align = alCustom
      MaxLength = 600
      TabOrder = 5
    end
  end
  object HTTP: TIdHTTP
    OnStatus = HTTPStatus
    OnWork = HTTPWork
    OnWorkBegin = HTTPWorkBegin
    OnWorkEnd = HTTPWorkEnd
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 664
    Top = 89
  end
end
