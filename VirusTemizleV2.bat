@echo off
chcp 65001 >nul
title USB Virus Temizleyici - KAPSAMLI
color 0C

echo ============================================
echo    USB KISAYOL VIRUSU TEMIZLEYICI
echo           KAPSAMLI TEMIZLIK
echo ============================================
echo.

:: Yönetici kontrolü
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [HATA] Bu script yonetici olarak calistirilmali!
    echo Sag tikla ve "Yonetici olarak calistir" secin.
    pause
    exit /b 1
)

echo [1/10] VIRUS SERVISI DURDURULUYOR (u820397)...
sc stop u820397 2>nul
sc config u820397 start= disabled 2>nul
timeout /t 2 /nobreak >nul

echo [2/10] Virus surecleri durduruluyor...
taskkill /F /IM u255187.exe /T 2>nul
taskkill /F /IM u459185.exe /T 2>nul
taskkill /F /IM svctrl64.exe /T 2>nul
taskkill /F /IM printui.exe /T 2>nul
for /f "tokens=2" %%i in ('tasklist /fi "imagename eq u*.exe" /fo list ^| find "PID:"') do taskkill /F /PID %%i 2>nul
timeout /t 3 /nobreak >nul

echo [3/10] VIRUS SERVISI SILINIYOR...
sc delete u820397 2>nul
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\u820397" /f 2>nul

echo [4/10] ANA VIRUS DLL SILINIYOR (u820397.dll)...
takeown /F "C:\Windows\System32\u820397.dll" /A 2>nul
icacls "C:\Windows\System32\u820397.dll" /grant administrators:F 2>nul
del /F /Q "C:\Windows\System32\u820397.dll" 2>nul

echo [5/10] YEDEK VIRUS DOSYASI SILINIYOR (svctrl64.exe)...
takeown /F "C:\Windows\System32\svctrl64.exe" /A 2>nul
icacls "C:\Windows\System32\svctrl64.exe" /grant administrators:F 2>nul
del /F /Q "C:\Windows\System32\svctrl64.exe" 2>nul

echo [6/10] Virus klasoru siliniyor (wsvcz)...
takeown /F "C:\Windows\System32\wsvcz" /R /D Y >nul 2>&1
icacls "C:\Windows\System32\wsvcz" /grant administrators:F /T >nul 2>&1
rd /S /Q "C:\Windows\System32\wsvcz" 2>nul

echo [7/10] Windows Defender istisnalari temizleniyor...
powershell -Command "Remove-MpPreference -ExclusionPath 'C:\Windows\System32\wsvcz' -ErrorAction SilentlyContinue"
powershell -Command "Remove-MpPreference -ExclusionPath 'C:\Windows ' -ErrorAction SilentlyContinue"
powershell -Command "$exc = (Get-MpPreference).ExclusionPath; foreach($e in $exc){if($e -match 'sysvolume|wsvcz'){Remove-MpPreference -ExclusionPath $e}}"

echo [8/10] Sahte Windows klasoru siliniyor...
rd /S /Q "\\?\C:\Windows " 2>nul
rd /S /Q "\\?\C:\Windows  " 2>nul

echo [9/10] Tum surucuerdeki virus dosyalari temizleniyor...
for %%d in (D E F G H I J K L) do (
    if exist "%%d:\sysvolume" (
        echo       %%d: surucusu temizleniyor...
        attrib -h -s "%%d:\sysvolume" /S /D 2>nul
        rd /S /Q "%%d:\sysvolume" 2>nul
        for %%f in ("%%d:\*.lnk") do del /F /Q "%%f" 2>nul
        attrib -h -s "%%d:\*" /S /D 2>nul
    )
)

echo [10/10] Windows Defender taramasi baslatiliyor...
powershell -Command "Update-MpSignature; Start-MpScan -ScanPath 'C:\Windows\System32' -ScanType CustomScan"

echo.
echo ============================================
echo    TEMIZLIK TAMAMLANDI!
echo ============================================
echo.
echo ONEMLI: Bilgisayari SIMDI yeniden baslatin!
echo Yeniden baslatmadan USB takmayin!
echo.
echo Kontrol icin asagidaki komutlari calistirin:
echo   sc query u820397
echo   dir C:\Windows\System32\u820397.dll
echo   dir C:\Windows\System32\svctrl64.exe
echo.
pause
