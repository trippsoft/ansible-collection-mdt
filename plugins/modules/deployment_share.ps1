#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.Common
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.DeploymentShare

function Get-ExistingDeploymentShare {
    <#
    .SYNOPSIS
    Gets an existing MDT deployment share.

    .DESCRIPTION
    This function gets an existing MDT deployment share.

    .PARAMETER Module
    The Ansible module.

    .EXAMPLE
    Get-ExistingDeploymentShare -Module $module

    .OUTPUTS
    System.Collections.Hashtable
    #>

    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module
    )

    $mdtDrive = Get-MDTDeploymentShareDrive -Module $Module
    $rootFolder = $mdtDrive | Get-MDTDeploymentShareRootFolder -Module $Module

    if ($null -eq $mdtDrive -or $null -eq $rootFolder) {
        return $null
    }

    return @{
        name = $mdtDrive.Name
        path = $mdtDrive.Path
        description = $rootFolder.Item("Description")
        unc_path = $rootFolder.Item("UNCPath")
    }
}

function Get-ExpectedDeploymentShare {
    <#
    .SYNOPSIS
    Gets an expected MDT deployment share.

    .DESCRIPTION
    This function gets an expected MDT deployment share.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER Existing
    The existing deployment share configuration.


    .EXAMPLE
    Get-ExpectedDeploymentShare -Module $module -Existing $existing

    .OUTPUTS
    System.Collections.Hashtable
    #>

    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Collections.Hashtable]$Existing
    )

    $path = $Module.Params.mdt_share_path
    $description = $Module.Params.description
    $uncPath = $Module.Params.unc_path

    if ($null -eq $Existing) {

        for ($i = 1; $i -lt 1000; $i++) {

            $name = "DS$($i.ToString().PadLeft(3, '0'))"
            $matchingDrive = Get-MDTPersistentDrive | Where-Object { $_.Name -ieq $name }

            if ($null -eq $matchingDrive) {
                break
            }
        }

        return @{
            name = $name
            path = $path
            description = $description
            unc_path = $uncPath
        }
    }
    else {
        return @{
            name = $Existing.name
            path = $path
            description = $description
            unc_path = $uncPath
        }
    }
}

function Compare-ExpectedDeploymentShareToExisting {
    <#
    .SYNOPSIS
    Compares an expected MDT deployment share to an existing deployment share.

    .DESCRIPTION
    This function compares an expected MDT deployment share to an existing deployment share.

    .PARAMETER Expected
    The expected deployment share configuration.

    .PARAMETER Existing
    The existing deployment share configuration.

    .EXAMPLE
    Compare-ExpectedDeploymentShareToExisting -Expected $expected -Existing $existing

    .OUTPUTS
    System.Collections.Hashtable
    #>

    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$Expected,
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$Existing
    )

    $propertyChanges = @{}

    if ($Expected.description -ne $Existing.description) {
        $propertyChanges.Description = $Expected.description
    }

    if ($Expected.unc_path -ne $Existing.unc_path) {
        $propertyChanges.UNCPath = $Expected.unc_path
    }

    return $propertyChanges
}

function Set-DeploymentShare {
    <#
    .SYNOPSIS
    Sets a deployment share.

    .DESCRIPTION
    This function sets a deployment share.

    .PARAMETER Name
    The name of the deployment share.

    .PARAMETER Description
    The description of the deployment share.

    .PARAMETER UNCPath
    The UNC share path of the deployment share.

    .EXAMPLE
    Set-DeploymentShare -Name $name -Description $description -UNCPath $uncPath
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $false)]
        [string]$Description,
        [Parameter(Mandatory = $false)]
        [string]$UNCPath
    )

    $Module.Result.changed = $true

    if ($Module.CheckMode) {
        return
    }

    $rootFolder = Get-Item -LiteralPath "$($Name):\"

    if (-not [string]::IsNullOrEmpty($Description)) {
        $rootFolder.Item("Description") = $Description
    }

    if (-not [string]::IsNullOrEmpty($UNCPath)) {
        $rootFolder.Item("UNCPath") = $UNCPath
    }

    $rootFolder = Get-Item -LiteralPath "$($Name):\"

    $Module.Result.description = $rootFolder.Item("Description")
    $Module.Result.unc_path = $rootFolder.Item("UNCPath")

    $Module.Diff.after.description = $rootFolder.Item("Description")
    $Module.Diff.after.unc_path = $rootFolder.Item("UNCPath")
}

function Add-DeploymentShare {
    <#
    .SYNOPSIS
    Adds a deployment share.

    .DESCRIPTION
    This function adds a deployment share.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER Expected
    The expected deployment share configuration.

    .EXAMPLE
    Add-DeploymentShare -Module $module -Expected $expected
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$Expected
    )

    $Module.Result.changed = $true

    if ($Module.CheckMode) {
        return
    }

    $name = $Expected.name
    $path = $Expected.path
    $description = $Expected.description
    $uncPath = $Expected.unc_path

    if (-not (Test-Path -LiteralPath $path)) {
        New-Item -Path $path -ItemType Directory -Force | Out-Null
    }

    New-PSDrive -Name $name -PSProvider MDTProvider -Root $path -Scope Global -Description $description -NetworkPath $uncPath |
        Add-MDTPersistentDrive |
        Out-Null

    $rootFolder = Get-Item -LiteralPath "$($name):\"

    $Module.Result.description = $rootFolder.Item("Description")
    $Module.Result.unc_path = $rootFolder.Item("UNCPath")

    $Module.Diff.after.description = $rootFolder.Item("Description")
    $Module.Diff.after.unc_path = $rootFolder.Item("UNCPath")
}

function Remove-DeploymentShare {
    <#
    .SYNOPSIS
    Removes a deployment share.

    .DESCRIPTION
    This function removes a deployment share.

    .PARAMETER Name
    The name of the deployment share.

    .EXAMPLE
    Remove-DeploymentShare -Name $name
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $Module.Result.changed = $true

    if ($Module.CheckMode) {
        return
    }

    Remove-MDTPersistentDrive -Name $Name | Out-Null
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
        description = @{
            type = 'str'
            required = $false
        }
        unc_path = @{
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
    required_if = @(
        , @('state', 'present', @('description', 'unc_path'))
    )
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-MDTModule -Module $module | Out-Null

$state = $module.Params.state

$existing = Get-ExistingDeploymentShare -Module $module

$module.Diff.before = $existing
$module.Result.changed = $false

if ($state -eq 'present') {

    $expected = Get-ExpectedDeploymentShare -Module $module -Existing $existing

    $module.Diff.after = $expected

    $module.Result.name = $expected.name
    $module.Result.path = $expected.path
    $module.Result.description = $expected.description
    $module.Result.unc_path = $expected.unc_path

    if ($null -ne $existing) {

        $propertyChanges = Compare-ExpectedDeploymentShareToExisting -Expected $expected -Existing $existing

        if ($propertyChanges.Count -gt 0) {
            Set-DeploymentShare -Module $module -Name $expected.name @propertyChanges | Out-Null
        }
    }
    else {
        Add-DeploymentShare -Module $module -Expected $expected | Out-Null
    }
}
elseif ($state -eq 'absent') {

    $module.Diff.after = $null

    if ($null -ne $existing) {
        Remove-DeploymentShare -Name $existing.Name | Out-Null
    }
}

$module.ExitJson()
