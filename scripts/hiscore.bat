@echo off
SETLOCAL EnableDelayedExpansion

REM START OF VARIABLES DECLARATION
    REM Set the following variables based on your setup
    REM Path to PINemHI
    SET "PINemHiPath=c:\Visual~1\Hiscores\PINemHi 1.3.1"

    REM Path to ImageMagick
    SET "ImageMagick=c:\Visual~1\Hiscores\ImageMagick-7.1.0-61-portable-Q16-x86"

    REM Path to TXT files with HiScores
    SET "PINemHiHS=c:\Visual~1\Hiscores\Text"
    If NOT EXIST "%PINemHiHS%" (mkdir "%PINemHiHS%")

    REM Path for temporary PNGs and background image
    SET "PINemHiPNG=c:\Visual~1\Hiscores\PNGs"

    REM Filename of background image to be used
    SET "Background=chalkboard.jpg"

    REM Path to VPinMAME nvram files
    SET "NVRamPath=c:\Visual~1\VPinMAME\nvram"

    REM Path to FP nvram files
    SET "FPNVRamPath=c:\Visual~1\Future Pinball\fpRAM"

    REM Path to VP User files
    SET "UserPath=c:\Visual~1\User"

    REM Path to VP User files
    SET "AliasPath=c:\Visual~1\VPinMAME\VPMAlias.txt"

    REM Path to 7z
    SET "Zexepath=c:\Visual~1\Hiscores\7z"

    REM Folder where you want the VP high score PNGs with high scores placed (GameInfo, Topper, DMD, etc.)
    SET "POPVPMedia=C:\Visual Pinball\PinUPPopper\POPMedia\Visual Pinball X\DMD"

    REM Folder where you want the FP high score PNGs with high scores placed (GameInfo, Topper, DMD, etc.)
    SET "POPFPMedia=c:\Visual~1\Hiscores\"

    REM This suffix will be added to the second parameter passed (tablename) when saving high score PNGs
    SET "Suffix="

    SET "Font=c:\Visual~1\Hiscores\Fonts\pinball-data.pinball.ttf"

    REM Moviepy requires escape style paths
    REM SET "Video_Font=c:\\PinUPSystem\\Utils\\Fonts\\HIGHSPEED.TTF"

    SET "HiScoreDir=c:\Visual~1\Hiscores"

    SET "LogPath=c:\Visual~1\Hiscores\logs\debug.log"
REM END OF VARIABLES DECLARATION

REM Need to change to the PINemHi folder in order for the exe to read its INI
cd "%PINemHiPath%"
REM Uncomment the next line to regenerate PINemHi supported roms DB
REM "%PINemHiPath%\pinemhi.exe" -lr>"%PINemHiPath%\supported.txt"

SET ROM_NAME=%~1

REM Check if our rom file is aliased to another name
FOR /F "usebackq tokens=1,2 delims=," %%i in ("%AliasPath%") do (
    if %%i==%ROM_NAME% (
        SET ROM_NAME=%%j
        ECHO Found aliased ROM, using %ROM_NAME%>> %LogPath%
    )
)

REM We will select the right parsing routine
SET ISTEXT=%3
if %ISTEXT% == "BAM" GOTO FUTURE
SET ISTEXT=%3
if %ISTEXT% == "UltraDMD" GOTO ULTRADMD
SET ISTEXT=%1
SET ISTEXT=%ISTEXT:~-4%
if "%ISTEXT%" == ".txt" GOTO POSTIT

GOTO NVRAM

:FUTURE
REM Start of fpram processing
ECHO Getting Future Pinball High Score>> %LogPath%
SET OUTPUT=%POPFPMedia%
SET TEMPTXT=%~2
REM if there is no FP nvram file, exit
IF NOT EXIST "%FPNVRamPath%\%~2.fpram" exit /B
REM call PINemHi pipped to a txt file
"%PINemHiPath%\pinemhi.exe" %~2.fpram>"%PINemHiHS%\%~2.txt"
REM delete TXT files with size 0 as they are empty
for /f %%I in ("%PINemHiHS%\%~2.txt") do if %%~zI==0 del "%PINemHiHS%\%TEMPTXT%.txt"
GOTO PNG

