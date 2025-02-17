#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.Common
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.Driver

function Confirm-ImportDriversParamsAreValid {
    <#
    .SYNOPSIS
    Confirms that the parameters are valid.

    .DESCRIPTION
    Confirms that the parameters are valid.

    .PARAMETER Module
    The Ansible module object.

    .EXAMPLE
    Confirm-ImportDriversParamsAreValid -Module $Module
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [Ansible.Basic.AnsibleModule]$Module
    )

    process {

        $Module.Params.path = $Module.Params.path | Format-MDTPath
        $Module.Params.path | Confirm-MDTPathIsValid -Module $Module -ParameterName "path" | Out-Null
    }
}

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
        source_paths = @{
            type = 'list'
            required = $true
            elements = 'path'
        }
        path = @{
            type = 'str'
            required = $true
        }
        import_duplicates = @{
            type = 'bool'
            required = $false
            default = $false
        }
    }
    supports_check_mode = $false
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$module | Confirm-ImportDriversParamsAreValid | Out-Null
Import-MDTModule -Module $module | Out-Null

$mdtDrive = Get-MDTPSDrive -Module $module -ReadWrite

$sourcePaths = $module.Params.source_paths
$path = $module.Params.path
$importDuplicates = $module.Params.import_duplicates

foreach ($sourcePath in $sourcePaths) {

    if (-not (Test-Path -LiteralPath $sourcePath)) {
        $module.FailJson("Source path '$sourcePath' does not exist.")
    }
}

$fullPath = "$($mdtDrive.Name):\$($path)"

if (-not (Test-Path -LiteralPath $fullPath -PathType Container)) {
    $module.FailJson("Directory '$path' does not exist.")
}

$module.Result.changed = $false

$importedDrivers = Import-MDTDriver -Path $fullPath -SourcePath $sourcePaths -ImportDuplicates:$importDuplicates

if ($null -ne $importedDrivers) {
    $module.Result.changed = $importedDrivers.Length -gt 0
    $module.Result.drivers = $importedDrivers | Format-MDTDriver -Module $module -MDTDriveName $mdtDrive.Name -ExcludePaths
}

$mdtDrive | Remove-PSDrive | Out-Null

$module.ExitJson()
