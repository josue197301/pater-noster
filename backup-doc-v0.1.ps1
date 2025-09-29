# Carrega JSON de configuracoes
$configPath = ".\lib\backup-config-v0.1.json"
$config = Get-Content $configPath | ConvertFrom-Json

$DriveLetter = 
$NetworkPath = 

cmd.exe /c "net use $DriveLetter $NetworkPath /user:$User $Password /persistent:yes"
#cmd.exe /c "net use $DriveLetter $NetworkPath /user:$User $Password /persistent:yes"



# Testa path solicitado



if ( !(Test-Path $args[0]) ) {
	Write-Host "Diretorio nao encontrado " $args[0];
}
# define data com base no segundo argumento
$age = (Get-Date).AddDays(-$args[1])

Get-ChildItem $args[0] -Recurse -File | foreach{
	#$_ | Select-Object -Property *

}

#Get-ChildItem $args[0] -Recurse -File | foreach{
    <#if ($_.LastWriteTime -le $age){
        Write-Output "$($_.FullName)"
        Write-Output $_.LastWriteTime
        Write-Output  ""
        #Move-Item -Path $_.fullname -Destination "D:\CHPEO\TESTE2" -force
    }#>
    
#}