:ULTRADMD
REM Start of ULTRADMD processing
ECHO Getting UltraDMD High Score>> %LogPath%
SET OUTPUT=%POPVPMedia%
SET TEMPTXT=%ROM_NAME%
REM extract hiscore files from iStor
@echo HIGHEST SCORES>"%PINemHiHS%\%TEMPTXT%.txt"
%Zexepath%\7z.exe x -o"%PINemHiHS%" "%UserPath%\VPReg.stg" %1
REM Then parse and build TXT file similar to POSTIT
FOR /L %%G IN (1,1,4) DO (
    more "%PINemHiHS%\%1\HighScore%%GName">>"%PINemHiHS%\%TEMPTXT%.txt"
    more "%PINemHiHS%\%1\HighScore%%G">>"%PINemHiHS%\%TEMPTXT%.txt"
    echo.>>"%PINemHiHS%\%TEMPTXT%.txt"
)
REM we now clean temp files
rmdir "%PINemHiHS%\%1" /s/q
REM delete TXT files with size 0 as they are empty
for /f %%I in ("%PINemHiHS%\%TEMPTXT%.txt") do if %%~zI==0 del "%PINemHiHS%\%TEMPTXT%.txt"
CALL python "%HiScoreDir%\reformat_scores.py" "%PINemHiHS%\%TEMPTXT%.txt" "%PINemHiHS%\%TEMPTXT%.txt" UltraDMD
GOTO PNG

:POSTIT
REM Start POSIT is file processing
ECHO Getting PostIt High Score>> %LogPath%
SET OUTPUT=%POPVPMedia%
SET TEMPTXT=%ROM_NAME%
SET TEMPTXT=%TEMPTXT:"=%
REM if there is no PostIT file, exit
IF NOT EXIST "%UserPath%\%TEMPTXT%" exit /B
REM We read the PostIT file into an Array
set var[0]=0
set /a idx=0
for /f "usebackq delims=" %%I in ("%UserPath%\%TEMPTXT%") do (
    set "var[!idx!]=%%I"
    set /a idx += 1
    )
REM We generate a text file with the high scores table
@echo HIGHEST SCORES:>"%PINemHiHS%\%TEMPTXT%.txt"
set /a "HSN=idx-5"
set /a "HS=idx-10"
:While
    IF %HSN% EQU %idx% GOTO EndWhile
        call echo %%var[!HSN!]%% %%var[!HS!]%%>>"%PINemHiHS%\%TEMPTXT%.txt"
        set /a HSN += 1
        set /a HS += 1
        GOTO While
:EndWhile
CALL python "%HiScoreDir%\reformat_scores.py" "%PINemHiHS%\%TEMPTXT%.txt" "%PINemHiHS%\%TEMPTXT%.txt" PostIt
GOTO PNG

:NVRAM
REM Start of NVRAM processing
ECHO Getting PinMAME NVRAM High Score>> %LogPath%
SET OUTPUT=%POPVPMedia%
SET TEMPTXT=%ROM_NAME%

REM if there is no nvram file, exit
IF NOT EXIST "%NVRamPath%\%TEMPTXT%.nv" exit /B
REM we will only process the nvram file if the rom is supported by PINemHi
for /F "usebackq delims=" %%A in ("%PINemHiPath%\supported.txt") do (
    if %%A==%TEMPTXT% (
        REM call PINemHi pipped to a txt file
        "%PINemHiPath%\pinemhi.exe" %TEMPTXT%.nv>"%PINemHiHS%\%TEMPTXT%.txt"
        )
    )
REM delete TXT files with size 0 as they are empty
for /f %%I in ("%PINemHiHS%\%TEMPTXT%.txt") do if %%~zI==0 del "%PINemHiHS%\%TEMPTXT%.txt"
GOTO PNG

:PNG
REM Call ImageMagick convert to create a PNG from the hiscore TXT file (note color, font and other options available)
REM Choose to size the resulting image based on the background file you use
REM if you'd like a monospaced output, add -font Courier
ECHO Checking if "%PINemHiHS%\%TEMPTXT%.txt" exists>> %LogPath%
IF NOT EXIST "%PINemHiHS%\%TEMPTXT%.txt" goto DONE

