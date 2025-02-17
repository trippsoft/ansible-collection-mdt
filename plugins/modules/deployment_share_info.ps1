#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.Common
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.DeploymentShare

function Confirm-DeploymentShareInfoParamsAreValid {
    <#
    .SYNOPSIS
    Confirms that the parameters are valid.

    .DESCRIPTION
    This function confirms that the parameters are valid.

    .PARAMETER Module
    The Ansible module.

    .EXAMPLE
    Confirm-DeploymentShareInfoParamsAreValid -Module $module
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [Ansible.Basic.AnsibleModule]$Module
    )

    process {
        $Module.Params.mdt_share_path = $Module.Params.mdt_share_path.TrimEnd('\')
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
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$module | Confirm-DeploymentShareInfoParamsAreValid | Out-Null
Import-MDTModule -Module $module | Out-Null

$mdtDrive = Get-MDTDeploymentShareDrive -Module $module

$deploymentShare = $mdtDrive |
    Get-MDTDeploymentShareRootFolder -Module $module |
    Format-MDTDeploymentShare -IncludeDescription -IncludeUNCPath -IncludeMonitor -IncludeDatabase

$module.Result.exists = $null -ne $deploymentShare

if ($null -ne $deploymentShare) {
    $module.Result.deployment_share = $deploymentShare
}

if ($null -ne $mdtDrive) {
    $mdtDrive | Remove-PSDrive | Out-Null
}

$module.ExitJson()
