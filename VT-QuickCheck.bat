
@echo off
setlocal EnableExtensions
chcp 65001 >nul
title VT-QuickCheck - VirusTotal
color 0B

echo ==========================================
echo             VT-QUICKCHECK
echo       URL SECURITY VERIFICATION
echo ==========================================
echo.

:: Carrega a chave de API local
if not exist "%~dp0config.bat" (
    echo ERRO: Arquivo config.bat nao encontrado.
    echo Crie esse arquivo com sua chave da API.
    pause
    exit /b 1
)

call "%~dp0config.bat"

if not defined VT_API_KEY (
    echo ERRO: Chave da API nao configurada.
    pause
    exit /b 1
)

:: Captura o endereco da area de transferencia
for /f "usebackq delims=" %%A in (`powershell.exe -NoProfile -Command "Get-Clipboard -Raw"`) do set "VT_URL=%%A"

if not defined VT_URL (
    echo ERRO: Area de transferencia vazia.
    pause
    exit /b 1
)

echo URL: %VT_URL%
echo.
echo [1/3] Enviando para o VirusTotal...
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $h=@{'x-apikey'=$env:VT_API_KEY;'accept'='application/json'}; try { $u=$env:VT_URL.Trim(); $parsed=$null; if(-not [Uri]::TryCreate($u,[UriKind]::Absolute,[ref]$parsed) -or $parsed.Scheme -notin @('http','https')){throw 'Endereco invalido. Informe uma URL HTTP ou HTTPS.'}; $r=Invoke-RestMethod -Uri 'https://www.virustotal.com/api/v3/urls' -Method Post -Headers $h -ContentType 'application/x-www-form-urlencoded' -Body @{url=$u}; $id=$r.data.id; if(-not $id){throw 'Identificador de analise nao recebido.'}; Write-Host ('ID: '+$id); $final=$null; for($i=1;$i -le 9;$i++){Write-Host ('Aguardando analise: '+$i+'/9'); Start-Sleep -Seconds 20; $final=Invoke-RestMethod -Uri ('https://www.virustotal.com/api/v3/analyses/'+$id) -Method Get -Headers $h; if($final.data.attributes.status -eq 'completed'){break}}; if($final.data.attributes.status -ne 'completed'){Write-Host 'RESULTADO: ANALISE PENDENTE.' -ForegroundColor Yellow; exit 2}; $s=$final.data.attributes.stats; $m=[int]$s.malicious; $sus=[int]$s.suspicious; $har=[int]$s.harmless; $und=[int]$s.undetected; Write-Host ''; Write-Host '========== RESULTADO =========='; Write-Host ('Maliciosos: '+$m); Write-Host ('Suspeitos: '+$sus); Write-Host ('Inofensivos: '+$har); Write-Host ('Sem deteccao: '+$und); if($m -gt 0){Write-Host 'VEREDITO: MALICIOSO!' -ForegroundColor Red} elseif($sus -gt 0){Write-Host 'VEREDITO: SUSPEITO!' -ForegroundColor Yellow} elseif($har -gt 0){Write-Host 'VEREDITO: SEM DETECCOES MALICIOSAS.' -ForegroundColor Green; Write-Host 'Isso nao garante seguranca.'} else {Write-Host 'VEREDITO: INCONCLUSIVO.' -ForegroundColor Yellow}; Write-Host '================================' } catch {Write-Host ''; Write-Host 'ERRO:' -ForegroundColor Red; Write-Host $_.Exception.Message; if($_.Exception.Response){Write-Host ('HTTP: '+[int]$_.Exception.Response.StatusCode)}; exit 1}"

echo.
echo Consulta encerrada.
echo.
pause

endlocal
