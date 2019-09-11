program henkakuaid;
{$mode delphi}{$ifdef windows}{$apptype console}{$endif}
uses
  Classes, SysUtils, fphttpclient, RegexPr, registry, strutils, Process;

const
  THIS : string = '.';
  PARENT : string = '..';
  EXENAME : string = 'psvimg-create.exe';

function getQCMAAppsPath() : string;
var
  appsPath: string = '';
  Registry: TRegistry;
begin
  Registry := TRegistry.Create;
  try
    // Navigate to proper "directory":
    Registry.RootKey := HKEY_CURRENT_USER;
    if Registry.OpenKeyReadOnly('\Software\codestation\qcma') then
      appsPath := Registry.ReadString('appsPath');
      result := appsPath;
  finally
    Registry.Free;
  end;
end;

function getAID(appsPath : string) : string;
var
  Info : TSearchRec;
  DN : String;
  nombre : string;
  directorios : TStringList;
  i : integer;
  selecc : string;
  nselect : integer;
begin
  // QCMA saves paths with unix slash
  DN := IncludeTrailingPathDelimiter(appsPath);
  if FindFirst(DN+AllFilesMask,faDirectory,Info) = 0 then
    try
      directorios := TStringList.Create;
      Repeat
        nombre := Info.Name;
        if ((THIS <> nombre) and (PARENT <> nombre)) then begin
          directorios.add(nombre);
        end;
      Until FindNext(Info) <> 0;

      if (directorios.count = 0) then begin
        result := '';
      end else if (directorios.count = 1) then begin
        result := directorios[0];
      end else begin
        // Hay varias opciones, el usuario tiene que elegir una
        for i := 0 to pred(directorios.count) do begin
          writeln(i:2, ' ', directorios[i]);
        end;
        write('Hay varias cuentas en el sitema, introduzca el numero que aparece a la izquierda de la cuenta que desea emplear y pulse intro (CTRL+C cancela el programa):');
        repeat
          readln(selecc);
          Try
            nselect := StrToInt(selecc);
          except
            On E : EConvertError do begin
              Write('N£mero incorrecto, introduzca el n£mero que aparece a la izquierda de la cuenta que desea emplear y pulse intro (CTRL+C cancela el programa):');
              selecc := '';
            end;
          end;
        until (selecc <> '');
        result := directorios[nselect];
      end;
    finally
      FindClose(info);
      if assigned(directorios) then begin
        directorios.free;
      end;
    end;
end;

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
      if IPRegex.Exec(RawData) then begin
        result := IPRegex.Match[1];
      end else begin
        emsg := 'Se ha obtenido un resultado no v lido. Detalles:' + LineEnding + RawData;
        raise Exception.Create(emsg);
      end;
    except
      on E: Exception do
      begin
        emsg := 'Error obteniendo informaci¢n: ' + E.Message;
        raise Exception.Create(emsg);
      end;
    end;
  finally
    HTTPClient.Free;
  end;
end;

function ejecutaComandoEnDir(base : string; exeName : string; params : array of string) : integer;
const
  BUF_SIZE = 4096;
var
  AProcess : TProcess;
  BytesRead : longint;
  Buffer : array[1..BUF_SIZE] of char;
  salida : string;
begin
  AProcess := TProcess.Create(nil);
  try
    AProcess.CurrentDirectory := base;
    AProcess.Executable := exeName;
    AProcess.Parameters.AddStrings(params);
    AProcess.Options := [poUsePipes];

    AProcess.Execute;

    repeat
      BytesRead := AProcess.Output.Read(Buffer, BUF_SIZE);
      salida :=  copy(Buffer, 1, BytesRead);
      write(salida);
    until BytesRead = 0;
    result := AProcess.ExitCode;
  finally
    AProcess.Free;
  end;
end;

procedure creaImagen(const base : string; const key : string);
var
  PARAM1 : array[0..5] of string = ('-n', 'app', '-K', '${KEY}', 'app', 'PCSG90096/app');
  PARAM2 : array[0..5] of string = ('-n', 'appmeta', '-K', '${KEY}', 'appmeta', 'PCSG90096/appmeta');
  PARAM3 : array[0..5] of string = ('-n', 'license', '-K', '${KEY}', 'license', 'PCSG90096/license');
  PARAM4 : array[0..5] of string = ('-n', 'savedata', '-K', '${KEY}', 'savedata', 'PCSG90096/savedata');
  s: integer;
begin
  PARAM1[3] := key;
  s := ejecutaComandoEnDir(base, EXENAME, PARAM1);
  if s <> 0 then begin
    writeln('Ha ocurrido un error al ejecutar el primer comando');
    halt(s);
  end;

  PARAM2[3] := key;
  s := ejecutaComandoEnDir(base, EXENAME, PARAM2);
  if s <> 0 then begin
    writeln('Ha ocurrido un error al ejecutar el segundo comando');
    halt(s);
  end;

  PARAM3[3] := key;
  s := ejecutaComandoEnDir(base, EXENAME, PARAM3);
  if s <> 0 then begin
    writeln('Ha ocurrido un error al ejecutar el tercer comando');
    halt(s);
  end;

  PARAM4[3] := key;
  s := ejecutaComandoEnDir(base, EXENAME, PARAM4);
  if s <> 0 then begin
    writeln('Ha ocurrido un error al ejecutar el cuarto comando');
    halt(s);
  end;
end;

var
  IPRegex: TRegExpr;
  AID : string;
  appsPath : string = '';
  key : string;
  base : string;
begin
  // Obtenemos la ruta del QCMA para consguir el account ID
  appsPath := getQCMAAppsPath();
  if appsPath <> '' then begin
    // Hemos conseguido la ruta del QCMA, tratemos de buscar el aid
    appsPath := ReplaceStr(appsPath + '/APP', '/', '\');
    AID := getAID(appsPath);
  end else begin
    WriteLn(stderr, 'No se puede encontrar la ruta del QCMA appsPath. ¨Est  instalado?');
    write('Escriba el AID y pulse intro:');
    readln(AID);
  end;
  writeln('AID: ' + AID);

  // TODO : Validar AID
  // Obtenemos la key de la web
  try
    try
      IPRegex := TRegExpr.Create;
      IPRegex.Expression := RegExprString('<b>[^<^]*</b>: ([1234567890abcdef]*)');
      // TODO : Externalizar URL a un fichero de config o leer de parametro
      key := getNumber('http://cma.henkaku.xyz/', AID, IPRegex);
      WriteLn('KEY: ' + key);
    except
      on E: Exception do begin
        WriteLn(E.Message);
        halt(-1); // %ERRORLEVEL%
    end;
  end;
  finally
    IPRegex.Free;
  end;

  // Invocamos a los programas para crear la imagen
  base := ExtractFilePath(ParamStr(0));
  creaImagen(base, key);

  // Copiamos el programa (si se puede)
  if appsPath <> '' then begin
    writeln('xcopy /E /Y /I PCSG90096 ' + appsPath + '\' + AID + '\PCSG90096');
    ejecutaComandoEnDir(base, 'c:\windows\system32\cmd.exe', ['/c', 'xcopy /E /Y /I PCSG90096 "' + appsPath + '\' + AID + '\PCSG90096"']);
  end else begin
    writeln('No he podido localizar la ruta de QCMA, tendras que copiar el directorio a mano');
    ejecutaComandoEnDir(base, 'c:\windows\system32\cmd.exe', ['/c', 'start .']);
  end;
  
  writeln('Una vez copiado el directorio de la imagen no olvides "refrescar base de datos" en Qcma');
end.
