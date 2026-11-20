
@echo off
setlocal
chcp 65001 >nul
title VT-QuickCheck - VirusTotal
color 0B

echo ==========================================
echo             VT-QUICKCHECK
echo       URL SECURITY VERIFICATION
echo ==========================================
echo.

if not exist "%~dp0config.bat" (
    echo ERRO: config.bat nao encontrado.
    echo.
    echo Copie config.example.bat para config.bat
    echo e configure sua chave do VirusTotal.
    pause
    exit /b 1
)

call "%~dp0config.bat"

if not defined VT_API_KEY (
    echo ERRO: Chave da API nao configurada.
    pause
    exit /b 1
)

if not exist "%~dp0VT-QuickCheck.ps1" (
    echo ERRO: VT-QuickCheck.ps1 nao encontrado.
    pause
    exit /b 1
)

set "VT_API_KEY=%VT_API_KEY%"

echo Iniciando verificacao...
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0VT-QuickCheck.ps1"

echo.
echo ==========================================
echo Consulta encerrada.
echo ==========================================
echo.
pause

endlocal
