unit TOTP.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.EditBox, FMX.NumberBox,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Layouts, FMX.TabControl,
  FMX.Platform, TOTP.QRScan, OTP.Core.URL,
  {$IFDEF ANDROID or IOS}
  FMX.BiometricAuth,
  {$ENDIF}
  FMX.ListBox, FMX.Objects, TOTP.Frame.Key, FMX.SearchBox, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.FMXUI.Wait, Data.DB, FireDAC.Comp.Client, FireDAC.Phys.SQLite,
  FireDAC.DApt, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FMX.Media, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView, FMX.Ani;

type
  TFormMain = class(TForm)
    TimerUpdate: TTimer;
    TabControlMain: TTabControl;
    TabItemList: TTabItem;
    TabItemAdd: TTabItem;
    TabItemTest: TTabItem;
    EditSecretKey: TEdit;
    EditToken: TEdit;
    ProgressBarRemaining: TProgressBar;
    LabelRemainingTime: TLabel;
    Label1: TLabel;
    LayoutTestContent: TLayout;
    LayoutTestClient: TLayout;
    Label2: TLabel;
    ListBoxKeys: TListBox;
    Layout3: TLayout;
    Label3: TLabel;
    StyleBook: TStyleBook;
    TabItemAuth: TTabItem;
    ButtonAuth: TButton;
    Path1: TPath;
    TimerUpdateList: TTimer;
    SearchBoxKeys: TSearchBox;
    Circle1: TCircle;
    Label4: TLabel;
    LayoutListOverlay: TLayout;
    LayoutListActions: TLayout;
    ButtonAdd: TButton;
    PathAddPlus: TPath;
    LayoutAddPopup: TLayout;
    ButtonAddManual: TButton;
    ButtonAddScan: TButton;
    Path3: TPath;
    Path4: TPath;
    TabItemScan: TTabItem;
    CameraComponent: TCameraComponent;
    RectangleFrame: TRectangle;
    ButtonBack: TButton;
    Path2: TPath;
    LayoutFrameOverlay: TLayout;
    Rectangle1: TRectangle;
    FloatAnimation1: TFloatAnimation;
    AniIndicatorCamera: TAniIndicator;
    LabelScanError: TLabel;
    TimerErrorHide: TTimer;
    FDConnection: TFDConnection;
    LayoutAddClient: TLayout;
    LayoutAddContent: TLayout;
    EditAddSecret: TEdit;
    EditAddLabel: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    EditAddIssuer: TEdit;
    EditAddPeriod: TEdit;
    Label8: TLabel;
    Label9: TLabel;
    EditAddAlgorithm: TEdit;
    Label10: TLabel;
    EditAddDigits: TEdit;
    Layout1: TLayout;
    ButtonAddAccept: TButton;
    VertScrollBoxAdd: TVertScrollBox;
    procedure TimerUpdateTimer(Sender: TObject);
    procedure EditSecretKeyChangeTracking(Sender: TObject);
    procedure LayoutTestClientResize(Sender: TObject);
    procedure ButtonAuthClick(Sender: TObject);
    procedure TimerUpdateListTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonAddClick(Sender: TObject);
    procedure ButtonAddExit(Sender: TObject);
    procedure LayoutAddPopupClick(Sender: TObject);
    procedure LayoutAddPopupMouseLeave(Sender: TObject);
    procedure ButtonAddManualClick(Sender: TObject);
    procedure ButtonAddScanClick(Sender: TObject);
    procedure CameraComponentSampleBufferReady(Sender: TObject; const ATime: TMediaTime);
    procedure FormDestroy(Sender: TObject);
    procedure ListBoxKeysHScrollChange(Sender: TObject);
    procedure RectangleFramePaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure ButtonBackClick(Sender: TObject);
    procedure TabControlMainChange(Sender: TObject);
    procedure TimerErrorHideTimer(Sender: TObject);
    procedure LayoutAddClientResize(Sender: TObject);
    procedure ButtonAddAcceptClick(Sender: TObject);
    procedure FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
  private
    FMenuAddOpenned: Boolean;
    FQRScan: TQRScan;
    {$IFDEF ANDROID or IOS}
    FBiometricAuth: TBiometricAuth;
    procedure BiometricAuthAuthenticateFail(Sender: TObject; const FailReason: TBiometricFailReason; const ResultMessage: string);
    procedure BiometricAuthAuthenticateSuccess(Sender: TObject);
    {$ENDIF}
    procedure CreateDB;
    procedure CreateBio;
    procedure CloseAddMenu;
    function CropBitmap(const ABitmap: TBitmap): TBitmap;
    function AppEventHandler(AAppEvent: TApplicationEvent; AContext: TObject): Boolean;
    function ScanFrames(const Bitmap: TBitmap): Boolean;
    procedure FOnScanResult(Sender: TObject);
    function TryParseQR(const QRData: string): Boolean;
    procedure OpenAdd;
    procedure StartScan;
    procedure StopScan;
    procedure Append(AuthData: TOTPAuthURL);
    procedure CreateViewItem(const Index: Integer; AuthData: TOTPAuthURL);
    procedure Init;
    procedure OpenTab(Tab: TTabItem; Reverse: Boolean = False);
    procedure FOnRemoveItem(Sender: TObject; const Index: Integer);
    procedure RemoveItem(const Index: Integer);
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

