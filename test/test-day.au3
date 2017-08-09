#include "..\logger.au3"

SetLogDir(@ScriptDir & "\test-logs\")

SetLogRotate(10)

SetLogCompressRotate(5)

SetFilePrefix("test-log")

SetFileExtension("log")

LogInfo("Log du jour ")