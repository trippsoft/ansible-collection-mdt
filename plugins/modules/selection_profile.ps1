#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.Common
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.SelectionProfile

function Confirm-SelectionProfileParamsAreValid {
    <#
    .SYNOPSIS
    Confirms that the parameters are valid.

    .DESCRIPTION
    This function confirms that the parameters are valid.

    .PARAMETER Module
    The Ansible module.

    .EXAMPLE
    Confirm-SelectionProfileParamsAreValid -Module $module
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [string]$MDTDriveName
    )

    process {

        $state = $Module.Params.state

        $Module.Params.mdt_share_path = $Module.Params.mdt_share_path.TrimEnd("\")
        $Module.Params.name | Confirm-NameIsValid -Module $Module -ParameterName "name" | Out-Null
        $Module.Params.guid = $Module.Params.guid | Format-MDTGuid -Module $Module

        if ($state -eq "absent") {
            $Module | Confirm-SelectionProfileParamsAreValidForAbsent | Out-Null
        }
        elseif ($state -eq "present") {
            $Module | Confirm-SelectionProfileParamsAreValidForPresent -MDTDriveName $MDTDriveName | Out-Null
        }
    }
}

function Confirm-SelectionProfileParamsAreValidForAbsent {
    <#
    .SYNOPSIS
    Confirms that the parameters are valid for the module when the state is 'absent'.

    .DESCRIPTION
    This function confirms that the parameters are valid for the module when the state is 'absent'.

    .PARAMETER Module
    The module object.

    .EXAMPLE
    Confirm-SelectionProfileParamsAreValidForAbsent -Module $Module
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [Ansible.Basic.AnsibleModule]$Module
    )

    process {

        if ($null -ne $Module.Params.guid -and $null -ne $Module.Params.name) {
            $Module.FailJson("The 'guid' and 'name' parameters are mutually exclusive when state is 'absent'.")
        }

        $invalidParams = New-Object -TypeName System.Collections.ArrayList

        if ($null -ne $Module.Params.definition_paths) {
            $invalidParams.Add("definition_paths") | Out-Null
        }

        if ($null -ne $Module.Params.comments) {
            $invalidParams.Add("comments") | Out-Null
        }

        if ($null -ne $Module.Params.enabled) {
            $invalidParams.Add("enabled") | Out-Null
        }

        if ($null -ne $Module.Params.hidden) {
            $invalidParams.Add("hidden") | Out-Null
        }

        if ($invalidParams.Count -gt 0) {
            $Module.FailJson("The following parameters are invalid when state is absent: $($invalidParams -join ', ')")
        }
    }
}

function Confirm-SelectionProfileParamsAreValidForPresent {
    <#
    .SYNOPSIS
    Confirms that the parameters are valid for the module when the state is 'present'.

    .DESCRIPTION
    This function confirms that the parameters are valid for the module when the state is 'present'.

    .PARAMETER Module
    The module object.

    .EXAMPLE
    Confirm-SelectionProfileParamsAreValidForPresent -Module $Module
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [string]$MDTDriveName
    )

    process {

        $definitionPaths = $Module.Params.definition_paths

        if ($null -ne $definitionPaths) {

            $addPaths = $definitionPaths.add
            $removePaths = $definitionPaths.remove
            $setPaths = $definitionPaths.set

            if ($null -ne $addPaths) {

                if ($addPaths.Count -eq 0) {
                    $Module.FailJson("The 'definition_paths.add' parameter must contain at least one path, if provided.")
                }

                for ($i = 0; $i -lt $addPaths.Count; $i++) {

                    if ([string]::IsNullOrEmpty($addPaths[$i])) {
                        continue
                    }

                    $addPaths[$i] = $addPaths[$i] | Format-MDTPath

                    $addPaths[$i] |
                        Confirm-MDTPathIsValid -Module $Module -ParameterName "paths.add[$($i)]" |
                        Out-Null

                    if (-not (Test-Path -LiteralPath "$($MDTDriveName):\$($addPaths[$i])" -PathType Container)) {
                        $Module.FailJson("The directory 'Operating Systems\$($addPaths[$i])' does not exist in the MDT share.")
                    }
                }
            }

            if ($null -ne $removePaths) {

                if ($removePaths.Count -eq 0) {
                    $Module.FailJson("The 'definition_paths.remove' parameter must contain at least one path, if provided.")
                }

                for ($i = 0; $i -lt $removePaths.Count; $i++) {

                    if ([string]::IsNullOrEmpty($removePaths[$i])) {
                        continue
                    }

                    $removePaths[$i] = $removePaths[$i] | Format-MDTPath

                    $removePaths[$i] |
                        Confirm-MDTPathIsValid -Module $Module -ParameterName "paths.remove[$($i)]" |
                        Out-Null

                    if (-not (Test-Path -LiteralPath "$($MDTDriveName):\$($removePaths[$i])" -PathType Container)) {
                        $Module.FailJson("The directory 'Operating Systems\$($removePaths[$i])' does not exist in the MDT share.")
                    }
                }
            }

            if ($null -ne $addPaths -and $null -ne $removePaths) {

                $intersection = [Array]($addPaths | Where-Object { $removePaths -contains $_ })

                if ($intersection.Length -gt 0) {
                    $Module.FailJson("The 'definition_paths.add' and 'definition_paths.remove' parameters must not contain the same path(s).")
                }
            }

            if ($null -ne $setPaths) {

                for ($i = 0; $i -lt $setPaths.Count; $i++) {

                    if ([string]::IsNullOrEmpty($setPaths[$i])) {
                        continue
                    }

                    $setPaths[$i] = $setPaths[$i] | Format-MDTPath

                    $setPaths[$i] |
                        Confirm-MDTPathIsValid -Module $Module -ParameterName "paths.set[$($i)]" |
                        Out-Null

                    if (-not (Test-Path -LiteralPath "$($MDTDriveName):\$($setPaths[$i])" -PathType Container)) {
                        $Module.FailJson("The directory 'Operating Systems\$($setPaths[$i])' does not exist in the MDT share.")
                    }
                }
            }
        }
    }
}

