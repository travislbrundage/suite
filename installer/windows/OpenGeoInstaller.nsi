; OpenGeo Suite Windows installer creation file

; Define your application name
!define COMPANYNAME "OpenGeo"
!define APPNAME "OpenGeo Suite"
!define VERSION "1.0-SNAPSHOT"
!define LONGVERSION "1.0.0.1" ; must be a.b.c.d
!define APPNAMEANDVERSION "${APPNAME} ${VERSION}"
!define SOURCEPATHROOT "..\..\target\opengeosuite-1.0-SNAPSHOT-win"
!define STARTMENU_FOLDER "${APPNAMEANDVERSION}"

; Main Install settings
Name "${APPNAMEANDVERSION}"
InstallDir "$PROGRAMFILES\${COMPANYNAME}\${APPNAMEANDVERSION}"
InstallDirRegKey HKLM "Software\${COMPANYNAME}\${APPNAMEANDVERSION}" ""
OutFile "OpenGeoSuite-${VERSION}.exe"

;Compression options
CRCCheck on

; This is the gray text on the bottom left of the installer.
BrandingText " " ; blank

; Hide the "Show details" button during the install/uninstall
ShowInstDetails nevershow
ShowUninstDetails nevershow

; For Vista
RequestExecutionLevel admin

; Includes
!include "MUI.nsh" ; Modern interface settings
!include "StrFunc.nsh" ; String functions
!include "LogicLib.nsh" ; ${If} ${Case} etc.
!include "nsDialogs.nsh" ; For Custom page layouts (Radio buttons etc)
!include "WordFunc.nsh" ; For VersionCompare

; WARNING!!! These plugins need to be installed spearately

; See http://nsis.sourceforge.net/ModernUI_Mod_to_Display_Images_while_installing_files
!include "Image.nsh" ; For graphics during the install 

; http://nsis.sourceforge.net/TextReplace_plugin
!include "TextReplace.nsh" ; For text replacing

; AccessControl plugin needed as well for permissions changes
; See http://nsis.sourceforge.net/AccessControl_plug-in

; See http://nsis.sourceforge.net/Dialogs_plug-in
; Needs Dialogs.dll!
!include "defines.nsh" ; For nice UI-file/folder dialogs


; Might be the same as !define
Var STARTMENU_FOLDER
;Var CommonAppData
;Var DataDirPath
;Var FolderName
;Var SDEPath
;Var SDEPathTemp
;Var SDEPathCheck
Var SDECheckBox
Var SDECheckBoxPrior
Var OracleCheckBox
Var OracleCheckBoxPrior
;Var SDEPathHWND
;Var BrowseSDEHWND

; Version Information (Version tab for EXE properties)
VIProductVersion ${LONGVERSION}
VIAddVersionKey ProductName "${APPNAME}"
VIAddVersionKey CompanyName "OpenGeo"
VIAddVersionKey LegalCopyright "Copyright (c) 2001 - 2010 OpenGeo"
VIAddVersionKey FileDescription "OpenGeo Suite Installer"
VIAddVersionKey ProductVersion "${VERSION}"
VIAddVersionKey FileVersion "${VERSION}"
VIAddVersionKey Comments "http://opengeo.org"

; Page headers for pages
;LangString TEXT_ARCSDE_TITLE ${LANG_ENGLISH} "ArcSDE Libraries"
;LangString TEXT_ARCSDE_SUBTITLE ${LANG_ENGLISH} "Link to your existing ArcSDE libraries."
;LangString TEXT_ORACLE_TITLE ${LANG_ENGLISH} "Oracle Libraries"
;LangString TEXT_ORACLE_SUBTITLE ${LANG_ENGLISH} "Link to your existing Oracle libraries."
LangString TEXT_READY_TITLE ${LANG_ENGLISH} "Ready to Install"
LangString TEXT_READY_SUBTITLE ${LANG_ENGLISH} "OpenGeo Suite is ready to be installed."

