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
    <# insert 
        into pn.stored_file (sfi_id, sfi_relative_path, sfi_name, 
                            sfi_volume_id, sfi_size_bytes, sfi_last_modified, 
                            sfi_last_access, sfi_hash_md5, sfi_user_id) 
        values (1, 'docs', 'file1.txt', 
                            1, 1234, '2024-06-01 12:00:00', 
                            '2024-06-10 12:00:00', 'd41d8cd98f00b204e9800998ecf8427e', 1);
    #>
    $insertQueries = [pscustomobject]@{
        Arquivo	= "INSERT INTO arquivo (arq_nome, ...";
        Grupos = @();
    }
    $insertQueries.Grupos += "INSERT 1 INTO grupos (arq_nome, ...";
    $insertQueries.Grupos += "INSERT 2 INTO grupos (arq_nome, ...";
    
    return $insertQueries
}