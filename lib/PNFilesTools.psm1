# PNFilesTools.psm1
#
# Módulo PowerShell para manipulação de arquivos e diretórios

# Get-FileProperties: Método para obter propriedades detalhadas de um arquivo
function Get-FileProperties {
    param (
        [string]$FilePath = ""
    )
    try {
		$file = Get-ChildItem $FilePath -File | Select-Object -Property *

		# Obter informações de segurança do arquivo
		$acl = Get-Acl -Path $file.FullName

		# Proprietário do arquivo
		$aFileOwner = $acl.Owner.Split("\\")

		$fileLastW = $file.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
		$fileLastA = $file.LastAccessTime.ToString("yyyy-MM-dd HH:mm:ss")
		$fileExt = $file.Extension.Substring(1)

		# CustomObject para armazenar propriedades
		$fileProps = [pscustomobject]@{
			baseName	= "$($file.Name)";
			baseDir		= "$($file.DirectoryName)";
			extension	= "$($fileExt)";
			username	= "$($aFileOwner[1])";
			domainUser	= "$($aFileOwner[0])";
			secGroups	= @();
			tsMod		= $file.LastWriteTime;
			tsAccess	= $file.LastAccessTime;
			tsMod_F		= "$($fileLastW)";
			tsAccess_F	= "$($fileLastA)";
			size		= "$($file.Length)";
		}

		# Grupos de segurança (entradas do tipo Group)
		$groups = $acl.Access | Where-Object {
			($_.IdentityReference -match "^(BUILTIN|NT AUTHORITY|S-1-5|REDEMARIOGATTI\\|GATTI\\|CHPEO\\)") -and
			($_.IdentityReference.Value -notmatch "^.*\\.*\$") # ignora contas de computador
		}
		foreach ($group in $groups) {
			$aGrp = $group.IdentityReference.ToString().Split("\\")
			$fileProps.secGroups += @{
				groupDomain="$($aGrp[0])";
				groupName="$($aGrp[1])"
			}
		}
        return $fileProps
    }
    catch {
        Write-Error "Erro: $_"
    }
}

# Compress-File: Método para compactar um arquivo em um arquivo ZIP
function Compress-File {
    param (
        [string]$FileDir,
        [string]$FileName,
        [string]$ZipDir,
        [string]$ZipFileName
    )
    try {
        Compress-Archive -Path "$($FileDir)\$($FileName)" -DestinationPath "$($ZipDir)\$($ZipFileName)" -Force
        Write-Host "Arquivo compactado com sucesso: $($ZipDir)\$($ZipFileName)"
    }
    catch {
        Write-Error "Erro ao compactar o arquivo: $_"
    }
}