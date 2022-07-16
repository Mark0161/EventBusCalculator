unit ModelU;

interface

type
  ICalcAppend = interface
    ['{265022E9-2220-4A81-9C73-752CF2E215BD}']
    procedure AppendDigit(const Value: Char);
    procedure CalcValue();
    procedure ClearCalc();
  end;

  ICalcValueChanged = interface
    ['{666E599F-901C-406B-9F4F-FC763CA36474}']
    function GetCalcValue: String;
  end;

function GetCalcEvent: ICalcAppend;
function GetCalcValueChanged: ICalcValueChanged;

implementation

uses
  System.Threading, EventBus, System.Classes, System.Bindings.Helper,
  System.Bindings.Expression, System.RegularExpressions, FMX.Dialogs,
  System.Bindings.EvalProtocol, System.SysUtils;

type
  TCalcAppend = class(TInterfacedObject, ICalcAppend)
    procedure AppendDigit(const Value: Char);
    procedure ClearCalc();
    procedure CalcValue();
  end;

  TCalcValueChanged = class(TInterfacedObject, ICalcValueChanged)
    function GetCalcValue: String;
  end;

  { TCalcCommands }

var
  CalcString: String;

procedure TCalcAppend.AppendDigit(const Value: Char);
var
  CalcValueChanged: ICalcValueChanged;

begin
  case Value of
    'B': // BackSpace
      if Length(CalcString) > 0 then
        CalcString := Copy(CalcString, 1, Length(CalcString) - 1);
    'C': // Clear
      CalcString := '';
  else
    CalcString := CalcString + Value;
  end;

  var
    CalcValueChangedEv: ICalcValueChanged := GetCalcValueChanged();
  GlobalEventBus.post(CalcValueChangedEv);
end;

procedure TCalcAppend.CalcValue;
var
  LExpression: TBindingExpression;
  Value: Extended;
  CalcValueChangedEv: ICalcValueChanged;
begin
  LExpression := TBindings.CreateExpression([], CalcString);
  try
    try
      Value := LExpression.Evaluate.GetValue.AsExtended;
      CalcString := FloatToStr(Value);
      CalcValueChangedEv := GetCalcValueChanged();
      // Notify listeners
      GlobalEventBus.post(CalcValueChangedEv);
    Except
      on E: EEvaluatorError do
        ShowMessage(E.ClassName + ' error raised, with message : ' + E.Message);
    end;
  finally
    LExpression.Free;
  end;
end;

procedure TCalcAppend.ClearCalc;
begin;
  CalcString := '';
end;

function GetCalcEvent: ICalcAppend;
begin
  result := TCalcAppend.Create();
end;

{ TCalcValue }

function TCalcValueChanged.GetCalcValue: String;
begin
  result := CalcString;
end;

function GetCalcValueChanged: ICalcValueChanged;
begin
  result := TCalcValueChanged.Create();
end;

end.