; Interface Settings
!define MUI_ICON "opengeo.ico"
!define MUI_UNICON "uninstall.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_RIGHT
!define MUI_HEADERIMAGE_BITMAP header.bmp
!define MUI_WELCOMEFINISHPAGE_BITMAP side_left.bmp

; Start Menu Folder Page Configuration
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKLM" 
!define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\${COMPANYNAME}\${APPNAMEANDVERSION}" 
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"

; "Are you sure you wish to cancel" dialog.
!define MUI_ABORTWARNING

; Optional welcome text here
!define MUI_WELCOMEPAGE_TEXT "Welcome to the OpenGeo Suite.\r\n\r\n\
                              We recommend that you close all other applications before starting Setup.\r\n\r\n\
	                          Click Next to continue."

; What to do when done
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "Start the OpenGeo Suite and launch the Dashboard"
!define MUI_FINISHPAGE_RUN_FUNCTION "RunAfterInstall"


; Do things after install
Function RunAfterInstall

  IfSilent SilentSkip

  ;Start Suite
  ExecWait '"$INSTDIR\opengeo-suite.bat" start'

  ClearErrors
  ExecShell "open" "$INSTDIR\dashboard\OpenGeo Dashboard.exe" SW_SHOWMAXIMIZED
  IfErrors 0 +2
    MessageBox MB_ICONSTOP "Unable to start the OpenGeo Suite or launch the Dashboard.  Please use the Start Menu to manually start these applications."
  ClearErrors

  SilentSkip:

FunctionEnd


; Install Page order
; This is the main list of installer pages
!insertmacro MUI_PAGE_WELCOME                                 ; Hello
Page custom CheckUserType                                     ; Die if not admin
Page custom PriorInstall                                      ; Check to see if previously installed
!insertmacro MUI_PAGE_LICENSE "..\common\license.txt"         ; Show license
!insertmacro MUI_PAGE_DIRECTORY                               ; Where to install
!insertmacro MUI_PAGE_STARTMENU Application $STARTMENU_FOLDER ; Start menu location
!insertmacro MUI_PAGE_COMPONENTS                              ; List of stuff to install
;Page custom GetSDE                                            ; Look for exisitng ArcSDE library
;Page custom SDE SDELeave                                      ; Set the ArcSDE Path
;Page custom GetOracle                                        ; Look for exisitng Oracle library
;Page custom Oracle OracleLeave                               ; Set the Oracle Path
Page custom Ready
!insertmacro MUI_PAGE_INSTFILES                               ; Actually do the install
!insertmacro MUI_PAGE_FINISH                                  ; Done

; Uninstall Page order
!insertmacro MUI_UNPAGE_CONFIRM   ; Are you sure you wish to uninstall?
!insertmacro MUI_UNPAGE_INSTFILES ; Do the uninstall
;!insertmacro MUI_UNPAGE_FINISH    ; Done

; Set languages (first is default language)
!insertmacro MUI_LANGUAGE "English"
;!insertmacro MUI_LANGUAGE "French"

; Makes the installer code at the top of the .EXE making loading faster, apparently
!insertmacro MUI_RESERVEFILE_LANGDLL


; Startup tasks
Function .onInit

  ; Init vars
  StrCpy $SDECheckBoxPrior 0
  StrCpy $OracleCheckBoxPrior 0

  IfSilent SilentSkip


  ; Splash screen
  SetOutPath $TEMP
  File /oname=spltmp.bmp "splash.bmp" ; transparent splash
  advsplash::show 2500 500 500 0xEC008C $TEMP\spltmp
  ;advsplash::show Delay FadeIn FadeOut KeyColor FileName
  Pop $0 ; '1' if the user closed the splash screen early
         ; '0' if everything closed normally
         ; '-1' if some error occurred.
  Delete $TEMP\spltmp.bmp

  SilentSkip:


FunctionEnd


; Check the user type, and quit if it's not an administrator.
; Taken from Examples/UserInfo that ships with NSIS.
Function CheckUserType
  ClearErrors
  UserInfo::GetName
  IfErrors Win9x
  Pop $0
  UserInfo::GetAccountType
  Pop $1
  StrCmp $1 "Admin" Admin NoAdmin

  NoAdmin:
    MessageBox MB_ICONSTOP "Sorry, you must have administrative rights in order to install the OpenGeo Suite."
    Quit

  Win9x:
    MessageBox MB_ICONSTOP "Sorry, this installer is not supported on Windows 9x/ME."
    Quit
		
  Admin:
	