REM Check if we have already generated a high score for a matching file, don't waste time recreating
ECHO Found high score file. Checking if high score has changed...>> %LogPath%
SET "CompResults=Not Checked"
IF EXIST "%PINemHiHS%\%TEMPTXT%-done.txt" (
    FOR /F "skip=1 tokens=*" %%G IN ('FC "%PINemHiHS%\%TEMPTXT%-done.txt" "%PINemHiHS%\%TEMPTXT%.txt"') DO SET "CompResults=%%G"
)

REM Check outside of IF statement to allow delayed variable expansion to take place
IF "%CompResults%"=="FC: no differences encountered" (
    REM We've already generated a video for this high score file, so no need to regenerate
    ECHO High score is unchanged!>> %LogPath%
    DEL "%PINemHiHS%\%TEMPTXT%.txt"
)

IF EXIST "%PINemHiHS%\%TEMPTXT%.txt" (
    ECHO New High Score detected.  Generating high score image or video.>> %LogPath%
    REM We are going to fill in the DMD area with the high scores so use the DMD size
    REM Fill with black background as that is the transparent color used by PinUP Popper
    REM type "%PINemHiHS%\%TEMPTXT%.txt" | "%ImageMagick%\convert.exe" -font %Font% -background black -gravity center -fill grey -size 1776x445 caption:@- "%PINemHiPNG%\%TEMPTXT%.png"
    REM type "%PINemHiHS%\%TEMPTXT%.txt" | "%ImageMagick%\convert.exe" -font %Font% -background black -fill grey pango:@- -resize 1776x445 "%PINemHiPNG%\%TEMPTXT%.png"
    REM CALL python "%HiScoreDir%\text_to_image.py" "%PINemHiHS%\%TEMPTXT%.txt" "%PINemHiPNG%\%TEMPTXT%.png" "%Font%" --max_lines 8  --text_color "#ff5820" --size 1920x1080
    REM CALL python "%HiScoreDir%\text_to_video.py" --text_color #ff5820 --text_speed 120 "%PINemHiHS%\%TEMPTXT%.txt" "%OUTPUT%\%~2%Suffix%-new.gif" "%Font%" --size 1920x1080
    REM type "%PINemHiHS%\%TEMPTXT%.txt" | "%ImageMagick%\convert.exe" -background none -fill yellow -pointsize 26 pango:@- -resize 570x730 "%PINemHiPNG%\%TEMPTXT%.png"
    CALL python3 "%HiScoreDir%\text_to_image.py" --max_lines 16 --text_color "#f44c14" "%PINemHiHS%\%TEMPTXT%.txt" "%OUTPUT%\%~2%Suffix%.png" "%HiScoreDir%\Fonts\pinball.ttf" --size "1920x1080" --background_color "#000000"
    MOVE /Y "%PINemHiHS%\%TEMPTXT%.txt" "%PINemHiHS%\%TEMPTXT%-done.txt"
)

REM We used a temp file during creation process to avoid getting PinUp confused seeing the file partway done, now move it
IF EXIST "%OUTPUT%\%~2%Suffix%-new.mp4" (
    ECHO Moving high score video file to PinUP>> %LogPath%
    REM This can fail if Pinup is currently playing the video. :(  Maybe next time we will be able to move it.
    MOVE /Y "%OUTPUT%\%~2%Suffix%-new.mp4" "%OUTPUT%\%~2%Suffix%.mp4" 2>> %LogPath%
)

REM Call ImageMagick composite to merge previous PNG with the background image, and center it
REM IF EXIST "%PINemHiPNG%\%TEMPTXT%.png" (
REM    ECHO Creating high score png for PinUP>> %LogPath%
REM    "%ImageMagick%\composite.exe" "%PINemHiPNG%\%TEMPTXT%.png" "%PINemHiPNG%\%Background%" -gravity center "%OUTPUT%\%~2%Suffix%.png"
REM    REM Cleanup temp PNGs
REM    del "%PINemHiPNG%\%TEMPTXT%.png"
REM)

:DONE
ECHO High score processing complete.>> %LogPath%
REM done
exit /B