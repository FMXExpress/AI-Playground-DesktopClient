unit uCard;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FMX.Controls.Presentation, Data.Bind.EngExt, Fmx.Bind.DBEngExt, System.Rtti,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.Components,
  Data.Bind.DBScope, FMX.ImgList, REST.Types, REST.Client,
  REST.Response.Adapter, Data.Bind.ObjectScope, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent, FMX.Platform,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FireDAC.Stan.StorageBin;

type
  TCardFrame = class(TFrame)
    Layout1: TLayout;
    FeedImage: TImage;
    Layout2: TLayout;
    MenuButton: TButton;
    ProfileCircle: TCircle;
    NameLabel: TLabel;
    Layout3: TLayout;
    DownloadButton: TButton;
    LoveButton: TButton;
    CommentButton: TButton;
    GoButton: TButton;
    DescLabel: TLabel;
    FollowButton: TButton;
    TimeLabel: TLabel;
    DataMT: TFDMemTable;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkPropertyToFieldFillBitmapBitmap: TLinkPropertyToField;
    LinkPropertyToFieldText: TLinkPropertyToField;
    LinkPropertyToFieldText4: TLinkPropertyToField;
    LinkPropertyToFieldText5: TLinkPropertyToField;
    LinkPropertyToFieldBitmap: TLinkPropertyToField;
    Glyph1: TGlyph;
    Glyph2: TGlyph;
    Glyph3: TGlyph;
    Timer1: TTimer;
    RESTRequest2: TRESTRequest;
    FDMemTable2: TFDMemTable;
    RESTResponseDataSetAdapter2: TRESTResponseDataSetAdapter;
    RESTResponse2: TRESTResponse;
    RESTClient2: TRESTClient;
    NetHTTPClient1: TNetHTTPClient;
    ProgressBar: TProgressBar;
    Layout4: TLayout;
    Line1: TLine;
    Timer2: TTimer;
    EditPromptButton: TButton;
    CopyResponseButton: TButton;
    CopyLabelButton: TButton;
    OutputMemo: TMemo;
    LinkControlToField1: TLinkControlToField;
    LLMLabel: TLabel;
    LinkPropertyToFieldText2: TLinkPropertyToField;
    CopyPromptResponseButton: TButton;
    CopyPromptButton: TButton;
    OAIRESTResponse: TRESTResponse;
    OAIMemTable: TFDMemTable;
    OAIRESTResponseDataSetAdapter: TRESTResponseDataSetAdapter;
    OAIRESTRequest: TRESTRequest;
    OAIRESTClient: TRESTClient;
    Layout5: TLayout;
    procedure FollowButtonClick(Sender: TObject);
    procedure LoveButtonClick(Sender: TObject);
    procedure CommentButtonClick(Sender: TObject);
    procedure GoButtonClick(Sender: TObject);
    procedure DownloadButtonClick(Sender: TObject);
    procedure CommentsLabelClick(Sender: TObject);
    procedure ProfileCircleClick(Sender: TObject);
    procedure FeedImageDblClick(Sender: TObject);
    procedure FrameResize(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure EditPromptButtonClick(Sender: TObject);
    procedure CopyResponseButtonClick(Sender: TObject);
    procedure CopyLabelButtonClick(Sender: TObject);
    procedure CopyPromptResponseButtonClick(Sender: TObject);
    procedure CopyPromptButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FMainFeedMT: TFDMemTable;
    FProvider: String;
  end;

implementation

{$R *.fmx}

uses
  Unit1, System.Threading, System.DateUtils, IdHashMessageDigest, System.IOUtils,
  System.JSON, uDM;

procedure TextToClipboard(const AString: String);
var
  clp: IFMXClipboardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService) then
  begin
    clp := IFMXClipboardService(TPlatformServices.Current.GetPlatformService(IFMXClipboardService));
    clp.SetClipboard(AString);
  end;
end;

function SaveControl(AControl: TControl): String;
var
  LMS: TMemoryStream;
  LSS: TStringStream;
  LName: string;
