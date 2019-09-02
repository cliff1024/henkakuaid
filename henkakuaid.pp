program henkakuaid;
{$mode delphi}{$ifdef windows}{$apptype console}{$endif}
uses
  Classes, SysUtils, fphttpclient, RegexPr;

function getNumber(URL : string; AID : string; IPRegex: TRegExpr) : string;
var
  HTTPClient: TFPHTTPClient;
  RawData: string;
  EndURL : string;
begin
  try
    HTTPClient := TFPHTTPClient.Create(nil);
    try
        EndURL := URL + '?aid=' + aid;
        //WriteLn('EndURL: ' + EndURL);
        RawData := HTTPClient.Get(EndURL);
        if IPRegex.Exec(RawData) then
          begin
            result := IPRegex.Match[1];
          end else begin
            result := 'Got invalid results getting data. Details:' + LineEnding + RawData;
          end;
    except
      on E: Exception do
      begin
        result := 'Error retrieving data: ' + E.Message;
      end;
    end;
  finally
    HTTPClient.Free;
  end;
end;

procedure usage;
begin
  WriteLn('Usage: ' + ParamStr(0) + ' aid');
  WriteLn('       aid: The AID number');
  WriteLn('');
  WriteLn('Example: ' + ParamStr(0) + ' 1111111111111111');
end;

var
  IPRegex: TRegExpr;
  AID : string;
begin
  if (ParamCount <> 1) then begin
    usage();
    halt(-1); // %ERRORLEVEL%
  end;
  AID := ParamStr(1);
  // TODO : Validar AID
  try
    IPRegex := TRegExpr.Create;
    IPRegex.Expression := RegExprString('<b>[^<^]*</b>: ([1234567890abcdef]*)');
    // TODO : Externalizar URL a un fichero de config o leer de parametro
    WriteLn(getNumber('http://cma.henkaku.xyz/', AID, IPRegex));
  finally
    IPRegex.Free;
  end;
end.
