@echo off
::set variables
Set /p Name= What is the end user's first and last name?
set d=%date%
set d=%d:/=_%
set d=%d: =_%
set Name=%Name: =_%
set uf=.\%d%_%Name%
set log=%uf%\Backup_Logs
set data=%log%\data.txt
set error=%log%\error.txt
set switches=/H /E /I /V /Y /C /D
::set variables
::make directory for the user
MD %log%
::make directory for the user

Setlocal
	:: Get windows Version numbers and set to _version var
		For /f "tokens=2 delims=[]" %%G in ('ver') Do (set _version=%%G)
	::Breaks up the Version numbers into three parts _major _minor and _build
		For /f "tokens=2,3,4 delims=. " %%G in ('echo %_version%') Do (set _major=%%G& set _minor=%%H& set _build=%%I)
	::Displays the version numbers on screen
		Echo Major version: %_major%  Minor Version: %_minor%.%_build% >%log%\UserInfo.txt
	::Checks the vernumbers and runs the custom command for each version.
		if "%_major%"=="5" goto sub5
		if "%_major%"=="6" goto sub6

		Echo unsupported version
		goto:next

	:sub5
		::Winxp or 2003
		if "%_minor%"=="2" goto sub_2003
		set docs=%userprofile%\My Documents
		set music=%docs%\My Music
		set videos=%docs%\My Videos
		set pictures=%docs%\My Pictures
		echo XP

		goto:next

	:sub_2003
		Echo Windows 2003 or XP 64 bit [%PROCESSOR_ARCHITECTURE%]

		goto:next

	:sub6
		if "%_minor%"=="1" goto sub7
		set docs=%userprofile%\Documents
		set music=%userprfile%\Music
		set videos=%userprfile%\Videos
		set pictures=%userprfile%\Pictures
		Echo Windows Vista or Windows 2008 [%PROCESSOR_ARCHITECTURE%]

		goto:next

	:sub7
		set docs=%userprofile%\Documents
		set music=%userprfile%\Music
		set videos=%userprfile%\Videos
		set pictures=%userprfile%\Pictures
		echo 7

		goto:next
	::Get Windows Version Numbers

:next

::creates info file
::user info
(@echo End User:	%Name% && echo Computer Name:	%computername% && echo User Name:	%username%) >> %log%\UserInfo.txt
::User info
::printer info
(@echo Printer Info:	) >> %log%\UserInfo.txt
net view %computername% | find /i "print" >> %log%\UserInfo.txt
::printer info

@echo Mapped Drives: >> %log%\UserInfo.txt
net use >> %log%\UserInfo.txt
::mapped drives
::creates info file
echo Info Logs Created
::Create Exclude list for later
echo %music% >.\Exclude.txt
echo %videos% >>.\Exclude.txt
echo %pictures% >>.\Exclude.txt
::Create Exclude list for later.

xcopy "%userprofile%\Desktop" .\%uf%\Desktop\ %switches% >%data% 2>%error%
@echo Desktop >>%data%
Echo Desktop Done.
::Desktop

xcopy "%userprofile%\Favorites" .\%uf%\Favorites\ %switches% >>%data% 2>>%error%
@echo Favorites >>%data%
echo Favorites Done
::Favorites

xcopy "%docs%" "%uf%\My Documents\" %switches% /Exclude:Exclude.txt >>%data% 2>>%error%
@echo Documents >>%data% >>%error%
del .\exclude.txt /q /f
echo Documents Done.
::Documents

xcopy "%music%" ".\%uf%\My Documents\My Music" %switches% >>%data% 2>>%error%
@echo Music >>%data% >>%error%
echo Music Done
::Music

xcopy "%videos%" ".\%uf%\My Documents\My Videos" %switches% >>%data% 2>>%error%
@echo Videos >>%data% >>%error%
echo Videos Done.
::Videos

xcopy "%pictures%" ".\%uf%\My Documents\My Pictures" %switches% >>%data% 2>>%error%
@echo Pictures >>%data% >>%error%
echo Pictures Done.
::Pictures

FOR /F "skip=125 tokens=* delims=" %%i in (Backup.bat) do echo %%i>>%uf%\Restore.bat
:: FOR copies the restore file to the backup directory. The next line skipps to the end of file so that the Restore does not run at the time of backup.
goto :eof
::Restore File below this point

@echo off

	set switches=/H /E /I /V /Y /C /D
	set log=.\Restore_Logs
	set error=%log%\errors.txt
	set restore=%log%\data.txt
	mkdir %log%

		Setlocal
:: Get windows Version numbers and set to _version var
		For /f "tokens=2 delims=[]" %%G in ('ver') Do (set _version=%%G)
::Breaks up the Version numbers into three parts _major _minor and _build
		For /f "tokens=2,3,4 delims=. " %%G in ('echo %_version%') Do (set _major=%%G& set _minor=%%H& set _build=%%I)
::Checks the vernumbers and runs the custom command for each version.
		if "%_major%"=="5" goto sub5
		if "%_major%"=="6" goto sub6

		Echo unsupported version
		goto:next

	:sub5
::Winxp or 2003
		if "%_minor%"=="2" goto sub_2003
		set docs=%userprofile%\My Documents
		set music=%docs%\My Music
		set videos=%docs%\My Videos
		set pictures=%docs%\My Pictures
		echo XP

		goto:next

	:sub_2003
::Windows 2003 or XP 64 Bit
		Echo Windows 2003 or XP 64 bit [%PROCESSOR_ARCHITECTURE%]

		goto:next

	:sub6
::Windows Vista or Windows 2008
		Echo Windows Vista or Windows 2008 [%PROCESSOR_ARCHITECTURE%]
		if "%_minor%"=="1" goto sub7
		set docs=%userprofile%\Documents
		set music=Music
		set videos=Videos
		set pictures=Pictures

		goto:next

	:sub7
:: Windows 7
		echo Windows 7? [%PROCESSOR_ARCHITECTURE%]
		set docs=%userprofile%\Documents
		set music=Music
		set videos=Videos
		set pictures=Pictures

		goto:next
::Get Windows Version Numbers

:next
echo "%videos%" >.\Exclude.txt
echo "%music%">>.\Exclude.txt
echo "%pictures%">>.\Exclude.txt

@echo %computername% >"%restore%"

xcopy Desktop "%userprofile%\Desktop" %switches% >>%restore% 2>>%error%
@echo Desktop >>"%restore%"
echo Desktop Done

xcopy Favorites "%userprofile%\Favorites" %switches% >>%restore% 2>>%error%
@echo Favorites >>"%restore%"
echo Favorites Done

xcopy "My Documents" "%docs%" %switches%  /Exclude:Exclude.txt >>%restore% 2>>%error%
@echo Documents >>"%restore%"
echo My Documents Done

xcopy ".\My Documents\My Music" "%userprofile%\%music%" %switches% >>%restore% 2>>%error%
@echo Music >>"%restore%"
echo Music Done

xcopy "My Documents\My Videos" "%userprofile%\%videos%" %switches% >>%restore% 2>>%error%
@echo Videos >>"%restore%"
echo My Videos Done

xcopy "My Documents\My Pictures" "%userprofile%\%pictures%" %switches% >>%restore% 2>>%error%
@echo Pictures >>"%restore%"
echo My Pictures Done

del .\Exclude.txt
::Stanley McMillan
::stanthepcman@gmail.com