begin
  LName := AControl.Name;
  AControl.Name := '';
  AControl.Visible := True;
  try
    LMS := TMemoryStream.Create;
    try
      LMS.WriteComponent(AControl);
      LMS.Position := 0;
      LSS := TStringStream.Create;
      try
        ObjectBinaryToText(LMS, LSS);
        Result := LSS.DataString;
      finally
        LSS.Free;
      end;
    finally
      LMS.Free;
    end;
  finally
    AControl.Visible := False;
    AControl.Name := LName;
  end;
end;

function MD5(const AString: String): String;
var
  LHash: TIdHashMessageDigest5;
begin
  LHash := TIdHashMessageDigest5.Create;
  try
    Result := LHash.HashStringAsHex(AString);
  finally
    LHash.Free;
  end;
end;

procedure TCardFrame.DownloadButtonClick(Sender: TObject);
begin
  // Download
  MainForm.SaveDialog.FileName := DescLabel.Text + '.png';
  if MainForm.SaveDialog.Execute then
  begin
    FeedImage.Bitmap.SaveToFile(MainForm.SaveDialog.FileName);
  end;
end;

procedure TCardFrame.EditPromptButtonClick(Sender: TObject);
begin
  MainForm.PromptMemo.Lines.Text := DescLabel.Text;
end;

procedure TCardFrame.CommentButtonClick(Sender: TObject);
begin
  // Comment
end;

procedure TCardFrame.CommentsLabelClick(Sender: TObject);
begin
  // View Comments
end;

procedure TCardFrame.CopyLabelButtonClick(Sender: TObject);
begin
  TextToClipboard(SaveControl(LLMLabel));
end;

procedure TCardFrame.CopyPromptButtonClick(Sender: TObject);
begin
  TextToClipboard(DescLabel.Text);
end;

procedure TCardFrame.CopyPromptResponseButtonClick(Sender: TObject);

