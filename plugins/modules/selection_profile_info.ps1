#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.Common
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.SelectionProfile

function Confirm-SelectionProfileInfoParamsAreValid {
    <#
    .SYNOPSIS
    Confirms that the parameters are valid.

    .DESCRIPTION
    This function confirms that the parameters are valid.

    .PARAMETER Module
    The Ansible module.

    .EXAMPLE
    Confirm-SelectionProfileInfoParamsAreValid -Module $module
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [Ansible.Basic.AnsibleModule]$Module
    )

    process {
        $Module.Params.name | Confirm-NameIsValid -Module $Module -ParameterName "name" | Out-Null
        $Module.Params.guid = $Module.Params.guid | Format-MDTGuid -Module $Module
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
        guid = @{
            type = 'str'
            required = $false
        }
        name = @{
            type = 'str'
            required = $false
        }
    }
    mutually_exclusive = @(
        , @('name', 'guid')
    )
    required_one_of = @(
        , @('name', 'guid')
    )
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$module | Confirm-SelectionProfileInfoParamsAreValid | Out-Null
Import-MDTModule -Module $module | Out-Null

$mdtDrive = Get-MDTPSDrive -Module $module

$selectionProfile = Get-MDTSelectionProfile -Module $module -MDTDriveName $mdtDrive.Name -Guid $module.Params.guid -Name $module.Params.name

if ($null -eq $selectionProfile) {
    $module.Result.exists = $false
}
else {
    $module.Result.exists = $true
    $module.Result.selection_profile = $selectionProfile | Format-MDTSelectionProfile
}

$mdtDrive | Remove-PSDrive | Out-Null

$module.ExitJson()
