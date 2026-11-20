
# ==========================================
# VT-QuickCheck - VirusTotal URL Scanner
# PowerShell Engine
# ==========================================

$ErrorActionPreference = "Stop"

try {
    # Validacao da chave
    $apiKey = $env:VT_API_KEY

    if ([string]::IsNullOrWhiteSpace($apiKey)) {
        throw "Chave da API nao encontrada."
    }

    # Captura da area de transferencia
    $url = (Get-Clipboard -Raw).Trim()

    if ([string]::IsNullOrWhiteSpace($url)) {
        throw "A area de transferencia esta vazia."
    }

    # Validacao do endereco
    $parsedUrl = $null

    if (
        -not [Uri]::TryCreate(
            $url,
            [UriKind]::Absolute,
            [ref]$parsedUrl
        ) -or
        $parsedUrl.Scheme -notin @("http", "https")
    ) {
        throw "Endereco invalido. Informe uma URL HTTP ou HTTPS."
    }

    # Configuracao da API
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $headers = @{
        "x-apikey" = $apiKey
        "accept"   = "application/json"
    }

    Write-Host "URL: $url"
    Write-Host ""
    Write-Host "[1/3] Enviando para o VirusTotal..."

    # Envio da URL
    $encodedUrl = [Uri]::EscapeDataString($url)
    $body = "url=$encodedUrl"

    $response = Invoke-RestMethod `
        -Uri "https://www.virustotal.com/api/v3/urls" `
        -Method Post `
        -Headers $headers `
        -ContentType "application/x-www-form-urlencoded" `
        -Body $body

    $analysisId = $response.data.id

    if (-not $analysisId) {
        throw "Identificador da analise nao recebido."
    }

    Write-Host "Analise ID: $analysisId"
    Write-Host ""

    # Acompanhamento da analise
    $analysis = $null

    for ($i = 1; $i -le 9; $i++) {

        Write-Host "[2/3] Aguardando analise ($i/9)..."

        Start-Sleep -Seconds 20

        $analysis = Invoke-RestMethod `
            -Uri "https://www.virustotal.com/api/v3/analyses/$analysisId" `
            -Method Get `
            -Headers $headers

        if ($analysis.data.attributes.status -eq "completed") {
            break
        }
    }

    # Verificacao do processamento
    if ($analysis.data.attributes.status -ne "completed") {

        Write-Host ""
        Write-Host "RESULTADO: ANALISE AINDA PENDENTE." -ForegroundColor Yellow
        Write-Host "O VirusTotal nao concluiu dentro do tempo de espera."

        exit 2
    }

    # Extracao das estatisticas
    $stats = $analysis.data.attributes.stats

    $malicious  = [int]$stats.malicious
    $suspicious = [int]$stats.suspicious
    $harmless   = [int]$stats.harmless
    $undetected = [int]$stats.undetected

    # Exibicao dos resultados
    Write-Host ""
    Write-Host "=========================================="
    Write-Host "             RESULTADO FINAL"
    Write-Host "=========================================="

    Write-Host "Maliciosos:   $malicious"
    Write-Host "Suspeitos:    $suspicious"
    Write-Host "Inofensivos:  $harmless"
    Write-Host "Sem deteccao: $undetected"

    Write-Host ""

    if ($malicious -gt 0) {

        Write-Host "VEREDITO: SITE MALICIOSO!" -ForegroundColor Red

    }
    elseif ($suspicious -gt 0) {

        Write-Host "VEREDITO: SITE SUSPEITO!" -ForegroundColor Yellow

    }
    elseif ($harmless -gt 0) {

        Write-Host "VEREDITO: SEM DETECCOES MALICIOSAS." -ForegroundColor Green
        Write-Host "Isso nao garante que o site seja seguro."

    }
    else {

        Write-Host "VEREDITO: INCONCLUSIVO." -ForegroundColor Yellow

    }

    Write-Host "=========================================="
    Write-Host ""
    Write-Host "[3/3] Consulta finalizada."

}
catch {

    Write-Host ""
    Write-Host "ERRO NA CONSULTA:" -ForegroundColor Red
    Write-Host $_.Exception.Message

    if ($_.Exception.Response) {

        $statusCode = [int]$_.Exception.Response.StatusCode

        Write-Host "HTTP Status: $statusCode"

        if ($statusCode -eq 429) {
            Write-Host "Limite de requisicoes da API atingido."
        }
    }

    exit 1
}