procedure Beep;

implementation

uses
  {$IFDEF ANDROID or IOS}
  Androidapi.NativeWindow, FMX.Presentation.Android.Style,
  Androidapi.NativeWindowJni, Androidapi.JNIBridge, System.Permissions,
  Androidapi.Helpers, Androidapi.JNI.Os, Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.JavaTypes, Androidapi.JNI.Webkit, Androidapi.JNI.Net,
  Androidapi.JNI.App, Androidapi.JNI.Support, FMX.Platform.Android,
  Androidapi.JNI.Media,
  {$ENDIF}
  System.DateUtils, OTP, System.Math, System.IOUtils, OTP.Consts;

{$R *.fmx}

procedure Beep;
{$IFDEF ANDROID}
var
  Volume: Integer;
  StreamType: Integer;
  ToneType: Integer;
  ToneGenerator: JToneGenerator;
{$ENDIF}
begin
{$IFDEF ANDROID}
  Volume := TJToneGenerator.JavaClass.MAX_VOLUME;

  StreamType := TJAudioManager.JavaClass.STREAM_ALARM;
  ToneType := TJToneGenerator.JavaClass.TONE_CDMA_EMERGENCY_RINGBACK;
  try
    ToneGenerator := TJToneGenerator.JavaClass.init(StreamType, Volume);
    ToneGenerator.startTone(ToneType, 100);
  finally
    ToneGenerator.Release;
  end;
{$ENDIF}
end;

{$IFDEF ANDROID or IOS}
procedure TFormMain.BiometricAuthAuthenticateFail(Sender: TObject; const FailReason: TBiometricFailReason; const ResultMessage: string);
begin
  Application.Terminate;
end;

procedure TFormMain.BiometricAuthAuthenticateSuccess(Sender: TObject);
begin
  Init;
end;
{$ENDIF}

procedure TFormMain.ButtonAddAcceptClick(Sender: TObject);
begin
  if EditAddSecret.Text.IsEmpty then
    Exit;
  if EditAddLabel.Text.IsEmpty then
    Exit;
  var Data: TOTPAuthURL;
  Data.AuthType := TAuthType.TOTP;
  Data.Issuer := EditAddIssuer.Text;
  Data.LabelInfo := EditAddLabel.Text;
  Data.Secret := EditAddSecret.Text;
  Data.Algorithm := EditAddAlgorithm.Text;
  if not EditAddPeriod.Text.IsEmpty then
    Data.Period := EditAddPeriod.Text.ToInteger
  else
    Data.Period := KEY_REGENERATION;
  if not EditAddDigits.Text.IsEmpty then
    Data.Digits := EditAddDigits.Text.ToInteger
  else
    Data.Digits := OTP_LENGTH;
  Append(Data);
  OpenTab(TabItemList, True);
end;

