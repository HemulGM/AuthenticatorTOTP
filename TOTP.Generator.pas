unit TOTP.Generator;

interface

uses
  OTP;

type
  TGenerator = class
  private
    FOTPCalculator: IOTPCalculator;
    FSecretKey: string;
    FPeriod: Integer;
    FTokenLength: Integer;
    FAlgorithm: TAlgorithm;
    function GetToken: string;
    function GetRemainingTime: Integer;
    procedure SetPeriod(const Value: Integer);
    procedure SetSecretKey(const Value: string);
    procedure SetTokenLength(const Value: Integer);
    procedure SetAlgorithm(const Value: TAlgorithm);
  public
    property Token: string read GetToken;
    property RemainingTime: Integer read GetRemainingTime;
    //
    property SecretKey: string read FSecretKey write SetSecretKey;
    property Period: Integer read FPeriod write SetPeriod default 30;
    property TokenLength: Integer read FTokenLength write SetTokenLength default 6;
    property Algorithm: TAlgorithm read FAlgorithm write SetAlgorithm default TAlgorithm.SHA1;
    constructor Create; overload;
    constructor Create(const ASecretKey: string; const APeriod: Integer = 30; const ATokenLength: Integer = 6); overload;
    destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils, System.DateUtils;

{ TGenerator }

constructor TGenerator.Create(const ASecretKey: string; const APeriod, ATokenLength: Integer);
begin
  Create;
  //
  SecretKey := ASecretKey;
  Period := APeriod;
  TokenLength := ATokenLength;
end;

constructor TGenerator.Create;
begin
  inherited Create;
  FOTPCalculator := TOTPCalculator.New;
  Algorithm := TAlgorithm.SHA1;
end;

destructor TGenerator.Destroy;
begin
  FOTPCalculator := nil;
  inherited;
end;

function TGenerator.GetRemainingTime: Integer;
begin
  Result := FPeriod - DateTimeToUnix(Now, False) mod FPeriod;
end;

function TGenerator.GetToken: string;
begin
  Result := FOTPCalculator.Calculate.ToString.PadLeft(FTokenLength, '0');
end;

procedure TGenerator.SetAlgorithm(const Value: TAlgorithm);
begin
  FAlgorithm := Value;
  FOTPCalculator.SetAlgorithm(Value);
end;

procedure TGenerator.SetPeriod(const Value: Integer);
begin
  FPeriod := Value;
  FOTPCalculator.SetKeyRegeneration(Value);
end;

procedure TGenerator.SetSecretKey(const Value: string);
begin
  FSecretKey := Value;
  FOTPCalculator.SetSecret(Value);
end;

procedure TGenerator.SetTokenLength(const Value: Integer);
begin
  FTokenLength := Value;
  FOTPCalculator.SetLength(Value);
end;

end.