function Get-ExpectedSelectionProfile {
    <#
    .SYNOPSIS
    Gets the expected selection profile.

    .DESCRIPTION
    This function gets the expected selection profile.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The MDT drive name.

    .PARAMETER Existing
    The existing selection profile.

    .EXAMPLE
    Get-ExpectedSelectionProfile -Module $Module -MDTDriveName "DS001"
    #>

    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [string]$MDTDriveName,
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Collections.Hashtable]$Existing
    )

    $expected = @{
        name = $Module.Params.name
        read_only = $false
    }

    if ($null -ne $Existing.guid) {
        $expected.guid = $Existing.guid
    }
    if ($null -ne $Module.Params.guid) {
        $expected.guid = $Module.Params.guid
    }

    if ($null -ne $Module.Params.comments) {
        $expected.comments = $Module.Params.comments
    }
    elseif ($null -ne $Existing) {
        $expected.comments = $Existing.comments
    }
    else {
        $expected.comments = ""
    }

    if ($null -ne $Module.Params.enabled) {
        $expected.enabled = $Module.Params.enabled
    }
    elseif ($null -ne $Existing) {
        $expected.enabled = $Existing.enabled
    }
    else {
        $expected.enabled = $true
    }

    if ($null -ne $Module.Params.hidden) {
        $expected.hidden = $Module.Params.hidden
    }
    elseif ($null -ne $Existing) {
        $expected.hidden = $Existing.hidden
    }
    else {
        $expected.hidden = $false
    }

    $setPaths = $Module.Params.definition_paths.set

    if ($null -ne $setPaths) {
        $expected.definition = $setPaths

        return $expected
    }

    if ($null -ne $Existing) {
        $existingDefinitionPaths = $Existing.definition_paths
    }
    else {
        $existingDefinitionPaths = @{}
    }

    $addPaths = $Module.Params.definition_paths.add

    if ($null -eq $addPaths) {
        $addPaths = @()
    }

    $removePaths = $Module.Params.definition_paths.remove

    if ($null -eq $removePaths) {
        $removePaths = @()
    }

    $definitionPaths = New-Object -TypeName System.Collections.ArrayList

    foreach ($existingPath in $existingDefinitionPaths) {

        if ($removePaths -icontains $existingPath) {
            continue
        }

        $definitionPaths.Add($existingPath) | Out-Null
    }

    foreach ($addPath in $addPaths) {

        if ($definitionPaths -icontains $addPath) {
            continue
        }

        $definitionPaths.Add($addPath) | Out-Null
    }

    $expected.definition = [string[]]$definitionPaths.ToArray()

    return $expected
}