procedure TFormMain.CreateDB;
begin
  try
    {$IFDEF ANDROID or IOS}
    FDConnection.Params.Database := TPath.Combine(TPath.GetDocumentsPath, 'local.db');
    {$ELSE}
    FDConnection.Params.Database := 'local.db';
    {$ENDIF}
    FDConnection.Open;
    FDConnection.ExecSQL(
      'CREATE TABLE IF NOT EXISTS keys ( ' +
      '  id        INTEGER PRIMARY KEY AUTOINCREMENT,' +
      '  auth_type INTEGER NOT NULL,' +
      '  issuer    STRING,' +
      '  label     STRING,' +
      '  secret    STRING  NOT NULL,' +
      '  image     STRING,' +
      '  algorithm STRING,' +
      '  period    INTEGER DEFAULT (30),' +
      '  digits    INTEGER DEFAULT (6),' +
      '  counter   INTEGER' +
      ');');
  except
    on E: Exception do
      ShowMessage(E.Message + #13#10 + FDConnection.Params.Database + #13#10 + TPath.GetDocumentsPath);
  end;
end;

procedure TFormMain.Append(AuthData: TOTPAuthURL);
begin
  with AuthData do
    FDConnection.ExecSQL(
      'INSERT INTO keys (auth_type, secret, issuer, label, algorithm, period, digits) ' +
      'VALUES (?, ?, ?, ?, ?, ?, ?)',
      [Ord(AuthType), Secret, Issuer, LabelInfo, Algorithm, Period, Digits]);
  var Id: Integer := FDConnection.ExecSQLScalar('select last_insert_rowid()');
  CreateViewItem(Id, AuthData);
end;

procedure TFormMain.FOnRemoveItem(Sender: TObject; const Index: Integer);
begin
  TThread.ForceQueue(nil,
    procedure
    begin
      RemoveItem(Index);
    end);
end;

procedure TFormMain.RemoveItem(const Index: Integer);
begin
  FDConnection.ExecSQL('DELETE FROM keys WHERE id = ?', [Index]);
  for var i := 0 to ListBoxKeys.Count - 1 do
  begin
    if ListBoxKeys.ListItems[i].Tag = Index then
    begin
      ListBoxKeys.ListItems[i].Free;
      Exit;
    end;
  end;
end;

procedure TFormMain.CreateViewItem(const Index: Integer; AuthData: TOTPAuthURL);
begin
  ListBoxKeys.BeginUpdate;
  try
    var Item := TListBoxItem.Create(ListBoxKeys);
    Item.Tag := Index;
    ListBoxKeys.AddObject(Item);
    var Frame := TFrameKey.Create(Item);
    Frame.Id := Index;
    Frame.SetOTPData(AuthData);
    Frame.Parent := Item;
    Frame.Align := TAlignLayout.Client;
    Frame.OnRemove := FOnRemoveItem;
    Item.Text := Frame.Text;
    Frame.Update;
  finally
    ListBoxKeys.EndUpdate;
  end;
end;

procedure TFormMain.ButtonAddClick(Sender: TObject);
const
  Dur = 0.2;
begin
  if FMenuAddOpenned then
    CloseAddMenu
  else
  begin
    FMenuAddOpenned := True;
    LayoutAddPopup.HitTest := True;
    TAnimator.AnimateFloat(PathAddPlus, 'RotationAngle', 135, Dur);
    TAnimator.AnimateFloat(ButtonAddScan, 'Position.Y', 6, Dur);
    TAnimator.AnimateFloat(ButtonAddScan, 'Opacity', 1, Dur);
    TAnimator.AnimateFloat(ButtonAddManual, 'Position.Y', 53, Dur);
    TAnimator.AnimateFloat(ButtonAddManual, 'Opacity', 1, Dur);
  end;
end;

function TFormMain.CropBitmap(const ABitmap: TBitmap): TBitmap;
var
  LCropW, LCropH, LCropMargin: Integer;
begin
  LCropMargin := Round(Abs(ABitmap.Width - ABitmap.Height) / 2);
  LCropW := LCropMargin;
  LCropH := 0;
  if ABitmap.Width < ABitmap.Height then
  begin
    LCropW := 0;
    LCropH := LCropMargin;
  end;

  Result := TBitmap.Create(ABitmap.Width - (2 * LCropW), ABitmap.Height - (2 * LCropH));
  Result.CopyFromBitmap(ABitmap, Rect(LCropW, LCropH, ABitmap.Width - LCropW, ABitmap.Height - LCropH), 0, 0);
end;

function TFormMain.ScanFrames(const Bitmap: TBitmap): Boolean;
begin
  Result := False;
  if FQRScan.IsBusy then
    Exit;
  Result := True;
  FQRScan.Scan(Bitmap);
end;

procedure TFormMain.CameraComponentSampleBufferReady(Sender: TObject; const ATime: TMediaTime);
var
  LBuffer, LReducedBuffer: TBitmap;
begin
  LBuffer := TBitmap.Create;
  try
    CameraComponent.SampleBufferToBitmap(LBuffer, True);
    AniIndicatorCamera.Visible := False;
    LayoutFrameOverlay.Visible := True;
    LReducedBuffer := CropBitmap(LBuffer);
    RectangleFrame.Fill.Kind := TBrushKind.Bitmap;
    RectangleFrame.Fill.Bitmap.WrapMode := TWrapMode.TileStretch;
    RectangleFrame.Fill.Bitmap.Bitmap.Assign(LReducedBuffer);
    if not ScanFrames(LReducedBuffer) then
      LReducedBuffer.Free;
  finally
    LBuffer.Free;
  end;
end;

procedure TFormMain.CloseAddMenu;
const
  Dur = 0.2;
begin
  if not FMenuAddOpenned then
    Exit;
  LayoutAddPopup.HitTest := False;
  FMenuAddOpenned := False;
  TAnimator.AnimateFloat(PathAddPlus, 'RotationAngle', 0, Dur);
  TAnimator.AnimateFloat(ButtonAddScan, 'Position.Y', 150, Dur);
  TAnimator.AnimateFloat(ButtonAddScan, 'Opacity', 0, Dur);
  TAnimator.AnimateFloat(ButtonAddManual, 'Position.Y', 150, Dur);
  TAnimator.AnimateFloat(ButtonAddManual, 'Opacity', 0, Dur);
end;

procedure TFormMain.ButtonAddExit(Sender: TObject);
begin
  var Obj := ObjectAtPoint(Screen.MousePos);
  if (Obj.GetObject = ButtonAddScan) or (Obj.GetObject = ButtonAddManual) then
    Exit;
  CloseAddMenu;
end;

procedure TFormMain.ButtonAddManualClick(Sender: TObject);
begin
  CloseAddMenu;
  OpenAdd;
end;

procedure TFormMain.ButtonAddScanClick(Sender: TObject);
begin
  CloseAddMenu;
  StartScan;
end;

procedure TFormMain.ButtonAuthClick(Sender: TObject);
begin
  {$IFDEF ANDROID or IOS}
  if FBiometricAuth.CanAuthenticate then
    FBiometricAuth.Authenticate
  else
    OpenTab(TabItemTest);
  {$ENDIF}
end;

procedure TFormMain.ButtonBackClick(Sender: TObject);
begin
  StopScan;
  OpenTab(TabItemList);
end;

procedure TFormMain.StartScan;
begin
  AniIndicatorCamera.Visible := True;
  LayoutFrameOverlay.Visible := False;
  LabelScanError.Visible := False;
  {$IFDEF ANDROID}
  var PermCamera := JStringToString(TJManifest_permission.JavaClass.CAMERA);
  if not PermissionsService.IsPermissionGranted(PermCamera) then
    PermissionsService.RequestPermissions(
      [PermCamera],
      procedure(const APermissions: TClassicStringDynArray; const AGrantResults: TClassicPermissionStatusDynArray)
      begin
        if (Length(AGrantResults) > 0) and (AGrantResults[0] = TPermissionStatus.Granted) then
        begin
          CameraComponent.FocusMode := TFocusMode.ContinuousAutoFocus;
          CameraComponent.CaptureSettingPriority := TVideoCaptureSettingPriority.FrameRate;
          CameraComponent.Active := True;
          OpenTab(TabItemScan);
        end;
      end)
  else
  begin
    CameraComponent.FocusMode := TFocusMode.ContinuousAutoFocus;
    CameraComponent.CaptureSettingPriority := TVideoCaptureSettingPriority.FrameRate;
    CameraComponent.Active := True;
    OpenTab(TabItemScan);
  end;
  {$ELSE}
  CameraComponent.FocusMode := TFocusMode.ContinuousAutoFocus;
  CameraComponent.CaptureSettingPriority := TVideoCaptureSettingPriority.FrameRate;
  CameraComponent.Active := True;
  OpenTab(TabItemScan);
  {$ENDIF}
end;

procedure TFormMain.EditSecretKeyChangeTracking(Sender: TObject);
begin
  TimerUpdate.Enabled := False;
  TimerUpdate.Enabled := True;
end;

procedure TFormMain.CreateBio;
begin
  {$IFDEF ANDROID or IOS}
  FBiometricAuth := TBiometricAuth.Create(Self);
  with FBiometricAuth do
  begin
    AllowedAttempts := 0;
    BiometricStrengths := [TBiometricStrength.DeviceCredential];
    PromptConfirmationRequired := False;
    PromptDescription := 'Enter to HGM Authenticator';
    OnAuthenticateFail := BiometricAuthAuthenticateFail;
    OnAuthenticateSuccess := BiometricAuthAuthenticateSuccess;
  end;
  {$ENDIF}
end;

function TFormMain.AppEventHandler(AAppEvent: TApplicationEvent; AContext: TObject): Boolean;
begin
  Result := False;

  if AAppEvent in [
    TApplicationEvent.WillBecomeInactive,
    TApplicationEvent.EnteredBackground,
    TApplicationEvent.WillTerminate
    ] then
    StopScan;
end;

procedure TFormMain.StopScan;
begin
  CameraComponent.Active := False;
  RectangleFrame.Fill.Kind := TBrushKind.Solid;
  AniIndicatorCamera.Visible := False;
  LayoutFrameOverlay.Visible := False;
end;

procedure TFormMain.OpenTab(Tab: TTabItem; Reverse: Boolean);
begin
  if TabControlMain.ActiveTab = Tab then
    Exit;
  if not Reverse then
    TabControlMain.SetActiveTabWithTransitionAsync(Tab, TTabTransition.Slide, TTabTransitionDirection.Normal, nil)
  else
    TabControlMain.SetActiveTabWithTransitionAsync(Tab, TTabTransition.Slide, TTabTransitionDirection.Reversed, nil);
  //TabControlMain.ActiveTab := Tab;
end;

procedure TFormMain.OpenAdd;
begin
  OpenTab(TabItemAdd);
end;

function TFormMain.TryParseQR(const QRData: string): Boolean;
begin
  try
    var OTP := TOTPAuthURL.Create(QRData);
    EditAddSecret.Text := OTP.Secret;
    EditAddLabel.Text := OTP.LabelInfo;
    EditAddIssuer.Text := OTP.Issuer;
    if OTP.Period <> KEY_REGENERATION then
      EditAddPeriod.Text := OTP.Period.ToString;
    if OTP.Digits <> OTP_LENGTH then
      EditAddDigits.Text := OTP.Digits.ToString;
    EditAddAlgorithm.Text := OTP.Algorithm;
    OpenAdd;
    Result := True;
  except
    Result := False;
  end;
end;

procedure TFormMain.FOnScanResult(Sender: TObject);
begin
  if FQRScan.LastResult.IsEmpty then
    Exit;
  if not CameraComponent.Active then
    Exit;
  if not TryParseQR(FQRScan.LastResult) then
  begin
    TimerErrorHide.Enabled := False;
    LabelScanError.Text := 'Invalid OTP QR';
    LabelScanError.Visible := True;
    TimerErrorHide.Enabled := True;
  end;
end;

procedure TFormMain.Init;
begin
  CreateDB;
  TabControlMain.ActiveTab := TabItemList;
  var Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDConnection;
    Query.Open('SELECT * FROM keys');
    Query.First;
    ListBoxKeys.BeginUpdate;
    try
      while not Query.Eof do
      begin
        var Data: TOTPAuthURL;
        Data.AuthType := TAuthType(Query.FieldByName('auth_type').AsInteger);
        Data.Issuer := Query.FieldByName('issuer').AsString;
        Data.LabelInfo := Query.FieldByName('label').AsString;
        Data.Secret := Query.FieldByName('secret').AsString;
        Data.Algorithm := Query.FieldByName('algorithm').AsString;
        Data.Period := Query.FieldByName('period').AsInteger;
        Data.Digits := Query.FieldByName('digits').AsInteger;
        var Id := Query.FieldByName('id').AsInteger;
        CreateViewItem(Id, Data);
        Query.Next;
      end;
    finally
      ListBoxKeys.EndUpdate;
    end;
  finally
    Query.Free;
  end;
  TimerUpdateList.Enabled := True;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  var LAppEventService: IFMXApplicationEventService;
  if TPlatformServices.Current.SupportsPlatformService(IFMXApplicationEventService, LAppEventService) then
    LAppEventService.SetApplicationEventHandler(AppEventHandler);

  ListBoxKeys.Clear;
  FQRScan := TQRScan.Create;
  FQRScan.OnResult := FOnScanResult;
  TAnimation.AniFrameRate := 300;
  ButtonAddScan.Position.Y := 150;
  ButtonAddScan.Opacity := 0;
  ButtonAddManual.Position.Y := 150;
  ButtonAddManual.Opacity := 0;
  FMenuAddOpenned := False;
  {$IFDEF ANDROID or IOS}
  CreateBio;
  TabControlMain.ActiveTab := TabItemAuth;
  {$ELSE}
  Init;
  {$ENDIF}
  ListBoxKeys.AniCalculations.Animation := True;
  ListBoxKeys.AniCalculations.Interval := 1;
  ListBoxKeys.AniCalculations.Averaging := True;
  ListBoxKeys.AniCalculations.BoundsAnimation := True;
  TabControlMainChange(nil);
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  FQRScan.OnResult := nil;
  FQRScan.Free;
end;

procedure TFormMain.FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
begin
  TAnimator.AnimateFloat(Self, 'Padding.Bottom', 0);
  //TAnimator.AnimateFloat(LayoutOverlay, 'Margins.Bottom', 0);
end;

procedure TFormMain.FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
begin
  TAnimator.AnimateFloat(Self, 'Padding.Bottom', Bounds.Height);
  //TAnimator.AnimateFloat(LayoutOverlay, 'Margins.Bottom', Bounds.Height);
end;

procedure TFormMain.LayoutAddClientResize(Sender: TObject);
begin
  LayoutAddContent.Width := Min(370, LayoutAddClient.Width);
end;

procedure TFormMain.LayoutAddPopupClick(Sender: TObject);
begin
  CloseAddMenu;
end;

procedure TFormMain.LayoutAddPopupMouseLeave(Sender: TObject);
begin
  var Obj := ObjectAtPoint(Screen.MousePos);
  if (Obj.GetObject = ButtonAddScan) or (Obj.GetObject = ButtonAddManual) then
    Exit;
  CloseAddMenu;
end;

procedure TFormMain.LayoutTestClientResize(Sender: TObject);
begin
  LayoutTestContent.Width := Min(370, LayoutTestClient.Width);
end;

procedure TFormMain.ListBoxKeysHScrollChange(Sender: TObject);
begin
  Invalidate;
end;

procedure TFormMain.RectangleFramePaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
const
  ASize = 6;
begin
  Canvas.BeginScene;
  try
    var List := FQRScan.Points.LockList;
    try
      for var Item in List do
      begin
        var R: TRectF;
        R.Left := (Item.X - (ASize / 2)) * (RectangleFrame.Width / RectangleFrame.Fill.Bitmap.Bitmap.Width);
        R.Top := (Item.Y - (ASize / 2)) * (RectangleFrame.Height / RectangleFrame.Fill.Bitmap.Bitmap.Height);
        R.Width := ASize;
        R.Height := ASize;
        Canvas.Fill.Color := TAlphaColors.White;
        Canvas.FillEllipse(R, 1);
      end;
    finally
      FQRScan.Points.UnlockList;
    end;
  finally
    Canvas.EndScene;
  end;
end;

procedure TFormMain.TabControlMainChange(Sender: TObject);
begin
  ButtonBack.Visible :=
    (TabControlMain.ActiveTab = TabItemAdd)
    or (TabControlMain.ActiveTab = TabItemScan)
    or (TabControlMain.ActiveTab = TabItemTest);
  if TabControlMain.ActiveTab <> TabItemScan then
    StopScan;
end;

procedure TFormMain.TimerErrorHideTimer(Sender: TObject);
begin
  TimerErrorHide.Enabled := False;
  LabelScanError.Visible := False;
end;

procedure TFormMain.TimerUpdateListTimer(Sender: TObject);
begin
  for var i := 0 to ListBoxKeys.Count - 1 do
    for var Control in ListBoxKeys.ListItems[i].Controls do
      if Control is TFrameKey then
      begin
        TFrameKey(Control).Update;
        Break;
      end;
end;

procedure TFormMain.TimerUpdateTimer(Sender: TObject);
begin
  try
    var Period := 30;
    var TokenLength := 6;
    var RemainingTime := Period - DateTimeToUnix(Now, False) mod Period;
    var SecretKey := EditSecretKey.Text;

    EditToken.Text := TOTPCalculator.New
      .SetSecret(SecretKey)
      .SetKeyRegeneration(Period)
      .SetLength(TokenLength)
      .SetAlgorithm(TAlgorithm.SHA1)
      .Calculate
      .ToString
      .PadLeft(TokenLength, '0');

    ProgressBarRemaining.Max := Period;
    ProgressBarRemaining.Value := RemainingTime;

    LabelRemainingTime.Text := Format('Updating in %d seconds', [RemainingTime]);
  except
    TimerUpdate.Enabled := False;
    EditToken.Text := '';
    raise;
  end;
end;

end.

