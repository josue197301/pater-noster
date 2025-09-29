# backup-doc v0.1
#
# Importa módulo
Import-Module  ".\lib\SMBFileTools.psm1"

$fp = Get-FileProperties -FilePath  $args[0]

$fp
$fp.secGroups
# $fp.secGroups| Where-Object { $_.Key -match "Value" }
Write-Host "_______________"
#$fp.secGroups| Where-Object { $_.Value -like "*Adm*" }
$filter = $fp.secGroups| Where-Object { $_.groupName -like "FS*" } | Format-Table
$Filter
Write-Host "_______________"