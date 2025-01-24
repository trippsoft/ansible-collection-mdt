#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.SharedFunctions

$spec = @{
    options = @{
        installation_path = @{
            type = 'path'
            required = $false
            default = 'C:\Program Files\Microsoft Deployment Toolkit'
        }
        compress = @{
            type = 'bool'
            required = $false
            default = $false
        }
        force = @{
            type = 'bool'
            required = $false
            default = $false
        }
        mdt_share_path = @{
            type = 'str'
            required = $true
        }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-MDTModule -InstallationPath $module.Params.installation_path

$compress = $module.Params.compress
$force = $module.Params.force
$mdtSharePath = $module.Params.mdt_share_path

if (-not (Test-Path -LiteralPath $mdtSharePath))
{
    $module.FailJson("MDT share path '$mdtSharePath' does not exist.")
}

$mdtDrive = Get-MDTPSDrive -Path $mdtSharePath

if ($null -eq $mdtDrive)
{
    $module.FailJson("Failed to find or create MDT PowerShell drive for '$mdtSharePath'.")
}

$settingsXmlPath = "$($mdtSharePath)\Control\Settings.xml"

if (-not (Test-Path -LiteralPath $settingsXmlPath))
{
    $module.FailJson("Settings.xml file does not exist at '$settingsXmlPath'.")
}

$settingsXml = [XML](Get-Content -Path $settingsXmlPath)

$useLiteTouchISO = [bool]::Parse($settingsXml.Settings.'Boot.x64.GenerateLiteTouchISO')
$useGenericISO = [bool]::Parse($settingsXml.Settings.'Boot.x64.GenerateGenericISO')
$useGenericWIM = [bool]::Parse($settingsXml.Settings.'Boot.x64.GenerateGenericWIM')

$liteTouchISOFilename = $settingsXml.Settings.'Boot.x64.LiteTouchISOName'
$genericISOFilename = $settingsXml.Settings.'Boot.x64.GenericISOName'

$liteTouchWIMPath = "$($mdtSharePath)\Boot\LiteTouchPE_x64.wim"
$liteTouchISOPath = "$($mdtSharePath)\Boot\$($liteTouchISOFilename)"
$genericWIMPath = "$($mdtSharePath)\Boot\Generic_x64.wim"
$genericISOPath = "$($mdtSharePath)\Boot\$($genericISOFilename)"

if (Test-Path -Path $liteTouchWIMPath)
{
    $previousLiteTouchWIMHash = Get-FileHash -Path $liteTouchWIMPath -Algorithm SHA256
}

if ((Test-Path -Path $liteTouchISOPath) -and $useLiteTouchISO)
{
    $previousLiteTouchISOHash = Get-FileHash -Path $liteTouchISOPath -Algorithm SHA256
}

if ((Test-Path -Path $genericWIMPath) -and $useGenericWIM)
{
    $previousGenericWIMHash = Get-FileHash -Path $genericWIMPath -Algorithm SHA256
}

if ((Test-Path -Path $genericISOPath) -and $useGenericISO)
{
    $previousGenericISOHash = Get-FileHash -Path $genericISOPath -Algorithm SHA256
}

$module.Result["changed"] = $false

if ($force)
{
    Update-MDTDeploymentShare -Path "$($mdtDrive.Name):" -Force | Out-Null
}
else
{
    Update-MDTDeploymentShare -Path "$($mdtDrive.Name):" -Compress:$compress | Out-Null
}

$liteTouchWIMHash = Get-FileHash -Path $liteTouchWIMPath -Algorithm SHA256

if ($previousLiteTouchWIMHash.Hash -ne $liteTouchWIMHash.Hash)
{
    $module.Result["changed"] = $true
    $module.Result["litetouch_wim"] = @{
        path = $liteTouchWIMPath
        sha256_hash = $liteTouchWIMHash.Hash
        sha256_hash_previous = $previousLiteTouchWIMHash.Hash
    }
}
else
{
    $module.Result["litetouch_wim"] = @{
        path = $liteTouchWIMPath
        sha256_hash = $liteTouchWIMHash.Hash
    }
}

if ($useLiteTouchISO)
{
    $liteTouchISOHash = Get-FileHash -Path $liteTouchISOPath -Algorithm SHA256

    if ($null -eq $previousLiteTouchISOHash)
    {
        $module.Result["changed"] = $true
        $module.Result["litetouch_iso"] = @{
            path = $liteTouchISOPath
            sha256_hash = $liteTouchISOHash.Hash
            sha256_hash_previous = $null
        }
    }
    elseif ($previousLiteTouchISOHash.Hash -ne $liteTouchISOHash.Hash)
    {
        $module.Result["changed"] = $true
        $module.Result["litetouch_iso"] = @{
            path = $liteTouchISOPath
            sha256_hash = $liteTouchISOHash.Hash
            sha256_hash_previous = $previousLiteTouchISOHash.Hash
        }
    }
    else
    {
        $module.Result["litetouch_iso"] = @{
            path = $liteTouchISOPath
            sha256_hash = $liteTouchISOHash.Hash
        }
    }
}

if ($useGenericWIM)
{
    $genericWIMHash = Get-FileHash -Path $genericWIMPath -Algorithm SHA256

    if ($null -eq $previousGenericWIMHash)
    {
        $module.Result["changed"] = $true
        $module.Result["generic_wim"] = @{
            path = $genericWIMPath
            sha256_hash = $genericWIMHash.Hash
            sha256_hash_previous = $null
        }
    }
    elseif ($previousGenericWIMHash.Hash -ne $genericWIMHash.Hash)
    {
        $module.Result["changed"] = $true
        $module.Result["generic_wim"] = @{
            path = $genericWIMPath
            sha256_hash = $genericWIMHash.Hash
            sha256_hash_previous = $previousGenericWIMHash.Hash
        }
    }
    else
    {
        $module.Result["generic_wim"] = @{
            path = $genericWIMPath
            sha256_hash = $genericWIMHash.Hash
        }
    }
}

if ($useGenericISO)
{
    $genericISOHash = Get-FileHash -Path $genericISOPath -Algorithm SHA256

    if ($null -eq $previousGenericISOHash)
    {
        $module.Result["changed"] = $true
        $module.Result["generic_iso"] = @{
            path = $genericISOPath
            sha256_hash = $genericISOHash.Hash
            sha256_hash_previous = $null
        }
    }
    elseif ($previousGenericISOHash.Hash -ne $genericISOHash.Hash)
    {
        $module.Result["changed"] = $true
        $module.Result["generic_iso"] = @{
            path = $genericISOPath
            sha256_hash = $genericISOHash.Hash
            sha256_hash_previous = $previousGenericISOHash.Hash
        }
    }
    else
    {
        $module.Result["generic_iso"] = @{
            path = $genericISOPath
            sha256_hash = $genericISOHash.Hash
        }
    }
}

$mdtDrive | Remove-PSDrive | Out-Null

$module.ExitJson()