FunctionEnd


; Checks for existing versions
Function PriorInstall

  ClearErrors

  ; Is this version already installed?
  ReadRegStr $R1 HKLM "Software\${COMPANYNAME}\${APPNAMEANDVERSION}" "InstallDir"
  IfErrors NoPriorInstall ; This specific version is not installed

  ClearErrors
  ; Fail!  This exact version is installed!

  MessageBox MB_ICONSTOP "Setup has found this version (${VERSION}) of the OpenGeo Suite \
                          installed on your machine.  If you wish to reinstall the \
                          OpenGeo Suite, please uninstall first.  After you have \
                          uninstalled, you may run Setup again.$\r$\n$\r$\nPlease note that \
                          it is also possible to run different versions of the OpenGeo Suite \
                          on your machine simultaneously."
  MessageBox MB_OK "Setup will now exit..."
  Quit

  NoPriorInstall:
  ClearErrors

FunctionEnd


; Calls path function only if it hasn't called it before
/*
Function GetSDE

  ; Skip if box unchecked
  StrCmp $SDECheckBox 1 0 Skip

  ; as this function been run before?
  StrCmp $SDEPath "" 0 Skip 
  ClearErrors
  ReadRegStr $0 HKLM "SOFTWARE\ESRI\ArcInfo\ArcSDE\8.0\ArcSDE Java SDK" "InstallDir"
  IfErrors NoSDE
  StrCpy $0 $0 -1 ; remove trailing slash
  IfFileExists "$0\arcsde\lib" 0 NoSDE
  StrCpy $SDEPath "$0\arcsde\lib"
  IfFileExists "$SDEPath\jsde*.jar" 0 NoSDE
  IfFileExists "$SDEPath\jpe*.jar" Success NoSDE

  NoSDE:
  StrCpy $SDEPath ""

  Success: 
  ClearErrors
  StrCpy $0 ""

  Skip:  

FunctionEnd
*/

/*
Function SDE

  ; Skip if box unchecked
  StrCmp $SDECheckBox 1 0 Skip

  !insertmacro MUI_HEADER_TEXT "$(TEXT_ARCSDE_TITLE)" "$(TEXT_ARCSDE_SUBTITLE)"

  StrCpy $SDEPathTemp $SDEPath

  Call SDEPathValidInit
  Pop $8

  nsDialogs::Create 1018

  ; ${NSD_Create*} x y width height text
  ${NSD_CreateLabel} 0 0 100% 48u "You have elected to install the GeoServer ArcSDE extension.  GeoServer requires libraries from an existing ArcSDE installation to proceed.  The files required are named jsde*.jar and jpe*.jar. $\r$\n$\r$\nPlease select the path to your ArcSDE Java SDK library path or click Back to unselect the ArcSDE extension."

  ${NSD_CreateDirRequest} 0 70u 240u 13u $SDEPathTemp
  Pop $SDEPathHWND
  ${NSD_OnChange} $SDEPathHWND SDEPathValid
  Pop $9

  ${NSD_CreateBrowseButton} 242u 70u 50u 13u "Browse..."
  Pop $BrowseSDEHWND
  ${NSD_OnClick} $BrowseSDEHWND BrowseSDE

  ${NSD_CreateLabel} 0 86u 100% 12u " "
  Pop $SDEPathCheck

  ${If} $8 == "validSDE"
    ${NSD_SetText} $SDEPathCheck "This path contains a valid ArcSDE library"
    GetDlgItem $0 $HWNDPARENT 1 ; Next
    EnableWindow $0 1 ; Turns on
  ${EndIf}
  ${If} $8 == "novalidSDE"
    ${NSD_SetText} $SDEPathCheck "This path does not contain a valid ArcSDE library"
    GetDlgItem $0 $HWNDPARENT 1 ; Next
    EnableWindow $0 0 ; Turns off
  ${EndIf}
   
  nsDialogs::Show

  Skip:  

FunctionEnd
*/

