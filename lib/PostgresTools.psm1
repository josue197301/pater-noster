# PostgresTools.psm1
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
