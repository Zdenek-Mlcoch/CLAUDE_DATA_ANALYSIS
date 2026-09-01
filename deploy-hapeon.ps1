# Nahrani webu (slozka docs/) na FTP hosting hapeon.cz (PrestaHost)
# Pouziti: spustte v PowerShell z korene projektu:  .\deploy-hapeon.ps1
# Skript se zepta na FTP heslo - nikde se neuklada.

$FtpHost   = "ftp.hapeon.cz"
$FtpUser   = "zdenekmlcoch.hapeon.cz"
$RemoteDir = ""   # koren FTP uctu (/home/html/hapeon.cz/); pokud soubory pristanou jinam, upravte

$LocalDir = Join-Path $PSScriptRoot "docs"
if (-not (Test-Path $LocalDir)) { Write-Host "Slozka docs/ nenalezena." -ForegroundColor Red; exit 1 }

$sec  = Read-Host "FTP heslo pro $FtpUser" -AsSecureString
$pass = [System.Net.NetworkCredential]::new("", $sec).Password

$files = Get-ChildItem $LocalDir -File -Recurse | Where-Object { $_.Name -notin @(".nojekyll", "CNAME") }
$ok = 0; $fail = 0
foreach ($f in $files) {
  $rel = $f.FullName.Substring($LocalDir.Length + 1) -replace '\\','/'
  $prefix = if ($RemoteDir) { "$RemoteDir/" } else { "" }
  $target = "ftp://$FtpHost/$prefix$rel"
  & curl.exe --silent --show-error --ssl -k --ftp-create-dirs -T $f.FullName --user "${FtpUser}:$pass" $target
  if ($LASTEXITCODE -eq 0) { $ok++; Write-Host "OK   $rel" } else { $fail++; Write-Host "CHYBA $rel" -ForegroundColor Red }
}
$pass = $null

Write-Host ""
Write-Host "Nahrano: $ok souboru, chyb: $fail"
if ($fail -eq 0) { Write-Host "Hotovo - zkontrolujte https://hapeon.cz/" -ForegroundColor Green }
else { Write-Host "Nektera nahrani selhala - zkontrolujte heslo, pripadne nastavte `$RemoteDir." -ForegroundColor Yellow }
