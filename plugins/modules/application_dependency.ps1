#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.Common
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.Application

function Confirm-ApplicationDependencyParamsAreValid {
    <#
    .SYNOPSIS
    Confirms that the parameters are valid.

    .DESCRIPTION
    This function confirms that the parameters are valid.

    .PARAMETER Module
    The Ansible module.

    .EXAMPLE
    Confirm-ApplicationDependencyParamsAreValid -Module $module
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

        $add = $Module.Params.add

        if ($null -ne $add) {

            if ($add.Count -eq 0) {
                $module.FailJson("The 'add' parameter must contain at least one element.")
            }

            foreach ($dependency in $add) {

                $dependency.name | Confirm-NameIsValid -Module $Module -ParameterName "add.name" | Out-Null
                $dependency.guid = $dependency.guid | Format-MDTGuid -Module $Module
            }
        }

        $remove = $Module.Params.remove

        if ($null -ne $remove) {

            if ($remove.Count -eq 0) {
                $module.FailJson("The 'remove' parameter must contain at least one element.")
            }

            foreach ($dependency in $remove) {

                $dependency.name | Confirm-NameIsValid -Module $Module -ParameterName "remove.name" | Out-Null
                $dependency.guid = $dependency.guid | Format-MDTGuid -Module $Module
            }
        }

        $set = $Module.Params.set

        if ($null -ne $set) {

            foreach ($dependency in $set) {

                $dependency.name | Confirm-NameIsValid -Module $Module -ParameterName "set.name" | Out-Null
                $dependency.guid = $dependency.guid | Format-MDTGuid -Module $Module
            }
        }
    }
}

function Get-ExpectedDependencyValue {
    <#
    .SYNOPSIS
    Gets the expected dependency value.

    .DESCRIPTION
    This function gets the expected dependency value.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The MDT drive name.

    .PARAMETER Existing
    The existing dependencies.

    .EXAMPLE
    Get-ExpectedDependencyValue -Module $module -MDTDriveName $mdtDrive.Name -Existing $existing

    .OUTPUTS
    string[]
    #>

    [OutputType([System.Collections.Hashtable[]])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [string]$MDTDriveName,
        [Parameter(Mandatory = $false)]
        [System.Collections.Hashtable[]]$Existing
    )

    if ($null -eq $Existing) {
        $Existing = [System.Collections.Hashtable[]]@()
    }

    $expectedDependencies = New-Object -TypeName System.Collections.Generic.List[System.Collections.Hashtable]

    if ($null -ne $Module.Params.set) {

        foreach ($dependency in $Module.Params.set) {

            $applications = [Array](Get-MDTApplication -Module $Module -MDTDriveName $MDTDriveName -Guid $dependency.guid -Name $dependency.name)

            if ($null -eq $applications) {

                if ($null -ne $dependency.guid) {
                    $Module.FailJson("Dependency with GUID '$($dependency.guid)' does not exist.")
                }

                $Module.FailJson("Dependency '$($dependency.name)' does not exist.")
            }

            $expectedDependency = @{
                guid = $applications[0].guid
                name = $applications[0].Name
            }

            $expectedDependencies.Add($expectedDependency) | Out-Null
        }

        return $expectedDependencies.ToArray()
    }

    $addDependencies = New-Object -TypeName System.Collections.Generic.List[System.Collections.Hashtable]

    if ($null -ne $Module.Params.add) {

        foreach ($dependency in $Module.Params.add) {

            $applications = [Array](Get-MDTApplication -Module $Module -MDTDriveName $MDTDriveName -Guid $dependency.guid -Name $dependency.name)

            if ($null -eq $applications) {

                if ($null -ne $dependency.guid) {
                    $Module.FailJson("Dependency with GUID '$($dependency.guid)' does not exist.")
                }

                $Module.FailJson("Dependency '$($dependency.name)' does not exist.")
            }

            $addDependency = @{
                guid = $applications[0].guid
                name = $applications[0].Name
            }

            $addDependencies.Add($addDependency) | Out-Null
        }
    }

    $removeDependencies = New-Object -TypeName System.Collections.Generic.List[System.Collections.Hashtable]

    if ($null -ne $Module.Params.remove) {

        foreach ($dependency in $Module.Params.remove) {

            $applications = [Array](Get-MDTApplication -Module $Module -MDTDriveName $MDTDriveName -Guid $dependency.guid -Name $dependency.name)

            if ($null -eq $applications) {

                if ($null -ne $dependency.guid) {

                    $Module.Warn("Dependency with GUID '$($dependency.guid)' does not exist.")

                    $removeDependency = @{
                        guid = $dependency.guid
                    }

                    $removeDependencies.Add($removeDependencies) | Out-Null
                    continue
                }

                $Module.Warn("Dependency '$($dependency.name)' does not exist.")
                continue
            }

            $removeDependency = @{
                guid = $applications[0].guid
                name = $applications[0].Name
            }

            $removeDependencies.Add($removeDependency) | Out-Null
        }
    }

    $addGuids = [Array]($addDependencies | ForEach-Object { $_.guid })
    $removeGuids = [Array]($removeDependencies | ForEach-Object { $_.guid })

    $intersection = $addGuids | Where-Object { $removeGuids -icontains $_ }

    if ($null -ne $intersection) {
        $Module.FailJson("The 'add' and 'remove' parameters must not contain any of the same applications.")
    }

    foreach ($existingDependency in $Existing) {

        if ($removeGuids -icontains $existingDependency.guid) {
            continue
        }

        $expectedDependencies.Add($existingDependency) | Out-Null
    }

    foreach ($addGuid in $addGuids) {

        $matchingDependency = $expectedDependencies | Where-Object { $_.guid -ieq $addGuid }

        if ($null -ne $matchingDependency) {
            continue
        }

        $addDependency = $addDependencies | Where-Object { $_.guid -ieq $addGuid }
        $expectedDependencies.Add($addDependency) | Out-Null
    }

    return $expectedDependencies.ToArray()
}

