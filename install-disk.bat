::run as admin
if defined SESSIONNAME (PowerShell start """%~0""" -verb RunAs & Exit /B)

echo list disk | diskpart
echo input disk number
set /p disk_num=

(
  echo SELECT DISK %disk_num%
  echo CLEAN
  echo CONVERT GPT
  echo CREATE PARTITION EFI SIZE=100
  echo FORMAT QUICK FS=FAT32
  echo ASSIGN LETTER="S"
  echo CREATE PARTITION MSR SIZE=16
  echo CREATE PARTITION PRIMARY
  echo SHRINK MINIMUM=500
  echo FORMAT QUICK FS=NTFS
  echo ASSIGN LETTER="W"
  echo CREATE PARTITION PRIMARY
  echo FORMAT QUICK FS=NTFS
) | diskpart

DISM /Apply-Image /ImageFile:D:\Sources\install.wim /index:1 /ApplyDir:W:\

DISM /Image:W:\ /Set-LayeredDriver:6

BCDBOOT W:\Windows /l ja-jp /s S: /f UEFI
