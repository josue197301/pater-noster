Import-Module  ".\lib\PNFilesTools.psm1"
Import-Module  ".\lib\PNDataTools.psm1"

# Carrega JSON de configuracoes
$configPath = ".\lib\backup-config-v0.1.json"
$config = Get-Content $configPath | ConvertFrom-Json

$DriveLetter = 
$NetworkPath = 

#cmd.exe /c "net use $DriveLetter $NetworkPath /user:$User $Password /persistent:yes"
#cmd.exe /c "net use $DriveLetter $NetworkPath /user:$User $Password /persistent:yes"

# Testa path solicitado

if ( !(Test-Path $args[0]) ) {
	Write-Host "Diretorio nao encontrado " $args[0];
}
# define data com base no segundo argumento
#$age = (Get-Date).AddDays(-$args[1])

<#Get-ChildItem $args[0] -Recurse -File | ForEach-Object{
	#$_ | Select-Object -Property *

}#>

Get-ChildItem $args[0] -Directory | ForEach-Object {
    <#if ($_.LastWriteTime -le $age){
        Write-Output "$($_.FullName)"
        Write-Output $_.LastWriteTime
        Write-Output  ""
        #Move-Item -Path $_.fullname -Destination "D:\CHPEO\TESTE2" -force
    }#>
    #Write-Output "===================="

    #Write-Output "$($_.FullName)"

    Get-ChildItem "$($_.FullName)" -File -Recurse | ForEach-Object {
        $fp = Get-FileProperties -FilePath  "$($_.FullName)"
        $fp.baseDir + "\" +$fp.baseName
        # formar query de busca
        $queryBuscaArquivo = "select max(arq_id), arq_nome, arq_path, date_trunc('minute',arq_ts_mod) as arq_ts_modif from arquivo WHERE date_trunc('minute', arq_ts_mod) = '$($fp.tsMod_F)'::timestamp AND arq_nome='$($fp.baseName)' AND arq_tam='$($fp.size)' AND arq_tipo='$($fp.extension)' group by arq_nome, arq_path, arq_ts_mod;";
        $queryBuscaArquivo ;
        # buscar correspondencia no banco
        $resBusca = Invoke-PostgresQuery -PgHost "$($config.database.host)" -Database "$($config.database.dbname)" -User "$($config.database.username)" -Query "$($queryBuscaArquivo)" -ReturnAsCsvObject;
        Write-Host "------------------`n# Ts - "$fp.baseName": "$fp.tsMod_F" | "$fp.tsMod
        if ( $resBusca.Count  -gt 0 ){ # encontrou correspondencia
            Write-Host "### Encontrado no banco: "$resBusca.arq_nome" | "$resBusca.arq_path" | "$resBusca.arq_ts_modif;
            $resBusca.arq_ts_modif
        } else { # registrar no banco e zipar
            
            # formar o nome do arquivo para zipar
            # - tirar md5 ? <não>

            <#$zipFileName = "$($fp.baseDir)\$($fp.baseName)_$($resBusca.arq_id)_$($fp.tsMod_F).zip"
            Write-Host "### Zipando para: "$zipFileName
            Compress-Archive -Path "$($fp.fullName)" -DestinationPath "$zipFileName" -Force #>
        }
    }
}
