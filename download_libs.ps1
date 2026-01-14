# Set security protocol to TLS 1.2 (required for many modern sites)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Function to ignore SSL errors (use with caution, but helpful for some local network environments)
if (-not ([System.Management.Automation.PSTypeName]'TrustAllCertsPolicy').Type) {
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

$libDir = "lib"
if (!(Test-Path -Path $libDir)) {
    New-Item -ItemType Directory -Path $libDir | Out-Null
    Write-Host "Created directory: $libDir"
}

# Define files to download with domestic mirrors (Staticfile/BootCDN) for better access in China
$files = @(
    @{
        Url = "https://cdn.staticfile.org/react/18.2.0/umd/react.production.min.js"
        Output = "react.production.min.js"
    },
    @{
        Url = "https://cdn.staticfile.org/react-dom/18.2.0/umd/react-dom.production.min.js"
        Output = "react-dom.production.min.js"
    },
    @{
        Url = "https://cdn.staticfile.org/babel-standalone/7.23.6/babel.min.js"
        Output = "babel.min.js"
    },
    @{
        Url = "https://cdn.staticfile.org/dayjs/1.11.10/dayjs.min.js"
        Output = "dayjs.min.js"
    },
    @{
        Url = "https://cdn.staticfile.org/antd/5.12.2/antd.min.js"
        Output = "antd.min.js"
    },
    @{
        Url = "https://cdn.staticfile.org/ant-design-icons/5.2.6/index.umd.min.js"
        Output = "ant-design-icons.min.js"
    }
)

foreach ($file in $files) {
    $outputPath = Join-Path $libDir $file.Output
    Write-Host "Downloading $($file.Output)..."
    try {
        Invoke-WebRequest -Uri $file.Url -OutFile $outputPath -UseBasicParsing
        Write-Host "Success: $($file.Output)" -ForegroundColor Green
    }
    catch {
        Write-Host "Error downloading $($file.Output): $_" -ForegroundColor Red
    }
}

Write-Host "Download complete. Dependencies are in '$libDir' folder."
