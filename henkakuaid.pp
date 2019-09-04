program henkakuaid;
{$mode delphi}{$ifdef windows}{$apptype console}{$endif}
uses
  Classes, SysUtils, fphttpclient, RegexPr;

function getNumber(URL : string; AID : string; IPRegex: TRegExpr) : string;
var
  HTTPClient: TFPHTTPClient;
  RawData: string;
  EndURL : string;
  emsg: string;
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
            emsg := 'Got invalid results getting data. Details:' + LineEnding + RawData;
			raise Exception.Create(emsg);
          end;
    except
      on E: Exception do
      begin
        emsg := 'Error retrieving data: ' + E.Message;
		raise Exception.Create(emsg);
      end;
    end;
  finally
    HTTPClient.Free;
  end;
end;

procedure usage;
begin
  WriteLn(stderr, 'Usage: ' + ParamStr(0) + ' aid');
  WriteLn(stderr, '       aid: The AID number');
  WriteLn(stderr, '');
  WriteLn(stderr, 'Example: ' + ParamStr(0) + ' 1111111111111111');
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
    try
      IPRegex := TRegExpr.Create;
      IPRegex.Expression := RegExprString('<b>[^<^]*</b>: ([1234567890abcdef]*)');
      // TODO : Externalizar URL a un fichero de config o leer de parametro
      WriteLn(getNumber('http://cma.henkaku.xyz/', AID, IPRegex));
    except
      on E: Exception do begin
        WriteLn(E.Message);
        halt(-1); // %ERRORLEVEL%
	  end;
	end;
  finally
    IPRegex.Free;
  end;
end.
