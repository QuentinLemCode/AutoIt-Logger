#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2

 Script Function: Unit testing logger library

#ce ----------------------------------------------------------------------------

#include "..\logger.au3"
#include <File.au3>

DirRemove(@ScriptDir & "\test-logs\", 1)

;Check des fonctions parametres

SetLogLevel($g_iLogLevelDebug)

SetLogDir(@ScriptDir & "\test-logs\")

SetLogRotate(10)

SetLogCompressRotate(5)

SetFilePrefix("test-log")

SetFileExtension("log")

;Test numéro 1 - Verif application paramètres
If($__iCurrentLevel <> $g_iLogLevelDebug OR _
    $__iLogRotate <> 10 OR _
    $__iLogCompressRotate <> 5 Or _
    $__sLogDir <> @ScriptDir & "\test-logs\" OR _
    $__sFilePrefix <> "test-log" OR _
    $__sFileExtension <> "log") Then
    MsgBox(0,"Echec","Test numéro 1 en échec")
    Exit
EndIf


;Test numéro 2 - Verif ecriture logs
LogInfo("info")
LogDebug("debug")
LogWarning("warning")
LogCritical("critical")
LogOther("test", "NON !") ;Ne doit pas s'enregistrer
LogOther("test", "oui", True) ;doit s'enregistrer

If($__bInit == False OR $__hLogFile == 0 Or _FileCountLines($__sLogDir & $__sFilePrefix & "_" & @MDAY & "-" & @MON & "-" & @YEAR & "." & $__sFileExtension) <> 5) Then
    MsgBox(0, "Echec", "Test numéro 2 en échec")
Endif
Sleep(5000)

;Test numéro 3 - Verif rotation des logs
SetLogRotate(0)
FileDelete($__sLogDir & $__sFilePrefix & "_" & @MDAY & "-" & @MON & "-" & @YEAR & "." & $__sFileExtension)
For $iDay = 1 To 30 Step +1
Local $sDay = ""
    If($iDay < 10) Then
        $sDay = "0" & $iDay
    Else
        $sDay = $iDay
    Endif
    Run(@ScriptDir & '\RunAsDate.exe ' & $sDay & '\01\2017 "' & @ScriptDir & '\test-day.exe"')
    Sleep(1000)
Next
If(_FileListToArray($__sLogDir)[0] < 11) Then
    MsgBox(0, "", "Test numéro 3 en echec")
Endif