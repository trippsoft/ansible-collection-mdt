#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.Common

$spec = @{
    options = @{
        installation_path = @{
            type = 'path'
            required = $false
            default = 'C:\Program Files\Microsoft Deployment Toolkit'
        }
        mdt_share_path = @{
            type = 'path'
            required = $true
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
    }
    supports_check_mode = $false
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-MDTModule -Module $module | Out-Null

$compress = $module.Params.compress
$force = $module.Params.force
$mdtSharePath = $module.Params.mdt_share_path

$mdtDrive = Get-MDTPSDrive -Module $module -ReadWrite

$rootFolder = Get-Item -LiteralPath "$($mdtDrive.Name):\"

$useLiteTouchISO = [bool]::Parse($rootFolder.Item('Boot.x64.GenerateLiteTouchISO'))
$useGenericISO = [bool]::Parse($rootFolder.Item('Boot.x64.GenerateGenericISO'))
$useGenericWIM = [bool]::Parse($rootFolder.Item('Boot.x64.GenerateGenericWIM'))

$liteTouchISOFilename = $rootFolder.Item('Boot.x64.LiteTouchISOName')
$genericISOFilename = $rootFolder.Item('Boot.x64.GenericISOName')

$liteTouchWIMPath = "$($mdtSharePath)\Boot\LiteTouchPE_x64.wim"
$liteTouchISOPath = "$($mdtSharePath)\Boot\$($liteTouchISOFilename)"
$genericWIMPath = "$($mdtSharePath)\Boot\Generic_x64.wim"
$genericISOPath = "$($mdtSharePath)\Boot\$($genericISOFilename)"

$module.Diff.before = @{}
$module.Diff.after = @{}

if (Test-Path -LiteralPath $liteTouchWIMPath) {
    $previousLiteTouchWIMHash = Get-FileHash -LiteralPath $liteTouchWIMPath -Algorithm SHA256
    $module.Diff.before.litetouch_wim = @{
        path = $liteTouchWIMPath
        sha256_hash = $previousLiteTouchWIMHash.Hash
    }
}

if ((Test-Path -LiteralPath $liteTouchISOPath) -and $useLiteTouchISO) {
    $previousLiteTouchISOHash = Get-FileHash -LiteralPath $liteTouchISOPath -Algorithm SHA256
    $module.Diff.before.litetouch_iso = @{
        path = $liteTouchISOPath
        sha256_hash = $previousLiteTouchISOHash.Hash
    }
}

if ((Test-Path -LiteralPath $genericWIMPath) -and $useGenericWIM) {
    $previousGenericWIMHash = Get-FileHash -LiteralPath $genericWIMPath -Algorithm SHA256
    $module.Diff.before.generic_wim = @{
        path = $genericWIMPath
        sha256_hash = $previousGenericWIMHash.Hash
    }
}

if ((Test-Path -LiteralPath $genericISOPath) -and $useGenericISO) {
    $previousGenericISOHash = Get-FileHash -LiteralPath $genericISOPath -Algorithm SHA256
    $module.Diff.before.generic_iso = @{
        path = $genericISOPath
        sha256_hash = $previousGenericISOHash.Hash
    }
}

if ($module.Diff.before.Count -eq 0) {
    $module.Diff.before = $null
}

$module.Result.changed = $false

if ($force) {
    Update-MDTDeploymentShare -Path "$($mdtDrive.Name):" -Force | Out-Null
}
else {
    Update-MDTDeploymentShare -Path "$($mdtDrive.Name):" -Compress:$compress | Out-Null
}

$liteTouchWIMHash = Get-FileHash -LiteralPath $liteTouchWIMPath -Algorithm SHA256

if ($null -eq $previousLiteTouchWIMHash) {
    $module.Result.changed = $true
}
elseif ($previousLiteTouchWIMHash.Hash -ne $liteTouchWIMHash.Hash) {
    $module.Result.changed = $true
}

$litetouchWIM = @{
    path = $liteTouchWIMPath
    sha256_hash = $liteTouchWIMHash.Hash
}

$module.Result.litetouch_wim = $litetouchWIM
$module.Diff.after.litetouch_wim = $litetouchWIM

if ($useLiteTouchISO) {

    $liteTouchISOHash = Get-FileHash -LiteralPath $liteTouchISOPath -Algorithm SHA256

    if ($null -eq $previousLiteTouchISOHash) {
        $module.Result.changed = $true
    }
    elseif ($previousLiteTouchISOHash.Hash -ne $liteTouchISOHash.Hash) {
        $module.Result.changed = $true
    }

    $litetouchISO = @{
        path = $liteTouchISOPath
        sha256_hash = $liteTouchISOHash.Hash
    }

    $module.Result.litetouch_iso = $litetouchISO
    $module.Diff.after.litetouch_iso = $litetouchISO
}

if ($useGenericWIM) {

    $genericWIMHash = Get-FileHash -LiteralPath $genericWIMPath -Algorithm SHA256

    if ($null -eq $previousGenericWIMHash) {
        $module.Result.changed = $true
    }
    elseif ($previousGenericWIMHash.Hash -ne $genericWIMHash.Hash) {
        $module.Result.changed = $true
    }

    $genericWIM = @{
        path = $genericWIMPath
        sha256_hash = $genericWIMHash.Hash
    }

    $module.Result.generic_wim = $genericWIM
    $module.Diff.after.generic_wim = $genericWIM
}

if ($useGenericISO) {

    $genericISOHash = Get-FileHash -LiteralPath $genericISOPath -Algorithm SHA256

    if ($null -eq $previousGenericISOHash) {
        $module.Result.changed = $true
    }
    elseif ($previousGenericISOHash.Hash -ne $genericISOHash.Hash) {
        $module.Result.changed = $true
    }

    $genericISO = @{
        path = $genericISOPath
        sha256_hash = $genericISOHash.Hash
    }

    $module.Result.generic_iso = $genericISO
    $module.Diff.after.generic_iso = $genericISO
}

$mdtDrive | Remove-PSDrive | Out-Null

$module.ExitJson()
