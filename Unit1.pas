unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListBox,
  FMX.ScrollBox, FMX.Memo, FMX.Effects, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Stan.StorageBin, System.ImageList, FMX.ImgList, FMX.BufferedLayout,
  FMX.Edit, FMX.Memo.Types, FMX.MultiView, Data.Bind.EngExt, Fmx.Bind.DBEngExt,
  System.Rtti, System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.Components,
  Data.Bind.DBScope, FMX.DialogService.Async, FMX.Objects;

type
  TMainForm = class(TForm)
    StoryHSB: THorzScrollBox;
    Layout1: TLayout;
    ScrollLeftButton: TButton;
    ScrollRightButton: TButton;
    MaterialOxfordBlueSB: TStyleBook;
    ToolBar1: TToolBar;
    ShadowEffect4: TShadowEffect;
    Label1: TLabel;
    FeedVSB: TVertScrollBox;
    FeedMT: TFDMemTable;
    StoryMT: TFDMemTable;
    Label2: TLabel;
    GenerateButton: TButton;
    ImageList1: TImageList;
    Layout2: TLayout;
    PredictionMemo: TMemo;
    PromptMemo: TMemo;
    EmptyVSBLayout: TLayout;
    MultiView1: TMultiView;
    MaxTokensMemo: TMemo;
    Label3: TLabel;
    TemplateMT: TFDMemTable;
    VComboBox: TComboBox;
    VersionMT: TFDMemTable;
    VersionEdit: TEdit;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkListControlToField1: TLinkListControlToField;
    LinkControlToField1: TLinkControlToField;
    Label4: TLabel;
    Label5: TLabel;
    LinkPropertyToFieldText: TLinkPropertyToField;
    SaveDialog: TSaveDialog;
    APIKeyButton: TButton;
    NewSessionButton: TButton;
    SessionsMT: TFDMemTable;
    BindSourceDB2: TBindSourceDB;
    LinkListControlToField2: TLinkListControlToField;
    EnhanceMemo: TMemo;
    Layout3: TLayout;
    ConvoListBox: TListBox;
    ProviderLabel: TLabel;
    LinkPropertyToFieldText2: TLinkPropertyToField;
    OAPredictionMemo: TMemo;
    APIKeyPanel: TPanel;
    APIKeyEdit: TEdit;
    OAAPIKeyEdit: TEdit;
    OAGPTPredictionMemo: TMemo;
    Label6: TLabel;
    Label7: TLabel;
    Layout4: TLayout;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    procedure ScrollLeftButtonClick(Sender: TObject);
    procedure ScrollRightButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CameraButtonClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure APIKeyButtonClick(Sender: TObject);
    procedure NewSessionButtonClick(Sender: TObject);
    procedure ConvoListBoxChange(Sender: TObject);
  private
    { Private declarations }
    RanOnce: Boolean;
  public
    { Public declarations }
    FId: String;
    FCircle: Integer;
    FCard: Integer;
    FSessionFile: String;
    procedure Restore;
    procedure AppIdle(Sender: TObject; var Done: Boolean);
    procedure NewSession(ASession: String);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
  System.Generics.Collections, System.Hash, System.IOUtils, uCircle, uCard, uDM;

procedure TMainForm.Restore;
var
  LCard: TCardFrame;
  LCircle: TCircleFrame;
  LStream: TStream;
  LScene: TLayout;
begin

  FeedMT.First;
  while not FeedMT.Eof do
    begin

      // With TScene Buffering
      LScene := TLayout.Create(Self);
      LCard := TCardFrame.Create(Self);
      LCard.Timer1.Enabled := False;
      LCard.ProgressBar.Visible := False;
      LCard.OutputMemo.Visible := True;
      LCard.Name := 'Card'+FCard.ToString;
      LCard.Align := TAlignLayout.Client;
      LCard.DataMT.DisableControls;
      LCard.DataMT.Append;
      LCard.DataMT.CopyRecord(FeedMT);
      LCard.DataMT.Post;
      LCard.DataMT.EnableControls;
      LCard.Position.Y := 999999999;
      LCard.NameLabel.AutoSize := True;
      LScene.Height := LCard.Height;
      LCard.Parent := LScene;
      LScene.Align := TAlignLayout.Top;
      LScene.Parent := FeedVSB;

      Inc(FCard);

      FeedMT.Next;
    end;
end;

procedure TMainForm.APIKeyButtonClick(Sender: TObject);
begin
  APIKeyPanel.Visible := not APIKeyPanel.Visible;
end;

procedure TMainForm.AppIdle(Sender: TObject; var Done: Boolean);
begin
  if not RanOnce then
    begin
      RanOnce := True;

      var LSessionFileName := THashMD5.GetHashString(SessionsMT.FieldByName('Name').AsString);
      FSessionFile := TPath.Combine(TPath.GetDocumentsPath,'aip_'+LSessionFileName+'.fds');
      if TFile.Exists(FSessionFile) then
      begin
        FeedMT.LoadFromFile(FSessionFile);
      end;

      Restore;
    end;
