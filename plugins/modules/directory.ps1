#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.Common

function Confirm-DirectoryParamsAreValid {
    <#
    .SYNOPSIS
    Confirms that the parameters are valid.

    .DESCRIPTION
    This function confirms that the parameters are valid.

    .PARAMETER Module
    The Ansible module.

    .EXAMPLE
    Confirm-DirectoryParamsAreValid -Module $module
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module
    )

    $Module.Params.path = $Module.Params.path | Format-MDTPath

    if ([string]::IsNullOrEmpty($Module.Params.path)) {
        $Module.FailJson("The 'path' parameter cannot be empty.")
    }

    $Module.Params.path |
        Confirm-MDTPathIsValid -Module $Module -ParameterName "path" |
        Out-Null
}

function Add-MDTDirectory {
    <#
    .SYNOPSIS
    Adds a directory to the MDT drive.

    .DESCRIPTION
    This function adds a directory to the MDT drive.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The name of the MDT drive.

    .EXAMPLE
    Add-MDTDirectory -Module $module -MDTDriveName 'DS001'
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [string]$MDTDriveName
    )

    $path = $Module.Params.path
    $pathSegments = $path.Split('\')

    $fullPath = "$($MDTDriveName):"

    foreach ($segment in $pathSegments) {

        $fullPath = "$($fullPath)\$($segment)"

        if (Test-Path -LiteralPath $fullPath -PathType Container) {
            continue
        }

        $Module.Result.changed = $true

        if ($Module.CheckMode) {
            continue
        }

        New-Item -Path $fullPath -ItemType Directory | Out-Null

        if (-not (Test-Path -LiteralPath $fullPath -PathType Container)) {
            $Module.FailJson("Failed to create directory '$($fullPath)'.")
        }
    }
}

function Remove-MDTDirectory {
    <#
    .SYNOPSIS
    Removes a directory from the MDT drive.

    .DESCRIPTION
    This function removes a directory from the MDT drive.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The name of the MDT drive.

    .EXAMPLE
    Remove-MDTDirectory -Module $module -MDTDriveName 'DS001'
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [string]$MDTDriveName
    )

    $path = $Module.Params.path
    $fullPath = "$($MDTDriveName):\$($path)"

    if (-not (Test-Path -LiteralPath $fullPath -PathType Container)) {
        return
    }

    $Module.Result.changed = $true

    if ($Module.CheckMode) {
        return
    }

    Remove-Item -LiteralPath $fullPath -Recurse -Force | Out-Null

    if (Test-Path -LiteralPath $fullPath -PathType Container) {
        $Module.FailJson("Failed to remove directory '$($fullPath)'.")
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
        path = @{
            type = 'str'
            required = $true
        }
        state = @{
            type = 'str'
            required = $false
            default = 'present'
            choices = @(
                'present',
                'absent'
            )
        }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Confirm-DirectoryParamsAreValid -Module $module | Out-Null
Import-MDTModule -Module $module | Out-Null

$mdtDrive = Get-MDTPSDrive -Module $module -ReadWrite

$path = $module.Params.path
$state = $module.Params.state

$module.Result.changed = $false

if ($state -eq 'present') {
    Add-MDTDirectory -Module $module -MDTDriveName $mdtDrive.Name
}
elseif ($state -eq 'absent') {
    Remove-MDTDirectory -Module $module -MDTDriveName $mdtDrive.Name
}
else {
    $module.FailJson("Invalid state '$state'.")
}

$mdtDrive | Remove-PSDrive | Out-Null

$module.ExitJson()
