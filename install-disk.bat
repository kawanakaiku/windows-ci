::run as admin
if defined SESSIONNAME (PowerShell start """%~0""" -verb RunAs & Exit /B)

@echo off

echo list disk | diskpart
echo input disk number:
set /p disk_num=

echo input wim file:
set /p wim_file=

if not exist "%wim_file%" (
  echo "%wim_file%" does not exist
  pause
  exit /b 1
)

echo install drivers(y/n):
set /p install_drivers=

if "%install_drivers%"=="y" (
  echo input drvers path:
  set /p drivers_dir=
  if not exist "%drivers_dir%" (
    echo "%drivers_dir%" does not exist
    pause
    exit /b 1
  )
)

echo reboot on finish (y/n):
set /p reboot=


(
  echo SELECT DISK %disk_num%
  echo CLEAN
  echo CONVERT GPT
  echo CREATE PARTITION EFI SIZE=100
  echo FORMAT QUICK FS=FAT32
  echo ASSIGN LETTER=S
  echo CREATE PARTITION MSR SIZE=16
  echo CREATE PARTITION PRIMARY
  echo FORMAT QUICK FS=NTFS
  echo ASSIGN LETTER=W
) | diskpart

if not exist W: (
  echo W: does not exist
  pause
  exit /b 1
)

DISM /Apply-Image /ImageFile:"%wim_file%" /index:1 /ApplyDir:W:\

if not exist W:\Windows (
  echo W:\Windows does not exist
  echo maybe failed to install
  pause
  exit /b 1
)

DISM /Image:W:\ /Set-LayeredDriver:6

BCDBOOT W:\Windows /l ja-jp /s S: /f UEFI

if "%install_drivers%"=="y" (
  Dism /Image:W:\ /Add-Driver /Driver:"%drivers_dir%" /Recurse
)

MountVol W: /D
MountVol S: /D

if not errorlevel 0 (
  echo errorlevel not 0
  pause
  exit /b %errorlevel%
) else if /i "%reboot:~0,1%"=="y" (
  shutdown.exe /r /t 0
)
