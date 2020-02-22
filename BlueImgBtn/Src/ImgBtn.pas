(************************************************)
(*					ImgBtn.Pas                  *)
(*			      蓝鸟软件工作室				*)
(*	http://www.learnew.com/archives/116.htm     *)
(************************************************)

unit ImgBtn;

interface

// Designed By 蓝鸟软件工作室，Learnew.com

uses
  Classes, Controls, ExtCtrls, Graphics, Messages;

type
  TImgBtn = class(TCustomPanel)
  private
    FTransparent: Boolean;
    FPicture: TPicture;
    FPictureNormal: TPicture;
    FPictureHot: TPicture;
    FPictureDown: TPicture;
    FPictureDisabled: TPicture;
    procedure PictureChanged(Sender: TObject);
    procedure SetPictureNormal(Value: TPicture);
    procedure SetPictureHot(Value: TPicture);
    procedure SetPictureDown(Value: TPicture);
    procedure SetPictureDisabled(Value: TPicture);
    procedure SetTransparent(Value: Boolean);

  protected
    procedure Paint; override;
    procedure SetEnabled(Value: Boolean); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    Procedure CMMouseEnter(var msg: TMessage); message CM_MOUSEENTER;
    Procedure CMMouseLeave(var msg: TMessage); message CM_MOUSELEAVE;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;

  published
    property Enabled;
    property OnClick;
    property ShowHint;
    property Transparent: Boolean read FTransparent write SetTransparent;
    property PictureNormal: TPicture read FPictureNormal write SetPictureNormal;
    property PictureHot: TPicture read FPictureHot write SetPictureHot;
    property PictureDown: TPicture read FPictureDown write SetPictureDown;
    property PictureDisabled: TPicture read FPictureDisabled
      write SetPictureDisabled;

  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TImgBtn]);
end;

constructor TImgBtn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTransparent := True;
  Self.Width := 40;
  Self.Height := 40;
  Self.Caption := '';
  Self.BevelOuter := bvNone;
  Self.ParentColor := True;
  FPictureNormal := TPicture.Create;
  FPictureHot := TPicture.Create;
  FPictureDown := TPicture.Create;
  FPictureDisabled := TPicture.Create;
  FPictureNormal.OnChange := PictureChanged;
  FPictureHot.OnChange := PictureChanged;
  FPictureDown.OnChange := PictureChanged;
  FPictureDisabled.OnChange := PictureChanged;
  FPicture := FPictureNormal;
end;

destructor TImgBtn.Destroy;
begin
  FPictureNormal.Free;
  FPictureNormal := nil;
  FPictureHot.Free;
  FPictureHot := nil;
  FPictureDown.Free;
  FPictureDown := nil;
  FPictureDisabled.Free;
  FPictureDisabled := nil;
  inherited Destroy;
end;

procedure TImgBtn.Paint;
begin
  if Assigned(FPicture.Graphic) then
  begin
    if Width <> FPicture.Width then
      Width := FPicture.Width;
    if Height <> FPicture.Height then
      Height := FPicture.Height;
    if FPicture.Graphic.Transparent <> FTransparent then
      FPicture.Graphic.Transparent := FTransparent;
    Canvas.Brush.Style := bsClear;
    Canvas.Draw(0, 0, FPicture.Graphic);
  end
  else
    inherited Paint;
end;

procedure TImgBtn.SetTransparent(Value: Boolean);
begin
  FTransparent := Value;
  Repaint;
end;

procedure TImgBtn.SetEnabled(Value: Boolean);
begin
  if Value then
    FPicture := FPictureNormal
  else
    FPicture := FPictureDisabled;
  Repaint;
  inherited SetEnabled(Value);
end;

procedure TImgBtn.PictureChanged(Sender: TObject);
begin
  Repaint;
end;

procedure TImgBtn.SetPictureNormal(Value: TPicture);
begin
  if Enabled then
    FPicture := FPictureNormal;
  FPictureNormal.Assign(Value);
end;

procedure TImgBtn.SetPictureHot(Value: TPicture);
begin
  FPictureHot.Assign(Value);
end;

procedure TImgBtn.SetPictureDown(Value: TPicture);
begin
  FPictureDown.Assign(Value);
end;

procedure TImgBtn.SetPictureDisabled(Value: TPicture);
begin
  if not Enabled then
    FPicture := FPictureDisabled;
  FPictureDisabled.Assign(Value);
end;

procedure TImgBtn.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X: Integer; Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if Button = mbLeft then
    if Enabled then
      if Assigned(FPictureDown.Graphic) then
      begin
        FPicture := FPictureDown;
        Repaint;
      end;
end;

procedure TImgBtn.MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer;
  Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if Enabled then
  begin
    if (X > 0) and (Y > 0) and (X < Width) and (Y < Height) and
      (Assigned(FPictureHot.Graphic)) then
      FPicture := FPictureHot
    else
      FPicture := FPictureNormal;
    Repaint;
  end;
end;

procedure TImgBtn.CMMouseEnter(var msg: TMessage);
begin
  inherited;
  if Enabled then
    if Assigned(FPictureHot.Graphic) then
    begin
      FPicture := FPictureHot;
      Repaint;
    end;
end;

procedure TImgBtn.CMMouseLeave(var msg: TMessage);
begin
  inherited;
  if Enabled then
  begin
    FPicture := FPictureNormal;
    Repaint;
  end;
end;

end.
