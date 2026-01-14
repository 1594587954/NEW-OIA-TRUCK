# Set security protocol to TLS 1.2, 1.1, 1.0 (to cover all bases)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls

# Trust all certificates (to bypass SSL/TLS errors in some environments)
if ("TrustAllCertsPolicy" -as [type]) {
    # Policy already defined
} else {
    add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
}

# Also set the callback for newer .NET versions
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

$libDir = Join-Path $PSScriptRoot "lib"
if (!(Test-Path $libDir)) {
    New-Item -ItemType Directory -Path $libDir | Out-Null
    Write-Host "Created lib directory at $libDir"
}

$files = @(
    @{ Url = "https://cdn.staticfile.org/react/18.2.0/umd/react.production.min.js"; Name = "react.production.min.js" },
    @{ Url = "https://cdn.staticfile.org/react-dom/18.2.0/umd/react-dom.production.min.js"; Name = "react-dom.production.min.js" },
    @{ Url = "https://cdn.staticfile.org/babel-standalone/7.23.5/babel.min.js"; Name = "babel.min.js" },
    @{ Url = "https://cdn.staticfile.org/dayjs/1.11.10/dayjs.min.js"; Name = "dayjs.min.js" },
    @{ Url = "https://cdn.staticfile.org/antd/5.11.0/antd.min.js"; Name = "antd.min.js" },
    @{ Url = "https://cdn.staticfile.org/ant-design-icons/5.2.6/index.umd.min.js"; Name = "index.umd.min.js" }
)

foreach ($file in $files) {
    $outputPath = Join-Path $libDir $file.Name
    Write-Host "Downloading $($file.Name)..."
    try {
        Invoke-WebRequest -Uri $file.Url -OutFile $outputPath -UseBasicParsing
        Write-Host "Success: $($file.Name)"
    } catch {
        Write-Error "Failed to download $($file.Url): $_"
    }
}

Write-Host "Download complete. Please verify files in $libDir"
