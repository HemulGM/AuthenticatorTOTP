unit TOTP.QRScan;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Threading,
  System.Generics.Collections, FMX.Graphics, ZXing.ReadResult, ZXing.ScanManager,
  ZXing.BarcodeFormat, ZXing.ResultPoint;

type
  TQRScan = class
  private
    FIsBusy: Boolean;
    FOnResult: TNotifyEvent;
    FLastResult: string;
    FScanManager: TScanManager;
    FTask: ITask;
    FPoints: TThreadList<TPointF>;
    procedure SetOnResult(const Value: TNotifyEvent);
    procedure OnResultPointHandler(const APoint: IResultPoint);
  public
    procedure Scan(Bitmap: TBitmap);
    property IsBusy: Boolean read FIsBusy;
    property LastResult: string read FLastResult;
    property OnResult: TNotifyEvent read FOnResult write SetOnResult;
    property Points: TThreadList<TPointF> read FPoints;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TQRScan }

constructor TQRScan.Create;
begin
  inherited;
  FScanManager := TScanManager.Create(TBarcodeFormat.QR_CODE, nil);
  FScanManager.OnResultPoint := OnResultPointHandler;
  FTask := nil;
  FPoints := TThreadList<TPointF>.Create;
end;

destructor TQRScan.Destroy;
begin
  if Assigned(FTask) then
    TTask.WaitForAll([FTask]);
  FScanManager.Free;
  FPoints.Free;
  inherited;
end;

procedure TQRScan.OnResultPointHandler(const APoint: IResultPoint);
begin
  var List := FPoints.LockList;
  try
    if List.Count > 40 then
      List.Delete(0);
    List.Add(TPointF.Create(APoint.X, APoint.Y));
  finally
    FPoints.UnlockList;
  end;
end;

procedure TQRScan.Scan(Bitmap: TBitmap);
var
  LReadResult: TReadResult;
begin
  if not Assigned(Bitmap) then
    Exit;
  if (Bitmap.Width < 2) or FIsBusy then
  begin
    Bitmap.Free;
    Exit;
  end;

  FIsBusy := True;
  FLastResult := '';
  FTask := TTask.Run(
    procedure
    begin
      try
        try
          var List := FPoints.LockList;
          try
            if List.Count > 0 then
              List.Delete(0);
          finally
            FPoints.UnlockList;
          end;
          LReadResult := FScanManager.Scan(Bitmap);
        except
          LReadResult := nil;
        end;
        if LReadResult <> nil then
        begin
          FPoints.Clear;
          FLastResult := LReadResult.text;
          TThread.Queue(nil,
            procedure
            begin
              if Assigned(FOnResult) then
                FOnResult(Self);
              FIsBusy := False;
            end);
          LReadResult.Free;
        end
        else
          FIsBusy := False;
      finally
        FTask := nil;
        Bitmap.Free;
      end;
    end);
end;

procedure TQRScan.SetOnResult(const Value: TNotifyEvent);
begin
  FOnResult := Value;
end;

end.