; Runs when page is initialized
/*
Function SDEPathValidInit

    IfFileExists "$SDEPath\jsde*.jar" 0 Errors
    IfFileExists "$SDEPath\jpe*.jar" NoErrors Errors

    NoErrors:
    StrCpy $8 "validSDE"
    Goto End

    Errors:
    StrCpy $8 "novalidSDE"
    
    End:
    Push $8

FunctionEnd
*/

; Runs in real time
/*
Function SDEPathValid

  Pop $8
  ${NSD_GetText} $8 $SDEPathTemp

    IfFileExists "$SDEPathTemp\jsde*.jar" 0 Errors
    IfFileExists "$SDEPathTemp\jpe*.jar" NoErrors Errors

  NoErrors:
    ${NSD_SetText} $SDEPathCheck "This path contains a valid ArcSDE library"
    GetDlgItem $0 $HWNDPARENT 1 ; Next
    EnableWindow $0 1 ; Enable
  Goto End

  Errors:
    ${NSD_SetText} $SDEPathCheck "This path does not contain a valid ArcSDE library"
    GetDlgItem $0 $HWNDPARENT 1 ; Next
    EnableWindow $0 0 ; Disable

  End:
    StrCpy $8 ""
    ClearErrors

FunctionEnd
*/

; Brings up folder dialog
/*
Function BrowseSDE

  nsDialogs::SelectFolderDialog "Please select the location of your ArcSDE library..." $PROGRAMFILES
  Pop $1
  ${NSD_SetText} $SDEPathHWND $1
    
FunctionEnd
*/

; When done, set variable permanently
/*
Function SDELeave

  StrCpy $SDEPath $SDEPathTemp

FunctionEnd
*/


; Custom page, last page before install
Function Ready

  IfSilent SilentSkip

  nsDialogs::Create 1018
  !insertmacro MUI_HEADER_TEXT "$(TEXT_READY_TITLE)" "$(TEXT_READY_SUBTITLE)"

  ;Syntax: ${NSD_*} x y width height text
  ${NSD_CreateLabel} 10u 10u 90% 36u "Setup has all the information required to install the OpenGeo Suite.  Click the Install button to continue."

  nsDialogs::Show

  SilentSkip:

FunctionEnd


; Install Prerequisites if necessary
Section -Prerequisites

; No prereqs.

SectionEnd


; The webapp container
Section "-Jetty" SectionJetty ; dash = hidden

  SectionIn RO  ; Mandatory
  SetOverwrite on ; Set Section properties

  !insertmacro DisplayImage "slide_1_suite.bmp"

  SetOutPath "$INSTDIR"
  File /a "${SOURCEPATHROOT}\*.jar" ; custom startup jars
  File /r  "${SOURCEPATHROOT}\etc"
  File /r  "${SOURCEPATHROOT}\lib"
  File /r  "${SOURCEPATHROOT}\logs"
  File /r  "${SOURCEPATHROOT}\resources"
 
  ; Copy our own JRE (which includes native JAI)
  File /r "${SOURCEPATHROOT}\jre"

  File /a "${SOURCEPATHROOT}\opengeo-suite.bat" ; startup script
  ;${textreplace::ReplaceInFile} "$INSTDIR\opengeo-suite.bat" \
  ;                              "$INSTDIR\opengeo-suite.bat" \
  ;                              "@INSTDIR@" "$INSTDIR" \ 
  ;                              "/S=1" $1

  ; Create some dirs
  CreateDirectory "$INSTDIR\webapps"
  CreateDirectory "$INSTDIR\icons"
  SetOutPath "$INSTDIR\icons"
  File /a opengeo.ico
  File /a uninstall.ico
 
  CreateDirectory "$SMPROGRAMS\$STARTMENU_FOLDER"

SectionEnd

SectionGroup /e "Suite Services" SectionServices

