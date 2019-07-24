
@echo off

echo nat server

echo %cd%

goto runvb

:runvb
echo runvb
if "%1" == "h" goto begin
mshta vbscript:createobject("wscript.shell").run("""%~nx0"" h",0)(window.close)&&exit

:begin
echo begin
java -Xmx256m -Dfile.encoding=utf-8 -cp lsiding-xcode-0.0.1-SNAPSHOT-jar-with-dependencies.jar com.lsiding.xcode.XClassLoader com.lsiding.nat.server.Server main > server.log.txt
goto :eof