function Compare-ExpectedSelectionProfileToExisting {
    <#
    .SYNOPSIS
    Compares the expected selection profile to the existing selection profile.

    .DESCRIPTION
    This function compares the expected selection profile to the existing selection profile.

    .PARAMETER Expected
    The expected selection profile.

    .PARAMETER Existing
    The existing selection profile.

    .EXAMPLE
    Compare-ExpectedSelectionProfileToExisting -Expected $expected -Existing $existing

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

    if ($Existing.name -ne $Expected.name) {
        $propertyChanges.Name = $Expected.name
    }

    $missingDefinitionPaths = [Array]($Expected.definition | Where-Object { $Existing.definition -notcontains $_ })
    $extraDefinitionPaths = [Array]($Existing.definition | Where-Object { $Expected.definition -notcontains $_ })

    if ($null -ne $missingDefinitionPaths -or $null -ne $extraDefinitionPaths) {
        $propertyChanges.Definition = Convert-PathsToMDTSelectionProfileDefinition -Paths $Expected.definition
    }

    if ($Existing.comments -ne $Expected.comments) {

        if ($Expected.comments -eq "") {
            $propertyChanges.CommentsEmpty = $true
        }
        else {
            $propertyChanges.Comments = $Expected.comments
        }
    }

    if ($Existing.enabled -ne $Expected.enabled) {
        $propertyChanges.Enabled = $Expected.enabled
    }

    if ($Existing.hidden -ne $Expected.hidden) {
        $propertyChanges.Hidden = $Expected.hidden
    }

    return $propertyChanges
}

function Set-MDTSelectionProfile {
    <#
    .SYNOPSIS
    Sets an MDT selection profile.

    .DESCRIPTION
    This function sets an MDT selection profile.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The MDT drive name.

    .PARAMETER Name
    The name of the selection profile.

    .PARAMETER Definition
    The definition of the selection profile.

    .PARAMETER CommentsEmpty
    Indicates whether the comments should be empty.

    .PARAMETER Comments
    The comments for the selection profile.

    .PARAMETER Enabled
    Indicates whether the selection profile is enabled.

    .PARAMETER Hidden
    Indicates whether the selection profile is hidden.

    .EXAMPLE
    Set-MDTSelectionProfile -Module $module `
        -MDTDriveName "DS001" `
        -Name "Profile1" `
        -Definition "<SelectionProfile><Include path='OS1' /><Include path='OS2' /></SelectionProfile>" `
        -Comments "This is a selection profile." `
        -Enabled $true `
        -Hidden $false
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [string]$MDTDriveName,
        [Parameter(Mandatory = $false)]
        [string]$Name,
        [Parameter(Mandatory = $false)]
        [string]$Definition,
        [Parameter(Mandatory = $false)]
        [bool]$CommentsEmpty = $false,
        [Parameter(Mandatory = $false)]
        [string]$Comments,
        [Parameter(Mandatory = $false)]
        [ValidateSet($null, $false, $true)]
        [object]$Enabled,
        [Parameter(Mandatory = $false)]
        [ValidateSet($null, $false, $true)]
        [object]$Hidden
    )

    if ($Module.CheckMode) {
        return
    }

    $selectionProfile = Get-MDTSelectionProfile -Module $Module -MDTDriveName $MDTDriveName -Guid $Module.Params.guid -Name $Module.Params.name

    if (-not [string]::IsNullOrEmpty($Definition)) {
        $selectionProfile.Item("Definition") = $Definition
    }

    if ($CommentsEmpty) {
        $selectionProfile.Item("Comments") = ""
    }
    elseif (-not [string]::IsNullOrEmpty($Comments)) {
        $selectionProfile.Item("Comments") = $Comments
    }

    if ($null -ne $Enabled) {
        if ($Enabled) {
            $selectionProfile.Item("enable") = "True"
        }
        else {
            $selectionProfile.Item("enable") = "False"
        }
    }

    if ($null -ne $Hidden) {
        if ($Hidden) {
            $selectionProfile.Item("hide") = "True"
        }
        else {
            $selectionProfile.Item("hide") = "False"
        }
    }

    if (-not [string]::IsNullOrEmpty($Name)) {
        $selectionProfile.RenameItem($Name)
    }

    $selectionProfile = Get-MDTSelectionProfile -Module $Module -MDTDriveName $MDTDriveName -Guid $Module.Params.guid -Name $Module.Params.name |
        Format-MDTSelectionProfile

    $Module.Diff.after = $selectionProfile
    $Module.Result.selection_profile = $selectionProfile
}