Section "GeoServer" SectionGS

  SectionIn RO  ; Makes this install mandatory
  SetOverwrite on  

  !insertmacro DisplayImage "slide_3_geoserver.bmp"

  ; Copy GeoServer
  SetOutPath "$INSTDIR\webapps"
  File /r /x jai*.* "${SOURCEPATHROOT}\webapps\geoserver"

  ; Copy data_dir
  CreateDirectory "$PROFILE\.opengeo"
  SetOutPath "$PROFILE\.opengeo"
  File /r "${SOURCEPATHROOT}\data_dir"
  ;Next line is lame, but I can't figure out where this directory is being created
  ;RMDir /r "$CommonAppData\${COMPANYNAME}\${APPNAMEANDVERSION}\geoserver"

  ; Shortcuts
  CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\GeoServer Data Directory.lnk" \
                 "$PROFILE\.opengeo\data_dir"

SectionEnd


Section "GeoWebCache" SectionGWC

  ; Set Section properties
  SectionIn RO ; mandatory
  SetOverwrite on

  ; Too Short to display graphic
  ; !insertmacro DisplayImage "slide_4_gwc.bmp"

  ; Yes, this is a fake section.

SectionEnd

Section "GeoExplorer" SectionGX

  SectionIn RO ; mandatory
  SetOverwrite on

  !insertmacro DisplayImage "slide_6_geoext.bmp"

  SetOutPath "$INSTDIR\webapps\"
  File /r "${SOURCEPATHROOT}\webapps\geoexplorer"

  ; Persevere
  SetOutPath "$PROFILE\.opengeo"
  File /r "${SOURCEPATHROOT}\persevere"


SectionEnd

Section "Styler" SectionStyler

  SectionIn RO ; mandatory
  SetOverwrite on

  !insertmacro DisplayImage "slide_6_geoext.bmp"

  SetOutPath "$INSTDIR\webapps\"
  File /r "${SOURCEPATHROOT}\webapps\styler"

SectionEnd

SectionGroupEnd

SectionGroup "Extensions" SectionGSExt

  Section /o "ArcSDE" SectionGSArcSDE

  SetOutPath "$INSTDIR\webapps\geoserver\WEB-INF\lib"
  ;CopyFiles /SILENT /FILESONLY $SDEPath\jsde*.jar "$INSTDIR\webapps\geoserver\WEB-INF\lib"
  ;CopyFiles /SILENT /FILESONLY $SDEPath\jpe*.jar "$INSTDIR\webapps\geoserver\WEB-INF\lib"
  File /a "${SOURCEPATHROOT}\extension\arcsde\*.*"

  SectionEnd

  Section "GDAL" SectionGSGDAL

    SetOutPath "$INSTDIR\jre\bin"
    File /a "${SOURCEPATHROOT}\gdal\*.*"

  SectionEnd

  Section /o "Oracle" SectionGSOracle

    SetOutPath "$INSTDIR\webapps\geoserver\WEB-INF\lib"
    File /a "${SOURCEPATHROOT}\extension\oracle\*.*"

  SectionEnd

SectionGroupEnd

; This MUST go after the Extensions section (so that the vars aredefined)
Function .onSelChange

  ;Sets $SDECheckBox to 1 if component is checked
  SectionGetFlags ${SectionGSArcSDE} $SDECheckBox

  StrCmp $SDECheckBox 1 0 Oracle
    StrCmp $SDECheckBoxPrior 0 0 Oracle
      MessageBox MB_ICONEXCLAMATION|MB_OK "You have elected to install the optional ArcSDE extension.  In order for this functionality to be activated, additional files will need to be manually copied from your ArcSDE installation.  The files required are:$\r$\n$\r$\n     jsde*.jar, jpe*.jar$\r$\n$\r$\nThese files must be copied to the following folder:$\r$\n$\r$\n     $INSTDIR\webapps\geoserver\WEB-INF\lib"

  Oracle:

  ;Sets $OracleCheckBox to 1 if component is checked
  SectionGetFlags ${SectionGSOracle} $OracleCheckBox

  StrCmp $OracleCheckBox 1 0 End
    StrCmp $OracleCheckBoxPrior 0 0 End
      MessageBox MB_ICONEXCLAMATION|MB_OK "You have elected to install the optional Oracle Spatial extension.  In order for this functionality to be activated, the Oracle JDBC driver will need to be manually copied from your Oracle installation.  The file required is:$\r$\n$\r$\n     ojdbc*.jar$\r$\n$\r$\nThis file must be copied to the following folder:$\r$\n$\r$\n     $INSTDIR\webapps\geoserver\WEB-INF\lib"

  End:

  ; This is to set a flag so both displays don't show at once
  StrCpy $SDECheckBoxPrior $SDECheckBox 
  StrCpy $OracleCheckBoxPrior $OracleCheckBox

