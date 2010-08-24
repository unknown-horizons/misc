; Script by André Reichelt

SetCompressor lzma ;Kompression

; Helper defines
!define PRODUCT_NAME "OpenAnno"
!define PRODUCT_VERSION "2008.01a"
!define PRODUCT_WEB_SITE "http://openanno.org"
!define PRODUCT_PUBLISHER "OpenAnno Team"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\openanno.py"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

; MUI 1.67 compatible ------
!include "MUI.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "gfx\install.ico"
!define MUI_UNICON "gfx\uninstall.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "gfx\banner-1.bmp"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_RIGHT
!define MUI_HEADERIMAGE_BITMAP "gfx\header-1.bmp"
!define OA_ICON "$INSTDIR\openanno.ico"
!define OA_UNICON "$INSTDIR\uninstall.ico"

;!define MUI_INSTFILESPAGE_COLORS "#ABCDEF"

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
;!insertmacro MUI_PAGE_LICENSE "c:\pfad\zur\lizenz\IhreLizenz.txt"
!insertmacro MUI_PAGE_COMPONENTS
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_FUNCTION run_oa
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "Setup.exe"
InstallDir "$PROGRAMFILES\OpenAnno"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails nevershow
ShowUnInstDetails nevershow
BrandingText "${PRODUCT_NAME} ${PRODUCT_VERSION} installer"

;--------- RUN OPENANNO ---------
Function run_oa
  ExecShell "open" "$INSTDIR\openanno.py" ;OpenAnno starten
FunctionEnd
;---------- OnInit --------------
Function .onInit
  SectionSetSize 1 35664 ;Python Sektion
FunctionEnd
;------------ SECTION -----------
Section "OpenAnno" OpenAnno
  SectionIn RO

  ;SetDetailsPrint textonly
  ;DetailPrint "Installing core components"

  !include "setup include.nsi"
SectionEnd
;---------- DOWNLOAD PYTHON -------
Section "Python (required)" Python
  SetDetailsPrint textonly
  
  DetailPrint "Downloading Python"
  NSISdl::download http://www.python.org/ftp/python/2.5.2/python-2.5.2.msi $TEMP\pysetup.msi
  Pop $R0 ;Get the return value
    StrCmp $R0 "success" +3
      MessageBox MB_OK "Download failed: $R0"
      Quit

  DetailPrint "Installing Python"
  ExecWait '"msiexec" /i "$TEMP\pysetup.msi"'
  
  DetailPrint "Deleting Python installer"
  Delete $TEMP\pysetup.msi
SectionEnd
;----------- OPEN AL --------------
Section "OpenAL (required)" OpenAL
  SetDetailsPrint textonly

  SetOutPath "$TEMP"
  File "oalinst\oalinst.exe"
  DetailPrint "Installing OpenAL"
  ExecWait "$TEMP\oalinst.exe"

  DetailPrint "Deleting OpenAL installer"
  Delete "$TEMP\oalinst.exe"
SectionEnd
;--------- SECTION END ------------
Section -AdditionalIcons
  CreateDirectory "$SMPROGRAMS\OpenAnno"
  CreateShortCut "$SMPROGRAMS\OpenAnno\OpenAnno.lnk" "$INSTDIR\openanno.py" "" "${OA_ICON}"
  CreateShortCut "$DESKTOP\OpenAnno.lnk" "$INSTDIR\openanno.py" "" "${OA_ICON}"
  CreateShortCut "$SMPROGRAMS\OpenAnno\Uninstall.lnk" "$INSTDIR\uninst.exe" "" "${OA_UNICON}"
SectionEnd

Section -Post
  WriteUninstaller $INSTDIR\uninst.exe ;Create Uninstaller
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\openanno.py"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "${OA_ICON}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully uninstalled. Please keep in mind that this installer don't remove OpenAL and Python. You have to uninstall them separately via your control panel!"
FunctionEnd

Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Would you really like to uninstall $(^Name) and all its components?" IDYES +2
  Abort
FunctionEnd

Section Uninstall
  !include "uninstall include.nsi"
SectionEnd

;Description
LangString DESC_OpenAnno ${LANG_ENGLISH} "OpenAnno - The game (including FIFE)"
LangString DESC_Python ${LANG_ENGLISH} "Python - Only if it's not already on your hard drive!"
LangString DESC_OpenAL ${LANG_ENGLISH} "OpenAL: Necessary for music and sound! Choose this one if it isn't installed already."

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${OpenAnno} $(DESC_OpenAnno)
  !insertmacro MUI_DESCRIPTION_TEXT ${Python} $(DESC_Python)
  !insertmacro MUI_DESCRIPTION_TEXT ${OpenAL} $(DESC_OpenAL)
!insertmacro MUI_FUNCTION_DESCRIPTION_END