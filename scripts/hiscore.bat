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

    REM Path to 7z
    SET "Zexepath=c:\Visual~1\Hiscores\7z"

    REM Folder where you want the VP high score PNGs with high scores placed (GameInfo, Topper, DMD, etc.)
    SET "POPVPMedia=C:\Visual Pinball\PinUPPopper\POPMedia\Visual Pinball X\DMD"

    REM Folder where you want the FP high score PNGs with high scores placed (GameInfo, Topper, DMD, etc.)
    SET "POPFPMedia=c:\Visual~1\Hiscores\"

    REM This suffix will be added to the second parameter passed (tablename) when saving high score PNGs
    SET "Suffix="

REM END OF VARIABLES DECLARATION

REM Need to change to the PINemHi folder in order for the exe to read its INI
cd "%PINemHiPath%"
REM Uncomment the next line to regenerate PINemHi supported roms DB
REM "%PINemHiPath%\pinemhi.exe" -lr>"%PINemHiPath%\supported.txt"

REM We will select the right parsing routine
SET ISTEXT=%3
if "%ISTEXT%" == "BAM" GOTO FUTURE
SET ISTEXT=%3
if "%ISTEXT%" == "UltraDMD" GOTO ULTRADMD
SET ISTEXT=%1
SET ISTEXT=%ISTEXT:~-5%
set ISTEXT=%ISTEXT:"=%
if "%ISTEXT%" == ".txt" GOTO POSTIT

GOTO NVRAM

:FUTURE
REM Start of fpram processing
SET TEMPTXT=%~2
SET OUTPUT=%POPFPMedia%
REM if there is no FP nvram file, exit
IF NOT EXIST "%FPNVRamPath%\%~2.fpram" exit
REM call PINemHi pipped to a txt file
"%PINemHiPath%\pinemhi.exe" %~2.fpram>"%PINemHiHS%\%~2.txt"
REM delete TXT files with size 0 as they are empty
for /f %%I in ("%PINemHiHS%\%~2.txt") do if %%~zI==0 del "%PINemHiHS%\%TEMPTXT%.txt"
GOTO PNG

:ULTRADMD
REM Start of ULTRADMD processing
SET TEMPTXT=%~1
SET OUTPUT=%POPVPMedia%
REM extract hiscore files from iStor
@echo High Scores>"%PINemHiHS%\%TEMPTXT%.txt"
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
GOTO PNG

:POSTIT
REM Start POSIT is file processing
SET TEMPTXT=%~1
SET TEMPTXT=%TEMPTXT:"=%
SET OUTPUT=%POPVPMedia%
REM if there is no PostIT file, exit
IF NOT EXIST "%UserPath%\%TEMPTXT%" exit
REM We read the PostIT file into an Array
set var[0]=0
set /a idx=0
for /f "usebackq delims=" %%I in ("%UserPath%\%TEMPTXT%") do (
    set "var[!idx!]=%%I"
    set /a idx += 1
    )
REM We generate a text file with the high scores table
@echo High scores:>"%PINemHiHS%\%5%.txt"
set /a "HSN=idx-5"
set /a "HS=idx-10"
:While
    IF %HSN% EQU %idx% GOTO EndWhile
        call echo %%var[!HSN!]%% %%var[!HS!]%%>>"%PINemHiHS%\%TEMPTXT%.txt"
        set /a HSN += 1
        set /a HS += 1
        GOTO While
:EndWhile
GOTO PNG

:NVRAM
REM Start of NVRAM processing
SET TEMPTXT=%~1
SET OUTPUT=%POPVPMedia%

REM if there is no nvram file, exit
IF NOT EXIST "%NVRamPath%\%TEMPTXT%.nv" exit
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
IF EXIST "%PINemHiHS%\%TEMPTXT%.txt" (
    type "%PINemHiHS%\%TEMPTXT%.txt" | "%ImageMagick%\convert.exe" -background none -fill yellow -pointsize 26 pango:@- -resize 570x730 "%PINemHiPNG%\%TEMPTXT%.png"
    )

REM Call ImageMagick composite to merge previous PNG with the background image, and center it
IF EXIST "%PINemHiPNG%\%TEMPTXT%.png" (
    "%ImageMagick%\composite.exe" "%PINemHiPNG%\%TEMPTXT%.png" "%PINemHiPNG%\%Background%" -gravity center "%OUTPUT%\%~2%Suffix%.png"
    REM Cleanup temp PNGs
    del "%PINemHiPNG%\%TEMPTXT%.png"
    )

REM done
exit /B