FunctionEnd


Section "Documentation" SectionDocs

  SectionIn RO ; mandatory
  SetOverwrite on

  ; yes this isn't the GWC section, but it's a good place for GWC to go
  !insertmacro DisplayImage "slide_4_gwc.bmp"

  SetOutPath "$INSTDIR\icons"
  File /a geoserver.ico
  File /a geoexplorer.ico
  File /a styler.ico
  File /a geowebcache.ico
  ;File /a documentation.ico
  
  SetOutPath "$INSTDIR\webapps"

  ; Copy all doc projects
  File /r "${SOURCEPATHROOT}\webapps\docs"

  ; Shortcuts
  SetOutPath "$INSTDIR"
  CreateDirectory "$SMPROGRAMS\$STARTMENU_FOLDER\Documentation"
  CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Documentation\GeoServer Documentation.lnk" \
		         "$INSTDIR\webapps\docs\geoserver\index.html" \
                 "" "$INSTDIR\icons\geoserver.ico" 0
  CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Documentation\GeoExplorer Documentation.lnk" \
		         "$INSTDIR\webapps\docs\geoexplorer\index.html" \
                 "" "$INSTDIR\icons\geoexplorer.ico" 0
  CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Documentation\Styler Documentation.lnk" \
		         "$INSTDIR\webapps\docs\styler\index.html" \
                 "" "$INSTDIR\icons\styler.ico" 0
  CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Documentation\GeoWebCache Documentation.lnk" \
		         "$INSTDIR\webapps\docs\geoserver\geowebcache\index.html" \
                 "" "$INSTDIR\icons\geowebcache.ico" 0
  CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Documentation\Getting Started.lnk" \
		         "$INSTDIR\webapps\docs\gettingstarted\index.html" \
                 "" "$INSTDIR\icons\opengeo.ico" 0

SectionEnd

Section "Recipes" SectionRecipes

  SectionIn RO ; mandatory
  SetOverwrite on

  !insertmacro DisplayImage "slide_1_suite.bmp"

  SetOutPath "$INSTDIR\webapps"
  File /r "${SOURCEPATHROOT}\webapps\recipes"

SectionEnd

Section "-Dashboard" SectionDashboard ;dash means hidden

  SectionIn RO  ; Makes this install mandatory
  SetOverwrite on
 
  !insertmacro DisplayImage "slide_1_suite.bmp"

  SetOutPath "$INSTDIR"
  ;File /r /x config.ini "${SOURCEPATHROOT}\dashboard"
  File /r "${SOURCEPATHROOT}\dashboard"
  SetOutPath "$INSTDIR\dashboard\Resources"

  ${textreplace::ReplaceInFile} "$INSTDIR\dashboard\Resources\config.ini" \
                                "$INSTDIR\dashboard\Resources\config.ini" \
                                "@SUITE_EXE@" "$INSTDIR\opengeo-suite.bat" \ 
                                "/S=1" $1
  ${textreplace::ReplaceInFile} "$INSTDIR\dashboard\Resources\config.ini" \
                                "$INSTDIR\dashboard\Resources\config.ini" \
                                "@SUITE_DIR@" "$INSTDIR" \ 
                                "/S=1" $1
  ${textreplace::ReplaceInFile} "$INSTDIR\dashboard\Resources\config.ini" \
                                "$INSTDIR\dashboard\Resources\config.ini" \
                                "@GEOSERVER_DATA_DIR@" "$PROFILE\.opengeo\data_dir" \ 
                                "/S=1" $1


  CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\OpenGeo Suite Dashboard.lnk" \
		         "$INSTDIR\dashboard\OpenGeo Dashboard.exe" \
                 "" "$INSTDIR\icons\opengeo.ico" 0

