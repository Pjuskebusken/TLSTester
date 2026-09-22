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
#Make an OpenSSL s_client call for each TLS version and check if the connection is successful. If it is, print the version and the cipher used. If not, print that the version is not supported.
foreach ($flag in $versions.Keys) {
    $result = "" | & $OpenSslPath s_client -connect "$Hostname`:$Port" $flag -cipher "DEFAULT@SECLEVEL=0" 2>&1 | Out-String

    if ($result -match "Cipher is (?!NONE)([A-Za-z0-9_-]+)") {
        "{0}: SUPPORTED   (cipher: {1})" -f $versions[$flag], $Matches[1]
    } else {
        "{0}: NOT SUPPORTED" -f $versions[$flag]
    }
}

Write-Host ("-" * 73)

$pqcGroups = [ordered]@{
    "X25519MLKEM768"     = "ML-KEM768 + X25519"
    "SecP256r1MLKEM768"  = "ML-KEM768 + P-256"
    "SecP384r1MLKEM1024" = "ML-KEM1024 + P-384"
    "MLKEM768"           = "ML-KEM768 (pure)"
}

$pqc = "" | & $OpenSslPath s_client -connect "$Hostname`:$Port" -groups ($pqcGroups.Keys -join ":") 2>&1 | Out-String
$negotiated = if ($pqc -match "Negotiated TLS1\.3 group:\s*(\S+)") { $Matches[1] }

if ($negotiated -and $pqcGroups[$negotiated]) {
    "PQC: SUPPORTED   ($($pqcGroups[$negotiated]))"
} else {
    "PQC: NOT SUPPORTED"
}
Write-Host ("-" * 73)