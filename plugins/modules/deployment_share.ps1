#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.SharedFunctions

function Get-MatchingPersistentDriveByPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $persistentDrives = [Array](Get-MDTPersistentDrive)
    $matchingDrive = $null

    if ($null -ne $persistentDrives)
    {
        foreach ($persistentDrive in $persistentDrives)
        {
            if ($persistentDrive.Path -ieq $Path)
            {
                $matchingDrive = $persistentDrive
                break
            }
        }
    }

    return $matchingDrive
}

function Get-MatchingPersistentDriveByName {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name
    )
    
    $persistentDrives = [Array](Get-MDTPersistentDrive)
    $matchingDrive = $null

    if ($null -ne $persistentDrives)
    {
        foreach ($persistentDrive in $persistentDrives)
        {
            if ($persistentDrive.Name -eq $Name)
            {
                $matchingDrive = $persistentDrive
                break
            }
        }
    }

    return $matchingDrive
}

function Add-DeploymentShare {
    param (
        [Ansible.Basic.AnsibleModule]$Module
    )

    $path = $Module.Params.path
    $description = $Module.Params.description
    $shareName = $Module.Params.share_name
    
    $Module.Result['changed'] = $true
    $Module.Result['path'] = $path

    $directoryCreated = $false

    if (-not (Test-Path -Path $path))
    {
        $directoryCreated = $true

        if (-not $Module.CheckMode)
        {
            New-Item -Path $path -ItemType Directory -Force | Out-Null
        }
    }
    
    $Module.Result['directory_created'] = $directoryCreated

    for ($i = 1; $i -lt 1000; $i++)
    {
        $name = "DS$($i.ToString().PadLeft(3, '0'))"
        $matchingDrive = Get-MatchingPersistentDriveByName -Name $name

        if ($null -eq $matchingDrive)
        {
            break
        }
    }

    $Module.Result['name'] = $name

    if (-not $Module.CheckMode)
    {
        $networkPath = "\\$($env:COMPUTERNAME)\$($shareName)"
        New-PSDrive -Name $name -PSProvider MDTProvider -Root $path -Scope Global -Description $description -NetworkPath $networkPath | Add-MDTPersistentDrive | Out-Null
    }
}

function Remove-DeploymentShare {
    param (
        [Ansible.Basic.AnsibleModule]$Module,
        [System.Object]$ExistingDrive
    )
   
    $Module.Result['changed'] = $true
    $Module.Result['previous'] = @{
        name = $matchingDrive.Name
        path = $matchingDrive.Path
        description = $matchingDrive.Description
    }

    if (-not $Module.CheckMode)
    {
        Remove-MDTPersistentDrive -Name $matchingDrive.Name | Out-Null
    }
}

$spec = @{
    options = @{
        installation_path = @{
            type = 'path'
            required = $false
            default = 'C:\Program Files\Microsoft Deployment Toolkit'
        }
        name = @{
            type = 'str'
            required = $false
        }
        path = @{
            type = 'path'
            required = $false
        }
        description = @{
            type = 'str'
            required = $false
        }
        share_name = @{
            type = 'str'
            required = $false
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
    mutually_exclusive = @(
        , @('name', 'path')
    )
    required_if = @(
        @('state', 'present', @('path', 'description', 'share_name'), $false),
        @('state', 'absent', @('path', 'name'), $true)
    )
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-MDTModule -InstallationPath $module.Params.installation_path

$name = $module.Params.name
$path = $module.Params.path
$state = $module.Params.state

if ($state -eq 'present')
{
    $matchingDrive = Get-MatchingPersistentDriveByPath -Path $path

    if ($null -eq $matchingDrive)
    {
        Add-DeploymentShare -Module $module
    }
    else
    {
        $module.Result['changed'] = $false
        $module.Result['name'] = $matchingDrive.Name
        $module.Result['path'] = $matchingDrive.Path
        $module.Result['directory_created'] = $false
    }
}
elseif ($state -eq 'absent')
{
    if ($null -ne $name)
    {
        $matchingDrive = Get-MatchingPersistentDriveByName -Name $name
    }
    elseif ($null -ne $path)
    {
        $matchingDrive = Get-MatchingPersistentDriveByPath -Path $path
    }
    
    if ($null -ne $matchingDrive)
    {
        Remove-DeploymentShare -Module $module -ExistingDrive $matchingDrive
    }
    else
    {
        $module.Result['changed'] = $false
    }
}

$module.ExitJson()