SectionEnd


Section "-StartStop" SectionStartStop

  ; Create Start/Stop shortcuts

  SetOutPath "$INSTDIR\icons"
  File /a opengeo-start.ico
  File /a opengeo-stop.ico

  SetOutPath "$INSTDIR"
  CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Start OpenGeo Suite.lnk" \
                 "$INSTDIR\opengeo-suite.bat" \
                 "start" "$INSTDIR\icons\opengeo-start.ico" 0 SW_SHOWMINIMIZED
  CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Stop OpenGeo Suite.lnk" \
                 "$INSTDIR\opengeo-suite.bat" \
                 "stop" "$INSTDIR\icons\opengeo-stop.ico" 0 SW_SHOWMINIMIZED

SectionEnd

Section "-Misc" SectionMisc

  CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Uninstall.lnk" \
                 "$INSTDIR\Uninstall.exe" \
                 "" "$INSTDIR\icons\uninstall.ico" 0

  ; Changelog
  SetOutPath $INSTDIR
  File /a ..\common\changelog.txt

SectionEnd


; What happens at the end of the install.
Section -FinishSection

  ; Reg Keys
  WriteRegStr HKLM "Software\${COMPANYNAME}\${APPNAMEANDVERSION}" "" ""
  WriteRegStr HKLM "Software\${COMPANYNAME}\${APPNAMEANDVERSION}" "InstallDir" "$INSTDIR"

  ; For the Add/Remove programs area
  !define UNINSTALLREGPATH "Software\Microsoft\Windows\CurrentVersion\Uninstall"
  WriteRegStr HKLM "${UNINSTALLREGPATH}\${APPNAMEANDVERSION}" "DisplayName" "${APPNAMEANDVERSION}"
  WriteRegStr HKLM "${UNINSTALLREGPATH}\${APPNAMEANDVERSION}" "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegStr HKLM "${UNINSTALLREGPATH}\${APPNAMEANDVERSION}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "${UNINSTALLREGPATH}\${APPNAMEANDVERSION}" "DisplayIcon" "$INSTDIR\icons\opengeo.ico"
  WriteRegStr HKLM "${UNINSTALLREGPATH}\${APPNAMEANDVERSION}" "Publisher" "OpenGeo"
  WriteRegStr HKLM "${UNINSTALLREGPATH}\${APPNAMEANDVERSION}" "HelpLink" "http://opengeo.org"
  WriteRegDWORD HKLM "${UNINSTALLREGPATH}\${APPNAMEANDVERSION}" "NoModify" "1"
  WriteRegDWORD HKLM "${UNINSTALLREGPATH}\${APPNAMEANDVERSION}" "NoRepair" "1"

  WriteUninstaller "$INSTDIR\uninstall.exe"

SectionEnd


