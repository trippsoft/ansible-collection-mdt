#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.Common
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.OperatingSystem
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.TaskSequence

function Confirm-TaskSequenceInfoParamsAreValid {
    <#
    .SYNOPSIS
    Confirms that the parameters are valid.

    .DESCRIPTION
    This function confirms that the parameters are valid.

    .PARAMETER Module
    The Ansible module.

    .EXAMPLE
    Confirm-TaskSequenceInfoParamsAreValid -Module $module
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
        $Module.Params.id | Confirm-TaskSequenceIdIsValid -Module $Module -ParameterName "id" | Out-Null
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
        id = @{
            type = 'str'
            required = $false
        }
        name = @{
            type = 'str'
            required = $false
        }
        include_secrets = @{
            type = 'bool'
            required = $false
            default = $false
        }
    }
    mutually_exclusive = @(
        , @('name', 'id')
    )
    required_one_of = @(
        , @('name', 'id')
    )
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$module | Confirm-TaskSequenceInfoParamsAreValid | Out-Null
Import-MDTModule -Module $module | Out-Null

$mdtDrive = Get-MDTPSDrive -Module $module

$taskSequence = Get-MDTTaskSequence -Module $module -MDTDriveName $mdtDrive.Name -Id $module.Params.id -Name $module.Params.name |
    Format-MDTTaskSequence -Module $module -MDTDriveName $mdtDrive.Name -IncludeSecrets:$module.Params.include_secrets

if ($null -eq $taskSequence) {
    $module.Result.exists = $false
}
else {
    $module.Result.exists = $true
    $module.Result.task_sequence = $taskSequence
}

$mdtDrive | Remove-PSDrive | Out-Null

$module.ExitJson()
