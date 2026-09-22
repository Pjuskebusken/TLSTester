param(
    [Parameter(Mandatory = $true)]
    [string]$Hostname,

    [int]$Port = 443,

    [string]$OpenSslPath = "C:\Program Files\Git\usr\bin\openssl.exe"
)

Write-Host "Testing TLS versions for: $Hostname`:$Port"
Write-Host ("-" * 73)

$versions = [ordered]@{
    "-tls1"   = "TLSv1.0"
    "-tls1_1" = "TLSv1.1"
    "-tls1_2" = "TLSv1.2"
    "-tls1_3" = "TLSv1.3"
}

foreach ($flag in $versions.Keys) {
    $result = "" | & $OpenSslPath s_client -connect "$Hostname`:$Port" $flag -cipher "DEFAULT@SECLEVEL=0" 2>&1 | Out-String

    if ($result -match "Cipher is (?!NONE)([A-Za-z0-9_-]+)") {
        "{0}: SUPPORTED   (cipher: {1})" -f $versions[$flag], $Matches[1]
    } else {
        "{0}: NOT SUPPORTED" -f $versions[$flag]
    }
}

Write-Host ("-" * 73)