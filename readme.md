# henkakuaid

This is a simple pascal application that calls henkaku web page with the AID you use as first parameter and retrives your *random* number.
If some problem is found returns a -1 %ERRORLEVEL%

## usage

Usage: henkakuaid.exe aid
       aid: The AID number

Example: henkakuaid.exe 1111111111111111

## Execution example

```
C:\>henkakuaid.exe 1111111111111111
527e0200d0a80134d56f8ac24d5a0d742e2eb325e7bd69b1be3219b7c6245905

```

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
