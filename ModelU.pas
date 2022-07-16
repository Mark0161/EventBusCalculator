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
  tempStr: String;
begin
  case Value of
    'B': // BackSpace
      if Length(CalcString) > 0 then
        tempStr := Copy(CalcString, 1, Length(CalcString) - 1);
    'C': // Clear
      tempStr := '';
  else
    begin
      tempStr := CalcString + Value;
      var
        Match: TMatch;
        // prevents decimal point followed by [+,-,*,/]
      Match := TRegEx.Match(tempStr, '(\.[+\-\*\/])');
      if Match.Success then
        exit();

      Match := TRegEx.Match(tempStr, '[+-]?(\d+\.?\d*[+\-\*\/]?)*');
      if (Match.Value <> tempStr) then
      begin
        exit();
      end;
    end;
  end;

  // if we've got as far tempstr is valid then update expression and notify listeners
  CalcString := tempStr;
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
  // exit if the expression contains  a '.' followed by a '+,-,*,/'
  var
    Match: TMatch := TRegEx.Match(CalcString, '(\.[+\-\*\/])');
  if Match.Success then
    exit();
  // exit if Expression ends in a .
  Match := TRegEx.Match(CalcString, '(\.$)');
  if Match.Success then
    exit();

  // Check the Expression format complies
  Match := TRegEx.Match(CalcString, '[+-]?(\d+\.?\d*[+\-\*\/]?)*');
  if (Match.Value <> CalcString) then
    exit();

  // if we've reached here then the Exprssion is valid
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
