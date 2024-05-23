REM Call this batch file from Popper's Visual Pinball X Close Script.  It should be the last line.
REM CALL [STARTDIR]Hiscore\vpx_launch.bat "[DIREMU]" "[DIRGAME]" "[DIRROM]" "[GAMEFULLNAME]" "[GAMENAME]" "[GAMEEXT]" "[STARTDIR]" "[CUSTOM1]" "[CUSTOM2]" "[CUSTOM3]" "[ALTEXE]" "[ALTMODE]" "[MEDIADIR]" "[?ROM?]" "[?GameType?]" 

REM Use shift since we have more than 9 parameters
REM Remove quotes from variables
SET DIREMU=%~1
SHIFT
SET DIRGAME=%~1
SHIFT
SET DIRROM=%~1
SHIFT
SET GAMEFULLNAME=%~1
SHIFT
SET GAMENAME=%~1
SHIFT
SET GAMEEXT=%~1
SHIFT
SET STARTDIR=%~1
SHIFT
SET CUSTOM1=%~1
SHIFT
SET CUSTOM2=%~1
SHIFT
SET CUSTOM3=%~1
SHIFT
SET ALTEXE=%~1
SHIFT
SET ALTMODE=%~1
SHIFT
SET MEDIADIR=%~1
SHIFT
REM ?game_field? entries...
SET ROM=%~1
SHIFT
SET GAMETYPE=%~1
SHIFT

ECHO VPX close script start for %GAMENAME% >> "c:\Visual~1\Hiscores\logs\debug.log"

IF NOT "%ROM%"=="" (
   
    ECHO Cutom var was %CUSTOM2% >> "c:\Visual~1\Hiscores\logs\debug.log"
    IF "%CUSTOM2%"=="UltraDMD" (
        ECHO Starting high score generation...>> "c:\Visual~1\Hiscores\logs\debug.log"
        ECHO "c:\Visual~1\Hiscores\hiscore.bat" %ROM% "%GAMENAME%" "%CUSTOM2%">> "c:\Visual~1\Hiscores\logs\debug.log"

        REM Generate HiScore media file
        CALL "c:\Visual~1\Hiscores\hiscore.bat" %ROM% "%GAMENAME%" "%CUSTOM2%"
        ECHO Completed high score generation>> "c:\Visual~1\Hiscores\logs\debug.log"
        
    ) ELSE (
        ECHO Starting high score generation...>> "c:\Visual~1\Hiscores\logs\debug.log"
        ECHO "c:\Visual~1\Hiscores\hiscore.bat" %ROM% "%GAMENAME%" "%GAMETYPE%">> "c:\Visual~1\Hiscores\logs\debug.log"

        REM Generate HiScore media file
        CALL "c:\Visual~1\Hiscores\hiscore.bat" %ROM% "%GAMENAME%" "%GAMETYPE%"
        ECHO Completed high score generation>> "c:\Visual~1\Hiscores\logs\debug.log"
    )
)

ECHO generating md files and pushing to git >> "c:\Visual~1\Hiscores\logs\debug.log" 
REM python "C:\\Visual Pinball\\vmvpin.github.io\\scripts\\genmd.py"
CALL CMD /C python "C:\\Visual Pinball\\vmvpin.github.io\\scripts\\genmd.py"

REM ECHO Restoring settings...>> "c:\Visual~1\Hiscores\scripts\logs\debug.log"
REM CALL "c:\Visual~1\Hiscoresrestore_settings.bat"
REM DEL "c:\Visual~1\Hiscoresrestore_settings.bat"

REM ECHO Settings have been restored.>> "c:\Visual~1\Hiscores\scripts\logs\debug.log"
REM ECHO VPX close script end>> "c:\Visual~1\Hiscores\scripts\logs\debug.log"

cd "C:\Visual Pinball\vmvpin.github.io"
git add .
git commit -m "Hacked commit"
git push

ECHO VPX Close script complete for %GAMENAME% >> "c:\Visual~1\Hiscores\logs\debug.log"
ECHO - >> "c:\Visual~1\Hiscores\logs\debug.log"


exit /B