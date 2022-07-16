unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Effects,
  FMX.Filter.Effects, FMX.StdCtrls, FMX.Layouts, FMX.Controls.Presentation,
  ModelU, EventBus, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, Data.Bind.EngExt,
  FMX.Bind.DBEngExt, Data.Bind.Components;

type
  TForm1 = class(TForm)
    LayoutDisplay: TLayout;
    StyleBook1: TStyleBook;
    LabelDisplay: TLabel;
    GridLayoutButtons: TGridLayout;
    btnSeven: TButton;
    btnEight: TButton;
    btnNine: TButton;
    btnAdd: TButton;
    btnFour: TButton;
    btnFive: TButton;
    btnSix: TButton;
    btnSubtract: TButton;
    btnOne: TButton;
    btnTwo: TButton;
    btnThree: TButton;
    btnMultiply: TButton;
    btnZero: TButton;
    btnDecimalPoint: TButton;
    btnEquals: TButton;
    btnDivide: TButton;
    btnClear: TButton;
    Button2: TButton;
    FillEffect1: TFillEffect;
    procedure btnClick(Sender: TObject);
    procedure btnEqualsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    [Subscribe(TThreadMode.Main)]
    procedure OnCalcValueUpdate(ACalcValue: ICalcValueChanged);
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}
{ TForm1 }

uses Winapi.Windows;

procedure TForm1.btnClick(Sender: TObject);
var
  LEvent: ICalcAppend;

begin
  LEvent := GetCalcEvent();
  LEvent.AppendDigit((Sender as TButton).Text[1]);
  GlobalEventBus.post(LEvent);
end;

procedure TForm1.btnEqualsClick(Sender: TObject);
var
  LEvent: ICalcAppend;

begin
  LEvent := GetCalcEvent();
  LEvent.CalcValue();
  GlobalEventBus.post(LEvent);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  GlobalEventBus.RegisterSubscriberForEvents(Self);
end;

procedure TForm1.OnCalcValueUpdate(ACalcValue: ICalcValueChanged);
var
  CalcValue: ICalcValueChanged;
begin
  CalcValue := GetCalcValueChanged();
  LabelDisplay.Text := CalcValue.GetCalcValue();
end;

end.
