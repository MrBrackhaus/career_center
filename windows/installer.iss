#define MyAppName "Bewerbungszentrale"
; Version kann im CI per iscc /DMyAppVersion=<ver> gesetzt werden
; (wird aus pubspec.yaml gelesen). Ohne Angabe gilt dieser Standardwert.
#ifndef MyAppVersion
  #define MyAppVersion "0.9.2"
#endif
#define MyAppPublisher "MrBrackhaus"
#define MyAppExeName "career_center.exe"
; Muss mit dem Mutex-Namen in windows/runner/main.cpp übereinstimmen.
#define MyAppMutex "Bewerbungszentrale_SingleInstance_Mutex"

[Setup]
AppId={{D1B3A0D1-2C5E-4B9A-9B3E-7D8E9F0A1B2C}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={localappdata}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=..\
OutputBaseFilename=CareerCenter-Setup
Compression=lzma2
SolidCompression=yes
PrivilegesRequired=lowest
SetupIconFile=runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
; Erkennt eine laufende App-Instanz (Single-Instance-Mutex aus main.cpp).
AppMutex={#MyAppMutex}

[Languages]
Name: "german"; MessagesFile: "compiler:Languages\German.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\build\windows\x64\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\browser_extension\*"; DestDir: "{app}\browser_extension"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
; Kein "skipifsilent": Das Auto-Update startet den Installer mit /SILENT und
; die App muss danach wieder starten. Bei /VERYSILENT (z.B. Verteilung per
; Skript) wird die App bewusst nicht automatisch gestartet.
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall; Check: not IsVerySilent

[Code]
// True, wenn Setup mit /VERYSILENT gestartet wurde (kompatibel mit allen
// Inno-Setup-6-Versionen, ohne auf neuere Hilfsfunktionen angewiesen zu sein).
function IsVerySilent(): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 1 to ParamCount do
    if CompareText(ParamStr(I), '/VERYSILENT') = 0 then
    begin
      Result := True;
      Exit;
    end;
end;
