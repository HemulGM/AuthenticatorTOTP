unit TOTP.Frame.Key;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, TOTP.Generator, FMX.Ani, OTP.Core.URL,
  OTP.Types, FMX.Menus, FMX.Layouts;

type
  TOnRemoveItem = procedure(Sender: TObject; const Index: Integer) of object;

  TFrameKey = class(TFrame)
    LineContent: TLine;
    LabelInfo: TLabel;
    LabelToken: TLabel;
    PieTime: TPie;
    RectangleBG: TRectangle;
    FloatAnimationBG: TFloatAnimation;
    PathCopied: TPath;
    TimerCopy: TTimer;
    PopupMenu: TPopupMenu;
    MenuItemDelete: TMenuItem;
    ButtonDelete: TButton;
    LayoutContent: TLayout;
    LayoutEdit: TLayout;
    Path1: TPath;
    LabelInfoEdit: TLabel;
    procedure FrameGesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
    procedure FrameTap(Sender: TObject; const Point: TPointF);
    procedure FrameClick(Sender: TObject);
    procedure TimerCopyTimer(Sender: TObject);
    procedure MenuItemDeleteClick(Sender: TObject);
    procedure FrameMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure ButtonDeleteClick(Sender: TObject);
    procedure ButtonDeleteExit(Sender: TObject);
    procedure LayoutEditClick(Sender: TObject);
  private
    FGenerator: TGenerator;
    FText: string;
    FToken: string;
    FOnRemove: TOnRemoveItem;
    FId: Integer;
    procedure SetText(const Value: string);
    procedure CopyToClipboard;
    procedure SetOnRemove(const Value: TOnRemoveItem);
    procedure SetId(const Value: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Update;
    procedure SetOTPData(Data: TOTPAuthURL);
    property Text: string read FText write SetText;
    property Id: Integer read FId write SetId;
    property OnRemove: TOnRemoveItem read FOnRemove write SetOnRemove;
  end;

implementation

uses
  OTP.Core.SecretGenerator, System.Threading, FMX.Platform, FMX.DialogService;

{$R *.fmx}

{ TFrameKey }

constructor TFrameKey.Create(AOwner: TComponent);
begin
  inherited;
  Name := '';
  LayoutEdit.Visible := False;
  LayoutContent.Visible := True;
  FGenerator := TGenerator.Create(TOTPSecretGenerator.New.Generate, 30, 6);
end;

destructor TFrameKey.Destroy;
begin
  FGenerator.Free;
  inherited;
end;

procedure TFrameKey.ButtonDeleteClick(Sender: TObject);
begin
  if Assigned(FOnRemove) then
    FOnRemove(Self, FId);
end;

procedure TFrameKey.ButtonDeleteExit(Sender: TObject);
begin
  LayoutEdit.Visible := False;
  LayoutContent.Visible := True;
end;

procedure TFrameKey.CopyToClipboard;
begin
  var ClipBoard: IFMXClipboardService;
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, ClipBoard) then
  begin
    ClipBoard.SetClipboard(FToken);
    PathCopied.Opacity := 1;
    TimerCopy.Enabled := True;
  end;
end;

procedure TFrameKey.FrameClick(Sender: TObject);
begin
  {$IFNDEF ANDROID or IOS}
  CopyToClipboard;
  {$ENDIF}
end;

procedure TFrameKey.FrameGesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
  if (EventInfo.GestureID = System.UITypes.igiLongTap) and (TInteractiveGestureFlag.gfBegin in EventInfo.Flags) then
  begin
    Handled := True;
    LayoutEdit.Visible := True;
    ButtonDelete.SetFocus;
    LayoutContent.Visible := False;
  end;
end;

procedure TFrameKey.FrameMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  {$IFNDEF ANDROID or IOS}
  if Button = TMouseButton.mbRight then
  begin
    var P := Screen.MousePos;
    PopupMenu.Popup(P.X, P.Y);
  end;
  {$ENDIF}
end;

procedure TFrameKey.FrameTap(Sender: TObject; const Point: TPointF);
begin
  if LayoutEdit.Visible then
    Exit;
  CopyToClipboard;
end;

procedure TFrameKey.LayoutEditClick(Sender: TObject);
begin
  LayoutEdit.Visible := False;
  LayoutContent.Visible := True;
end;

procedure TFrameKey.MenuItemDeleteClick(Sender: TObject);
begin
  if Assigned(FOnRemove) then
    FOnRemove(Self, FId);
end;

procedure TFrameKey.SetId(const Value: Integer);
begin
  FId := Value;
end;

procedure TFrameKey.SetOnRemove(const Value: TOnRemoveItem);
begin
  FOnRemove := Value;
end;

procedure TFrameKey.SetOTPData(Data: TOTPAuthURL);
begin
  FGenerator.SecretKey := Data.Secret;
  FGenerator.Period := Data.Period;
  FGenerator.TokenLength := Data.Digits;
  FGenerator.Algorithm := TAlgorithm.SHA1;
  if Data.Issuer.IsEmpty then
    Text := Data.LabelInfo
  else
    Text := Data.Issuer + ': ' + Data.LabelInfo;
end;

procedure TFrameKey.SetText(const Value: string);
begin
  FText := Value;
  LabelInfo.Text := Value;
  LabelInfoEdit.Text := Value;
end;

procedure TFrameKey.TimerCopyTimer(Sender: TObject);
begin
  PathCopied.Opacity := 0;
  TimerCopy.Enabled := False;
end;

procedure TFrameKey.Update;
begin
  TTask.Run(
    procedure
    begin
      var Token := '';
      try
        Token := FGenerator.Token.Insert(3, ' ');
        FToken := Token;
      except
        Token := 'ERROR';
      end;
      TThread.Queue(nil,
        procedure
        begin
          LabelToken.Text := Token;
          var RemPerc := 100 / FGenerator.Period * FGenerator.RemainingTime;
          PieTime.StartAngle := 360 - ((360 / 100 * RemPerc) + 90);
        end);
    end);
end;

end.