end;

procedure TMainForm.CameraButtonClick(Sender: TObject);
var
LProvider: String;
begin
  if APIKeyEdit.Text='' then
  begin
    ShowMessage('Enter your API key before continuing.');
    Exit;
  end;

  LProvider := ProviderLabel.Text;
  if LProvider='replicate' then
  begin

    // customize the JSON in PredictionMemo
    DM.RestRequest1.Params[0].Value := 'Token ' + APIKeyEdit.Text;
    DM.RestRequest1.Params[1].Value := PredictionMemo.Lines.Text.Replace('%prompt%',PromptMemo.Lines.Text)
    .Replace('%max_tokens%',MaxTokensMemo.Lines.Text)
    .Replace('%version%',VersionEdit.Text);

    DM.RestRequest1.Execute;
    FId := DM.FDMemTable1.FieldByName('id').AsWideString;

  end
  else
  if LProvider='openai' then
  begin
    FId := LProvider + '-'+THashMD5.GetHashString(DateTimeToStr(Now));
  end;

  var LScene := TLayout.Create(Self);
  var LCard := TCardFrame.Create(Self);
  LCard.Name := 'Card'+FCard.ToString;
  LCard.Hint := FId;
  LCard.FProvider := LProvider;
  LCard.FMainFeedMT := FeedMT;
  LCard.Align := TAlignLayout.Client;
  LCard.DataMT.DisableControls;
  LCard.DataMT.Append;
  LCard.DataMT.CopyRecord(TemplateMT);
  LCard.DataMT.FieldByName('Name').AsWideString := VersionMT.FieldByName('Name').AsString;
  LCard.DataMT.FieldByName('Description').AsWideString := PromptMemo.Lines.Text;
 // LCard.DataMT.FieldByName('Description').AsString := LOutput;
  LCard.DataMT.Post;
  LCard.DataMT.EnableControls;
  LCard.Position.Y := 999999999;
  LCard.NameLabel.AutoSize := True;
  LScene.Height := LCard.Height;
  LCard.Parent := LScene;
  LScene.Align := TAlignLayout.Top;
  LScene.Parent := FeedVSB;

  Inc(FCard);

end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  FeedMT.SaveToFile(FSessionFile);
  CanClose := True;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  if APIKeyEdit.Text<>'' then
   APIKeyPanel.Visible := False;

  if TFile.Exists(TPath.Combine(TPath.GetDocumentsPath,'aip_sessions.fds')) then
    SessionsMT.LoadFromFile(TPath.Combine(TPath.GetDocumentsPath,'aip_sessions.fds'));


  Application.OnIdle := AppIdle;
end;

procedure TMainForm.ConvoListBoxChange(Sender: TObject);
begin
  if RanOnce = True then
  begin
    FeedMT.SaveToFile(FSessionFile);
    FeedMT.EmptyDataSet;

    EmptyVSBLayout.Parent := MainForm;
    FeedVSB.Content.DeleteChildren;
    EmptyVSBLayout.Parent := FeedVSB;

    var LLoadSessionFile := THashMD5.GetHashString(ConvoListBox.Selected.ItemData.Text);
    FSessionFile := TPath.Combine(TPath.GetDocumentsPath,'aip_'+LLoadSessionFile+'.fds');
    if TFile.Exists(FSessionFile) then
    begin
      FeedMT.LoadFromFile(FSessionFile);
    end;

    Restore;
  end;

end;

procedure TMainForm.NewSession(ASession: String);
begin
  FeedMT.SaveToFile(FSessionFile);
  FeedMT.EmptyDataSet;

  EmptyVSBLayout.Parent := MainForm;
  FeedVSB.Content.DeleteChildren;
  EmptyVSBLayout.Parent := FeedVSB;

  FSessionFile := TPath.Combine(TPath.GetDocumentsPath,THashMD5.GetHashString(ASession)+'.fds');
  FeedMT.SaveToFile(FSessionFile);
  SessionsMT.AppendRecord([ASession]);
  SessionsMT.SaveToFile(TPath.Combine(TPath.GetDocumentsPath,'aip_sessions.fds'));
end;

procedure TMainForm.NewSessionButtonClick(Sender: TObject);
begin
 TDialogServiceAsync.InputQuery('Enter a new session name', ['Text:'], [''],
    procedure(const AResult: TModalResult; const AValues: array of string)
     begin
       case AResult of
        mrOk: begin
                var AValue := AValues[0];
                TThread.Synchronize(nil,procedure begin
                  NewSession(AValue);
                end);
              end;
       end;
     end);
end;

procedure TMainForm.ScrollLeftButtonClick(Sender: TObject);
begin
  StoryHSB.ScrollBy(Trunc(StoryHSB.Height*0.8), 0);
end;

procedure TMainForm.ScrollRightButtonClick(Sender: TObject);
begin
  StoryHSB.ScrollBy(-1*Trunc(StoryHSB.Height*0.8), 0);
end;

end.
