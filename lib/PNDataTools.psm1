# PNDataTools.psm1
function Invoke-PostgresQuery {
    param (
        [string]$PgHost,
        [string]$Database,
        [string]$User,
        [string]$Query,
        [string]$PsqlPath = "C:\Program Files\PostgreSQL\13\bin\psql.exe",
        [string]$OutputFile = $null,
        [switch]$ReturnAsCsvObject
    )

    $originalOutputEncoding = [Console]::OutputEncoding
    $originalInputEncoding = [Console]::InputEncoding

    try {
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        [Console]::InputEncoding = [System.Text.Encoding]::UTF8

        $pgcmd = "`"$PsqlPath`" -h $PgHost -U $User -d $Database --csv -c `"$Query`""
        $result = cmd.exe /c $pgcmd

        if ($OutputFile) {
            $result | Out-File -FilePath $OutputFile -Encoding utf8
        }

        if ($ReturnAsCsvObject) {
            return $result | ConvertFrom-Csv
        } else {
            return $result
        }
    }
    catch {
        Write-Error "Erro ao executar a query: $_"
    }
    finally {
        [Console]::OutputEncoding = $originalOutputEncoding
        [Console]::InputEncoding = $originalInputEncoding
    }
}

function Format-SQLFileInsert {
    param (
        [PSCustomObject[]]$FileProperties
    )
    # $sqlInsertArquivo = "INSERT INTO arquivo (arq_nome, ..." #arq_path, arq_tam, arq_ts_mod, arq_ts_acess, arq_ext, arq_user, arq_domainuser, arq_hash_md5) VALUES "
    # CustomObject para armazenar queries
    #$insertQueries = "asdfg"
    
    $insertQueries = [pscustomobject]@{
        Arquivo	= "INSERT INTO arquivo (arq_nome, ...";
        Grupos = @();
    }
    $insertQueries.Grupos += "INSERT 1 INTO grupos (arq_nome, ...";
    $insertQueries.Grupos += "INSERT 2 INTO grupos (arq_nome, ...";
    
    return $insertQueries
}