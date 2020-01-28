@ECHO off
SET fileName="%1"
SET openBrowser=TRUE
FOR %%A IN (%*) DO (
    IF "%%A"=="-no-browser" SET openBrowser=FALSE
	IF "%%A"=="-nb" SET openBrowser=FALSE
)
IF %fileName%=="" (IF NOT openBrowser==TRUE (
	ECHO usage: run [exampleName]
	ECHO   where exampleName is the name of the desired html file ^(without []^)
	ECHO   optional flags:
	ECHO     -no-browser, -nb: prevents a browser tab being opened and only the http server will be started
)) ELSE (
	IF %openBrowser%==TRUE START http://localhost:8080/%fileName%.html
	http-server -c-1 --cors
)