function New-MDTSelectionProfile {
    <#
    .SYNOPSIS
    Creates a new MDT selection profile.

    .DESCRIPTION
    This function creates a new MDT selection profile.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The MDT drive name.

    .PARAMETER Expected
    The expected selection profile.

    .EXAMPLE
    New-MDTSelectionProfile -Module $module -MDTDriveName "DS001" -Expected $expected
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [string]$MDTDriveName,
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$Expected
    )

    if ($Module.CheckMode) {
        return
    }

    $definition = Convert-PathsToMDTSelectionProfileDefinition -Paths $Expected.definition

    if ($Expected.enabled) {
        $enableValue = "True"
    }
    else {
        $enableValue = "False"
    }

    if ($Expected.hidden) {
        $hideValue = "True"
    }
    else {
        $hideValue = "False"
    }

    $newItemArgs = @{
        Path = "$($MDTDriveName):\Selection Profiles\$($Expected.name)"
        Definition = $definition
        Comments = $Expected.comments
        enable = $enableValue
        hide = $hideValue
        ReadOnly = "False"
    }

    if ($null -ne $Expected.guid) {
        $newItemArgs.guid = $Expected.guid
    }

    New-Item @newItemArgs | Out-Null

    $selectionProfile = Get-MDTSelectionProfile -Module $Module -MDTDriveName $MDTDriveName -Guid $Expected.guid -Name $Expected.name |
        Format-MDTSelectionProfile

    $Module.Diff.after = $selectionProfile
    $Module.Result.selection_profile = $selectionProfile
}

function Remove-MDTSelectionProfile {
    <#
    .SYNOPSIS
    Removes an MDT selection profile.

    .DESCRIPTION
    This function removes an MDT selection profile.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The MDT drive name.

    .PARAMETER Existing
    The existing selection profile.

    .EXAMPLE
    Remove-MDTSelectionProfile -Module $module -MDTDriveName "DS001" -Existing $existing
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [string]$MDTDriveName,
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$Existing
    )

    if ($Module.CheckMode) {
        return
    }

    Remove-Item -LiteralPath "$($MDTDriveName):\Selection Profiles\$($Existing.name)" -Force | Out-Null
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
        definition_paths = @{
            type = 'dict'
            required = $false
            options = @{
                add = @{
                    type = 'list'
                    elements = 'str'
                    required = $false
                }
                remove = @{
                    type = 'list'
                    elements = 'str'
                    required = $false
                }
                set = @{
                    type = 'list'
                    elements = 'str'
                    required = $false
                }
            }
            mutually_exclusive = @(
                @('add', 'set'),
                @('remove', 'set')
            )
            required_one_of = @(
                , @('add', 'remove', 'set')
            )
        }
        comments = @{
            type = 'str'
            required = $false
        }
        enabled = @{
            type = 'bool'
            required = $false
        }
        hidden = @{
            type = 'bool'
            required = $false
        }
        state = @{
            type = 'str'
            required = $false
            default = 'present'
            choices = @(
                'absent',
                'present'
            )
        }
    }
    required_if = @(
        , @('state', 'present', @('name', 'definition_paths'))
    )
    required_one_of = @(
        , @('name', 'guid')
    )
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-MDTModule -Module $module | Out-Null

$mdtDrive = Get-MDTPSDrive -Module $module -ReadWrite

$module | Confirm-SelectionProfileParamsAreValid -MDTDriveName $mdtDrive.Name | Out-Null

$existing = Get-MDTSelectionProfile -Module $module -MDTDriveName $mdtDrive.Name -Guid $module.Params.guid -Name $module.Params.name |
    Format-MDTSelectionProfile

if ($null -ne $existing -and $existing.read_only) {
    $module.FailJson("The selection profile is read-only.")
}

$module.Diff.before = $existing
$module.Result.changed = $false

$state = $module.Params.state

if ($state -eq "present") {

    $expected = Get-ExpectedSelectionProfile -Module $module -MDTDriveName $mdtDrive.Name -Existing $existing

    $module.Diff.after = $expected
    $module.Result.selection_profile = $expected

    if ($null -ne $existing) {

        $propertyChanges = Compare-ExpectedSelectionProfileToExisting -Expected $expected -Existing $existing

        if ($propertyChanges.Count -gt 0) {

            $module.Result.changed = $true
            Set-MDTSelectionProfile -Module $module -MDTDriveName $mdtDrive.Name @propertyChanges
        }
    }
    else {
        $module.Result.changed = $true
        New-MDTSelectionProfile -Module $module -MDTDriveName $mdtDrive.Name -Expected $expected | Out-Null
    }

}
else {

    $module.Diff.after = $null

    if ($null -ne $existing) {

        $module.Result.changed = $true
        Remove-MDTSelectionProfile -Module $module -MDTDriveName $mdtDrive.Name -Existing $existing
    }
}

$mdtDrive | Remove-PSDrive | Out-Null

$module.ExitJson()