begin
  TextToClipboard(DescLabel.Text + #13#10 + OutputMemo.Lines.Text);
end;

procedure TCardFrame.CopyResponseButtonClick(Sender: TObject);
begin
  TextToClipboard(OutputMemo.Lines.Text);
end;

procedure TCardFrame.FeedImageDblClick(Sender: TObject);
begin
  // Double Tap Like
  LoveButtonClick(Sender);
end;

procedure TCardFrame.FollowButtonClick(Sender: TObject);
begin
  // Follow
end;

procedure TCardFrame.FrameResize(Sender: TObject);
begin
  FeedImage.Width := Self.Width;
end;

procedure TCardFrame.GoButtonClick(Sender: TObject);
begin
  // Go
end;

procedure TCardFrame.LoveButtonClick(Sender: TObject);
begin
  // Like
end;

procedure TCardFrame.ProfileCircleClick(Sender: TObject);
begin
  // View Profile
end;

function ConcatJSONStrings(const JSONArray: string): string;
var
  JSONData: TJSONArray;
  I: Integer;
begin
  if JSONArray[1]='[' then
  begin

  Result := '';
  JSONData := TJSONObject.ParseJSONValue(JSONArray) as TJSONArray;
  try
    for I := 0 to JSONData.Count - 1 do
      Result := Result + JSONData.Items[I].Value;
  finally
    JSONData.Free;
  end;
  end
  else
  Result := JSONArray;
end;

function ConcatJSONTexts(const JSONArray: string): string;
var
  JSONData: TJSONArray;
  JSONObj: TJSONObject;
  I: Integer;
begin
  Result := '';
  JSONData := TJSONObject.ParseJSONValue(JSONArray) as TJSONArray;
  try
    for I := 0 to JSONData.Count - 1 do
    begin
      JSONObj := JSONData.Items[I] as TJSONObject;
      Result := Result + JSONObj.GetValue<string>('text');
    end;
  finally
    JSONData.Free;
  end;
end;

function GetMessageContent(const JSONArray: string): string;
var
  JSONData: TJSONArray;
  MessageObj: TJSONObject;
begin
  Result := '';
  JSONData := TJSONObject.ParseJSONValue(JSONArray) as TJSONArray;
  try
    MessageObj := (JSONData.Items[0] as TJSONObject).GetValue<TJSONObject>('message');
    Result := MessageObj.GetValue<string>('content');
  finally
    JSONData.Free;
  end;
end;

procedure TCardFrame.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;

  if FProvider='replicate' then
  begin

    RESTRequest2.Params[0].Value := 'Token ' + MainForm.APIKeyEdit.Text;
    RESTRequest2.Resource := Self.Hint;
    RESTRequest2.Execute;
    var LStatus := FDMemTable2.FieldByName('status').AsWideString;

    if LStatus='succeeded' then
    begin
      var LOutput := ConcatJSONStrings(FDMemTable2.FieldByName('output').AsWideString);//.Replace('["','').Replace('"]','').Replace('\/','/');

      if LOutput<>'' then
      begin
        ProgressBar.Visible := False;
        OutputMemo.Visible := True;
        DataMT.Edit;
        DataMT.FieldByName('Output').AsString := LOutput;
        DataMT.FieldByName('Posted').AsDateTime := Now;
        DataMT.Post;

        FMainFeedMT.Append;
        FMainFeedMT.CopyRecord(DataMT);
        FMainFeedMT.Post;
      end
      else
      begin
        OutputMemo.Visible := True;
        DataMT.Edit;
        DataMT.FieldByName('Output').AsWideString := 'failed';
        DataMT.Post;
        ProgressBar.Visible := False;
      end;

      Timer1.Enabled := False;
    end
    else
    begin
      if ProgressBar.Value=ProgressBar.Max then
        ProgressBar.Value := ProgressBar.Min
      else
        ProgressBar.Value := ProgressBar.Value+5;
      Timer1.Enabled := True;
    end;
  end
  else
  if (FProvider='openai') OR (FProvider='chatgpt') then
  begin
      TTask.Run(procedure begin
        try
          OAIRESTRequest.Params[0].Value := 'Bearer ' + MainForm.APIKeyEdit.Text;
          if (FProvider='openai') then
          begin
            OAIRESTClient.BaseURL := 'https://api.openai.com/v1/completions';
            OAIRESTRequest.Params[1].Value := MainForm.OAPredictionMemo.Lines.Text.Replace('%prompt%',MainForm.PromptMemo.Lines.Text)
            .Replace('%max_tokens%',MainForm.MaxTokensMemo.Lines.Text)
            .Replace('%model%',MainForm.VersionEdit.Text);
          end;
          if (FProvider='chatgpt') then
          begin
            OAIRESTClient.BaseURL := 'https://api.openai.com/v1/chat/completions';
            OAIRESTRequest.Params[1].Value := MainForm.OAGPTPredictionMemo.Lines.Text.Replace('%prompt%',MainForm.PromptMemo.Lines.Text)
            .Replace('%max_tokens%',MainForm.MaxTokensMemo.Lines.Text)
            .Replace('%model%',MainForm.VersionEdit.Text);
          end;

          OAIRESTRequest.Execute;

          TThread.Synchronize(nil,procedure begin
            Self.Hint := OAIMemTable.FieldByName('id').AsWideString;
            var LChoices := '';
            if (FProvider='openai') then
              LChoices := ConcatJSONTexts(OAIMemTable.FieldByName('choices').AsWideString);
            if (FProvider='chatgpt') then
              LChoices := GetMessageContent(OAIMemTable.FieldByName('choices').AsWideString);
            if LChoices<>'' then
            begin
              OutputMemo.Visible := True;
              DataMT.Edit;
              DataMT.FieldByName('Output').AsString := LChoices;
              DataMT.FieldByName('Posted').AsDateTime := Now;
              DataMT.Post;

              FMainFeedMT.Append;
              FMainFeedMT.CopyRecord(DataMT);
              FMainFeedMT.Post;
            end
            else
            begin
              OutputMemo.Visible := True;
              DataMT.Edit;
              DataMT.FieldByName('Output').AsWideString := 'failed';
              DataMT.Post;
            end;

          end);
        finally

          TThread.Synchronize(nil,procedure begin
            ProgressBar.Visible := False;
            //StatusLabel.Text := 'Status: ' + LStatus;
          end);
        end;
      end);
  end;

end;

procedure TCardFrame.Timer2Timer(Sender: TObject);
begin
  if ProgressBar.Visible = False then
  begin
    Timer2.Enabled := False;
  end
  else
  begin
    if ProgressBar.Value=ProgressBar.Max then
      ProgressBar.Value := ProgressBar.Min
    else
      ProgressBar.Value := ProgressBar.Value+5;
  end;
end;

end.
