# henkakuaid

Aplicacion en pascal que automatiza el proceso de creación de la imagen del programa para explotar hencore2.

## Necesidades
Es necesario tener en el directorio actual los archivos preparados. Busca en youtube el video de NanospeedGamer con título "Nano-Hencore Psvita 3.72 & 3.71 - Instala H-ENCORE2 FÁCIL"
Deposita este ejecutable en el directorio de instalación del paquete y ejecútalo.
Automatiza los pasos 9 y 10 de la [guia](https://github.com/TheOfficialFloW/h-encore-2) además de obtener el AID (parte del paso 8)

## Execution example

```
C:\henkakuaid>henkakuaid.exe
AID: 1111111111111111
KEY: 527e0200d0a80134d56f8ac24d5a0d742e2eb325e7bd69b1be3219b7c6245905
psvimg-create.exe -n app -K 527e0200d0a80134d56f8ac24d5a0d742e2eb325e7bd69b1be3219b7c6245905 app PCSG90096/app
[...]
psvimg-create.exe -n appmeta -K 527e0200d0a80134d56f8ac24d5a0d742e2eb325e7bd69b1be3219b7c6245905 appmeta PCSG90096/appmeta
[...]
psvimg-create.exe -n license -K 527e0200d0a80134d56f8ac24d5a0d742e2eb325e7bd69b1be3219b7c6245905 license PCSG90096/license
[...]
psvimg-create.exe -n savedata -K 527e0200d0a80134d56f8ac24d5a0d742e2eb325e7bd69b1be3219b7c6245905 savedata PCSG90096/savedata
[...]
xcopy /E /Y /I PCSG90096 C:\Users\xxxxxxxxxxx\Documents\PS Vita\APP\1111111111111111\PCSG90096
PCSG90096\Nuevo documento de texto.txt
1 archivo(s) copiado(s)```

## Build

Clone and compile with [fpc](https://www.freepascal.org/)

```
C:\henkakuaid>fpc henkakuaid.pp
Free Pascal Compiler version 3.0.4 [2017/10/06] for i386
Copyright (c) 1993-2017 by Florian Klaempfl and others
Target OS: Win32 for i386
Compiling henkakuaid.pp
Linking henkakuaid.exe
61 lines compiled, 0.2 sec, 199120 bytes code, 9332 bytes data
```

## Creditos
[NanospeedGamer](https://twitter.com/NanospeedGamer) por la creacion del paquete
[TheFloW](https://twitter.com/theflow0) por [h-encore-2](https://github.com/TheOfficialFloW/h-encore-2)