function Set-DependencyValue {

    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [string]$MDTDriveName,
        [Parameter(Mandatory = $false)]
        [System.Collections.Hashtable[]]$Existing,
        [Parameter(Mandatory = $false)]
        [System.Collections.Hashtable[]]$Expected
    )

    if ($null -eq $Existing) {
        $Existing = [System.Collections.Hashtable[]]@()
    }

    if ($null -eq $Expected) {
        $Expected = [System.Collections.Hashtable[]]@()
    }

    $dependenciesToRemove = [Array]($Existing | Where-Object { ($Expected | ForEach-Object { $_.guid }) -inotcontains $_.guid })
    $dependenciesToAdd = [Array]($Expected | Where-Object { ($Existing | ForEach-Object { $_.guid }) -inotcontains $_.guid })

    if (($null -eq $dependenciesToRemove -or $dependenciesToRemove.Length -eq 0) -and ($null -eq $dependenciesToAdd -or $dependenciesToAdd.Length -eq 0)) {
        return
    }

    $Module.Result.changed = $true

    if ($Module.CheckMode) {
        return
    }

    $applications = [Array](Get-MDTApplication -Module $Module -MDTDriveName $MDTDriveName -Guid $Module.Params.guid -Name $Module.Params.name)
    $application = $applications[0]

    if ($Expected.Length -eq 0) {
        $application.Item("Dependency") = [System.Object[]]@()
    }
    else {
        $application.Item("Dependency") = [System.Object[]]($Expected | ForEach-Object { $_.guid })
    }

    $applications = Get-MDTApplication -Module $Module -MDTDriveName $MDTDriveName -Guid $Module.Params.guid -Name $Module.Params.name
    $application = $applications | Format-MDTApplication -Module $Module -MDTDriveName $MDTDriveName
    $dependencies = $application.dependencies

    $Module.Diff.after = @{ dependencies = $dependencies }
    $Module.Result.application_dependencies = $dependencies
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
        add = @{
            type = 'list'
            elements = 'dict'
            required = $false
            options = @{
                name = @{
                    type = 'str'
                    required = $false
                }
                guid = @{
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
        }
        remove = @{
            type = 'list'
            elements = 'dict'
            required = $false
            options = @{
                name = @{
                    type = 'str'
                    required = $false
                }
                guid = @{
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
        }
        set = @{
            type = 'list'
            elements = 'dict'
            required = $false
            options = @{
                name = @{
                    type = 'str'
                    required = $false
                }
                guid = @{
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
        }
    }
    mutually_exclusive = @(
        @('name', 'guid'),
        @('add', 'set'),
        @('remove', 'set')
    )
    required_one_of = @(
        @('name', 'guid'),
        @('add', 'remove', 'set')
    )
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$module | Confirm-ApplicationDependencyParamsAreValid | Out-Null
Import-MDTModule -Module $module | Out-Null

$mdtDrive = Get-MDTPSDrive -Module $module -ReadWrite

$module.Result.changed = $false

$applications = Get-MDTApplication -Module $module -MDTDriveName $mdtDrive.Name -Guid $module.Params.guid -Name $module.Params.name

if ($null -eq $applications) {

    if ($null -ne $module.Params.guid) {
        $module.FailJson("Application with GUID '$($module.Params.guid)' does not exist.")
    }

    $module.FailJson("Application '$($module.Params.name)' does not exist.")
}

$application = $applications | Format-MDTApplication -Module $module -MDTDriveName $mdtDrive.Name

$existing = $application.dependencies

$module.Diff.before = @{ dependencies = $existing }

$expected = [System.Collections.Hashtable[]](Get-ExpectedDependencyValue -Module $module -MDTDriveName $mdtDrive.Name -Existing $existing)

if ($null -eq $expected) {
    $expected = [System.Collections.Hashtable[]]@()
}

$module.Result.changed = $false

$module.Diff.after = @{ dependencies = $expected }
$module.Result.application_dependencies = $expected

Set-DependencyValue -Module $module -MDTDriveName $mdtDrive.Name -Existing $existing -Expected $expected | Out-Null

$mdtDrive | Remove-PSDrive | Out-Null

$module.ExitJson()
