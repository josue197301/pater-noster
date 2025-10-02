# SMBFileTools.psm1
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