; Modern install component descriptions
; Yes, this needs to go after the install sections. 
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SectionJetty} "Installs Jetty, a web server."
  !insertmacro MUI_DESCRIPTION_TEXT ${SectionServices} "A list of all of the services contained in the OpenGeo Suite."
  !insertmacro MUI_DESCRIPTION_TEXT ${SectionGS} "Installs GeoServer, a spatial data server."
  !insertmacro MUI_DESCRIPTION_TEXT ${SectionGSExt} "Includes GeoServer Extensions."
  !insertmacro MUI_DESCRIPTION_TEXT ${SectionGSArcSDE} "Adds support for ArcSDE databases.  Requires additional ArcSDE files."
  !insertmacro MUI_DESCRIPTION_TEXT ${SectionGSGDAL} "Adds support for GDAL image formats."
  !insertmacro MUI_DESCRIPTION_TEXT ${SectionGSOracle} "Adds support for Oracle databases.  Requires additional Oracle files."
  !insertmacro MUI_DESCRIPTION_TEXT ${SectionGWC} "Includes GeoWebCache, a tile cache server."
  !insertmacro MUI_DESCRIPTION_TEXT ${SectionGX} "Installs GeoExplorer, a graphical map editor."
  !insertmacro MUI_DESCRIPTION_TEXT ${SectionStyler} "Installs Styler, a graphical map style editor."
  !insertmacro MUI_DESCRIPTION_TEXT ${SectionDocs} "Includes full documentation for all applications."
  !insertmacro MUI_DESCRIPTION_TEXT ${SectionDashboard} "Installs the OpenGeo Suite Dashboard for access to all components."
  !insertmacro MUI_DESCRIPTION_TEXT ${SectionRecipes} "Installs examples and demos to help you build your own mapping applications."
  !insertmacro MUI_DESCRIPTION_TEXT ${SectionStartStop} "Creates shortcuts for starting and stopping the OpenGeo Suite."
  !insertmacro MUI_DESCRIPTION_TEXT ${SectionMisc} "Creates everything else."
!insertmacro MUI_FUNCTION_DESCRIPTION_END


; Uninstall section
Section Uninstall

  ; First check if registry info is intact, otherwise install will fail


  ; Stop Suite
  SetOutPath "$INSTDIR"
  ExecWait '"$INSTDIR\opengeo-suite.bat" stop'
  ; Wait for Start GeoServer window to go away
  Sleep 5000

  MessageBox MB_OKCANCEL                    "Your data directory will be deleted!$\r$\n$\r$\n\
                                             Your data directory is located at:\
                                             $\r$\n     $INSTDIR\data_dir$\r$\n$\r$\n\
                                             If you wish to save this directory for future use, \
                                             please take a moment to back it up now.$\r$\n\
                                             Click OK when ready to proceed." IDOK 0 IDCANCEL Die

  ; Have to move out of the directory to delete it
  SetOutPath $TEMP

  ; Remove all reg entries
  DeleteRegKey HKLM "Software\${COMPANYNAME}\${APPNAMEANDVERSION}"
  DeleteRegKey /ifempty HKLM "Software\${COMPANYNAME}"
  DeleteRegKey HKLM "${UNINSTALLREGPATH}\${APPNAMEANDVERSION}"

  ; Delete self
  Delete "$INSTDIR\uninstall.exe"

  ; Delete Shortcuts
  RMDir /r "$SMPROGRAMS\$STARTMENU_FOLDER"

  ; Delete all!

  Try:

    RMDir /r "$INSTDIR\dashboard"
    RMDir /r "$INSTDIR\data_dir"
    RMDir /r "$INSTDIR\etc"
    RMDir /r "$INSTDIR\lib"
    RMDir /r "$INSTDIR\logs"
    RMDir /r "$INSTDIR\resources"
    RMDir /r "$INSTDIR\webapps"
    RMDir /r "$INSTDIR\jre"
    RMDir /r "$INSTDIR\icons"
    RMDir /r "$INSTDIR\recipes"
    RMDir /r "$INSTDIR\trace.db" ; shouldn't need this
    Delete "$INSTDIR\*.*"
    RMDir "$INSTDIR"
    IfFileExists "$INSTDIR" Warn Succeed

  Warn:
    MessageBox MB_RETRYCANCEL "Setup is having trouble removing all files and folders from:$\r$\n   $INSTDIR\$\r$\nPlease make sure no files are open in this directory and close all browser windows.  You can also manually delete this folder if you choose.  To try again, click Retry." IDRETRY Try IDCANCEL GiveUp

  GiveUp:
    MessageBox MB_ICONINFORMATION "WARNING: Some files and folders could not be removed from:$\r$\n   $INSTDIR\$\r$\nYou will have to manually remove these files and folders."
    Goto Succeed

  Die:
    MessageBox MB_OK "Uninstallation was interrupted..."
    Quit

  Succeed:
    RMDir "$PROGRAMFILES\${COMPANYNAME}"

SectionEnd

; The End