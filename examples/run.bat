@ECHO off
SET fileName="%1"
IF %fileName%=="" (
	ECHO usage: run [exampleName]
	ECHO   where exampleName is the name of the desired html file ^(without []^)
) ELSE (
	start http://localhost:8080/%fileName%.html
	http-server -c-1 --cors
)