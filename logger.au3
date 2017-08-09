#include <FileConstants.au3>
#include "Zip.au3"
#include <File.au3>
#include <Date.au3>
#include-once 

#cs
Fonction permettant d'écrire un fichier de log
#ce

Local $__bInit = False
Local $__hLogFile = 0
Local $__sCurrentDay = @MDAY
Local $__iCurrentLevel = 5
Local $__iLogRotate = 30
Local $__iLogCompressRotate = 7
Local $__sLogDir = @ScriptDir & "\"
Local $__sFilePrefix = "log"
Local $__sFileExtension = "txt"

Global Const $g_iLogLevelAll = 5
Global Const $g_iLogLevelDebug = 4
Global Const $g_iLogLevelInfo = 3
Global Const $g_iLogLevelWarning = 2
Global Const $g_iLogLevelCritical = 1
Global Const $g_iLogLevelNoLog = 0


;Fonctions globales

Func LogOther($sLogLevel, $sLogValue, $bForce = False) ;Level 5
    If($__iCurrentLevel < 5 And Not $bForce) Then Return
    __WriteLog($sLogLevel, $sLogValue)
EndFunc

Func LogDebug($sLogValue) ;Level 4
    If($__iCurrentLevel < 4) Then Return
    __WriteLog("DEBUG",$sLogValue)
EndFunc

Func LogInfo($sLogValue) ;Level 3
    If($__iCurrentLevel < 3) Then Return
    __WriteLog("INFO",$sLogValue)
EndFunc

Func LogWarning($sLogValue) ;Level 2
    If($__iCurrentLevel < 2) Then Return
    __WriteLog("WARNING",$sLogValue)
EndFunc

Func LogCritical($sLogValue) ;Level 1
    If($__iCurrentLevel < 1) Then Return
    __WriteLog("CRITICAL",$sLogValue)
EndFunc

;Fonctions de configurations

Func SetLogLevel($iLogLevel)
    $__iCurrentLevel = $iLogLevel
EndFunc

Func SetLogDir($sLogDir)
    If DirGetSize($sLogDir) == -1 Then ;Si le dossier existe pas, on le crée
        Local $iRet = DirCreate($sLogDir)
    EndIf
    $__sLogDir = $sLogDir
EndFunc

Func SetFilePrefix($sFilePrefix)
    $__sFilePrefix = $sFilePrefix
EndFunc

Func SetFileExtension($sFileExtension)
    $__sFileExtension = $sFileExtension
EndFunc

Func SetLogRotate($iLogRotate) ;Nombre de jours avant suppression, 0 pour désactiver
    If($iLogRotate < 0) Then Return SetError(1,0,"Le nombre de jours de rotation des logs ne peut être négatif")
    $__iLogRotate = $iLogRotate
EndFunc

Func SetLogCompressRotate($iLogCompressRotate) ;Nombre de jours avant compression, 0 pour désactiver
    If($iLogCompressRotate < 0) Then Return SetError(1,0, "Le nombre de jours de rotation de la compression des logs ne peut être négatif")
    $__iLogCompressRotate = $iLogCompressRotate
EndFunc


;Fonctions internes

Func __WriteLog($sLogLevel, $sLogValue)
    If Not($__bInit) Then __InitLog()
    If($__sCurrentDay <> @MDAY) Then __ChangeLogDay()
    Local $sLogLine = "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] " & $sLogLevel & " : " &$sLogValue & @CRLF
    Local $ret = FileWriteLine($__hLogFile, $sLogLine)
EndFunc

Func __ChangeLogDay()
    FileClose($__hLogFile)
    Local $sFilePath = $__sLogDir & $__sFilePrefix & "_" & @MDAY & "-" & @MON & "-" & @YEAR & "." & $__sFileExtension
    $__hLogFile = FileOpen($sFilePath, $FO_APPEND)
    If(@error) Then $__bInit = False
EndFunc

Func __InitLog()
    If($__bInit) Then Return
    Local $sFilePath = $__sLogDir & $__sFilePrefix & "_" & @MDAY & "-" & @MON & "-" & @YEAR & "." & $__sFileExtension
    $__hLogFile = FileOpen($sFilePath, $FO_APPEND)
    If(@error) Then Return
    If(OnAutoItExitRegister("__LogDestruct") == 0) Then Return
    $__bInit = True
EndFunc


Func __LogDestruct()
    Local $aLogsFiles = _FileListToArray($__sLogDir, $__sFilePrefix & "*." & $__sFileExtension & "*", 1, True)
    If(@error) Then 
        If(@error <> 4) Then
            LogWarning("Erreur numero " & @error & " sur la fonction _FileListToArray, impossible d'effectuer la rotation des logs")
            FileClose($__hLogFile)
        Endif
        Return
    EndIf
    Local $sTodayDate = @YEAR & "/" & @MON & "/" & @MDAY
    For $i = 1 To $aLogsFiles[0] Step +1
        $asResult = StringRegExp($aLogsFiles[$i], $__sFilePrefix & "_(\d{2})-(\d{2})-(\d{4})." & $__sFileExtension, 1)
        If(@error) Then ContinueLoop
        If(Ubound($asResult) <> 3) Then ContinueLoop
        Local $sFileDate = $asResult[2] & "/" & $asResult[1] & "/" & $asResult[0]
        Local $iDiff = _DateDiff("D",$sFileDate, $sTodayDate)
        If($iDiff > $__iLogRotate AND $__iLogRotate <> 0) Then
            FileDelete($aLogsFiles[$i])
            ContinueLoop
        EndIf
        If(($iDiff >= $__iLogCompressRotate AND $__iLogCompressRotate <> 0) AND StringRight($aLogsFiles[$i], 3) == $__sFileExtension AND $__iLogRotate <> 0) Then
            __Compress($aLogsFiles[$i])
            ContinueLoop
        Endif
    Next
    FileClose($__hLogFile)
    $__bInit = False
EndFunc

Func __Compress($sFile)
    Local $zip = _Zip_Create($sFile & ".zip")
    If(@error) Then
        LogOther("LOGGER", "Impossible de créer le fichier " & $sFile & ".zip - Erreur " & @error & " Fonction _Zip_Create - Consulter la documentation de la librairie Zip.au3", True)
        Return 
    Endif
    _Zip_AddFile($zip, $sFile)
    If(@error) Then
        LogOther("LOGGER", "Impossible d'ajouter le fichier " & $sFile & " à l'archive zip - Erreur " & @error & " Fonction _Zip_AddFile - Consulter la documentation de la librairie Zip.au3", True)
        Return
    EndIf
    ;Verification
    Local $zCount = _Zip_Count($zip)
    If(@error) Then
        LogOther("LOGGER", "Impossible de vérifier l'archive " & $sFile & ".zip - Erreur " & @error & " Fonction _Zip_CountFile - Consulter la documentation de la librairie Zip.au3", True)
        Return
    EndIf
    If($zCount < 1) Then
        LogOther("LOGGER", "Impossible de vérifier l'archive " & $sFile & ".zip - Le fichier n'as pas été ajouté à l'archive - Consulter la documentation de la librairie Zip.au3", True)
        Return
    EndIf

    ;C'est OK on supprime le fichier de base
    FileDelete($sFile)
EndFunc