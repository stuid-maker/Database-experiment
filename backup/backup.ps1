# Run from repo root: powershell -ExecutionPolicy Bypass -File .\backup\backup.ps1
# If env MYSQL_PWD is set, it is used and no prompt is shown.
# Redirects output from backup\ (no Chinese path in mysqldump --result-file).
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

if ($env:MYSQL_PWD) {
    $plain = $env:MYSQL_PWD
} else {
    $pass = Read-Host "MySQL root password" -AsSecureString
    $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass)
    try {
        $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    } finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr) | Out-Null
    }
}

if (-not (Get-Command mysqldump -ErrorAction SilentlyContinue)) {
    Write-Error "mysqldump not found. Add MySQL bin to PATH."
}

$backupDir = Join-Path $root "backup"
$outFile = Join-Path $backupDir "scs_backup.sql"
$prevPwd = $env:MYSQL_PWD
$env:MYSQL_PWD = $plain

try {
    Push-Location $backupDir
    cmd /c "mysqldump -u root --databases scs --routines --triggers --events --default-character-set=utf8mb4 --single-transaction > scs_backup.sql"
    $exit = $LASTEXITCODE
    if ($exit -ne 0) {
        Write-Warning "Could not write scs_backup.sql (file in use?). Writing scs_backup_dump.sql instead."
        cmd /c "mysqldump -u root --databases scs --routines --triggers --events --default-character-set=utf8mb4 --single-transaction > scs_backup_dump.sql"
        $exit = $LASTEXITCODE
        if ($exit -eq 0) {
            $outFile = Join-Path $backupDir "scs_backup_dump.sql"
        }
    }
} finally {
    Pop-Location
    if ($prevPwd) { $env:MYSQL_PWD = $prevPwd } else { Remove-Item Env:MYSQL_PWD -ErrorAction SilentlyContinue }
}

if ($exit -ne 0) { exit $exit }

$len = (Get-Item $outFile).Length
Write-Host "Wrote $outFile ($len bytes)"
if ($len -lt 500) {
    Write-Warning "Backup file is very small; check database scs and mysqldump errors."
}
