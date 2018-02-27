!include "MUI2.nsh"
!include LogicLib.nsh
!include Win\COM.nsh
!include Win\Propkey.nsh

!macro DemoteShortCut target
    !insertmacro ComHlpr_CreateInProcInstance ${CLSID_ShellLink} ${IID_IShellLink} r0 ""
    ${If} $0 <> 0
            ${IUnknown::QueryInterface} $0 '("${IID_IPersistFile}",.r1)'
            ${If} $1 P<> 0
                    ${IPersistFile::Load} $1 '("${target}",1)'
                    ${IUnknown::Release} $1 ""
            ${EndIf}
            ${IUnknown::QueryInterface} $0 '("${IID_IPropertyStore}",.r1)'
            ${If} $1 P<> 0
                    System::Call '*${SYSSTRUCT_PROPERTYKEY}(${PKEY_AppUserModel_StartPinOption})p.r2'
                    System::Call '*${SYSSTRUCT_PROPVARIANT}(${VT_UI4},,&i4 ${APPUSERMODEL_STARTPINOPTION_NOPINONINSTALL})p.r3'
                    ${IPropertyStore::SetValue} $1 '($2,$3)'

                    ; Reuse the PROPERTYKEY & PROPVARIANT buffers to set another property
                    System::Call '*$2${SYSSTRUCT_PROPERTYKEY}(${PKEY_AppUserModel_ExcludeFromShowInNewInstall})'
                    System::Call '*$3${SYSSTRUCT_PROPVARIANT}(${VT_BOOL},,&i2 ${VARIANT_TRUE})'
                    ${IPropertyStore::SetValue} $1 '($2,$3)'

                    System::Free $2
                    System::Free $3
                    ${IPropertyStore::Commit} $1 ""
                    ${IUnknown::Release} $1 ""
            ${EndIf}
            ${IUnknown::QueryInterface} $0 '("${IID_IPersistFile}",.r1)'
            ${If} $1 P<> 0
                    ${IPersistFile::Save} $1 '("${target}",1)'
                    ${IUnknown::Release} $1 ""
            ${EndIf}
            ${IUnknown::Release} $0 ""
    ${EndIf}
!macroend

Name "GroundStation"
Var StartMenuFolder

InstallDir $PROGRAMFILES\GroundStation

SetCompressor /SOLID /FINAL lzma

!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "installlogo.bmp";

!insertmacro MUI_PAGE_LICENSE "license.txt"
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

Section
  ReadRegStr $R0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GroundStation" "UninstallString"
  StrCmp $R0 "" doinstall

  ExecWait "$R0 /S _?=$INSTDIR"
  IntCmp $0 0 doinstall

  MessageBox MB_OK|MB_ICONEXCLAMATION \
        "Could not remove a previously installed GroundStation version.$\n$\nPlease remove it before continuing."
  Abort

doinstall:
  SetOutPath $INSTDIR
  File /r /x GroundStation.pdb /x GroundStation_pch.pch /x GroundStation.lib /x GroundStation.exp /x GroundStation_pch.obj E:\UAV\Release\release\*.*
  WriteUninstaller $INSTDIR\GroundStation_uninstall.exe
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GroundStation" "DisplayName" "GroundStation"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GroundStation" "UninstallString" "$\"$INSTDIR\GroundStation_uninstall.exe$\""

done:
SectionEnd 

Section "Uninstall"
  !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
  SetShellVarContext all
  RMDir /r /REBOOTOK $INSTDIR
  RMDir /r /REBOOTOK "$SMPROGRAMS\$StartMenuFolder\"
  SetShellVarContext current
  RMDir /r /REBOOTOK "$APPDATA\GROUNDSTATION.ORG\"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GroundStation"
SectionEnd

Section "create Start Menu Shortcuts"
  SetShellVarContext all
  CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
  CreateShortCut "$SMPROGRAMS\$StartMenuFolder\GroundStation.lnk" "$INSTDIR\GroundStation.exe" "" "$INSTDIR\GroundStation.exe" 0
  CreateShortCut "$SMPROGRAMS\$StartMenuFolder\GroundStation (GPU Compatibility Mode).lnk" "$INSTDIR\GroundStation.exe" "-angle" "$INSTDIR\GroundStation.exe" 0
  !insertmacro DemoteShortCut "$SMPROGRAMS\$StartMenuFolder\GroundStation (GPU Compatibility Mode).lnk"
  CreateShortCut "$SMPROGRAMS\$StartMenuFolder\GroundStation (GPU Safe Mode).lnk" "$INSTDIR\GroundStation.exe" "-swrast" "$INSTDIR\GroundStation.exe" 0
  !insertmacro DemoteShortCut "$SMPROGRAMS\$StartMenuFolder\GroundStation (GPU Safe Mode).lnk"
SectionEnd

