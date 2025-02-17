#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.Common
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.DeploymentShare
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.SelectionProfile

function Confirm-DeploymentShareSettingsParamsAreValid {
    <#
    .SYNOPSIS
    Confirms that the parameters are valid.

    .DESCRIPTION
    This function confirms that the parameters are valid.

    .PARAMETER Module
    The Ansible module.

    .EXAMPLE
    Confirm-DeploymentShareSettingsParamsAreValid -Module $module
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

        $x86 = $Module.Params.x86

        if ($null -ne $x86) {

            $backgroundFile = $x86.background_file
            $extraDirectory = $x86.extra_directory
            $featurePacks = $x86.feature_packs
            $genericIso = $x86.generic_iso
            $genericWim = $x86.generic_wim
            $litetouchIso = $x86.litetouch_iso
            $litetouchWim = $x86.litetouch_wim
            $includeDrivers = $x86.include_drivers
            $scratchSpace = $x86.scratch_space
            $selectionProfile = $x86.selection_profile

            if ($null -eq $x86.enabled) {

                if ($null -ne $backgroundFile -or
                    $null -ne $extraDirectory -or
                    $null -ne $featurePacks -or
                    $null -ne $genericIso -or
                    $null -ne $genericWim -or
                    $null -ne $litetouchIso -or
                    $null -ne $litetouchWim -or
                    $null -ne $includeDrivers -or
                    $null -ne $scratchSpace -or
                    $null -ne $selectionProfile) {
                    $x86.enabled = $true
                }
            }
            elseif (-not $x86.enabled) {

                if ($null -ne $backgroundFile -or
                    $null -ne $extraDirectory -or
                    $null -ne $featurePacks -or
                    $null -ne $genericIso -or
                    $null -ne $genericWim -or
                    $null -ne $litetouchIso -or
                    $null -ne $litetouchWim -or
                    $null -ne $includeDrivers -or
                    $null -ne $scratchSpace -or
                    $null -ne $selectionProfile) {
                    $Module.FailJson('The enabled parameter must be true if any other x86 parameters are specified.')
                }
            }

            if ($null -ne $genericWim) {

                $genericWimDescription = $genericWim.description

                if ($null -eq $genericWim.enabled) {

                    if ($null -ne $genericWimDescription) {
                        $genericWim.enabled = $true
                    }
                }
                elseif (-not $genericWim.enabled) {

                    if ($null -ne $genericWimDescription) {
                        $Module.FailJson('The enabled parameter must be true if the description parameter is specified for the generic_wim parameter.')
                    }
                }
            }

            if ($null -ne $genericIso) {

                $genericIsoName = $genericIso.name

                if ($null -eq $genericIso.enabled) {

                    if ($null -ne $genericIsoName) {
                        $genericIso.enabled = $true
                    }
                }
                elseif (-not $genericIso.enabled) {

                    if ($null -ne $genericIsoName) {
                        $Module.FailJson('The enabled parameter must be true if the name parameter is specified for the generic_iso parameter.')
                    }
                }

                if ($null -eq $genericWim.enabled -and $genericIso.enabled) {
                    $genericWim.enabled = $true
                }
                elseif (-not $genericWim.enabled -and $genericIso.enabled) {
                    $Module.FailJson('The generic_iso parameter cannot be enabled if the generic_wim parameter is not enabled.')
                }

                if ($null -ne $genericIsoName) {

                    if ([System.IO.Path]::GetExtension($genericIsoName) -ne '.iso') {
                        $Module.FailJson('The name parameter for the generic_iso parameter must have an .iso extension.')
                    }

                    $genericIsoName | Confirm-MDTPathSegmentIsValid -Module $Module -ParameterName 'x86.generic_iso.name' | Out-Null
                }
            }

            if ($null -ne $litetouchIso) {

                $litetouchIsoName = $litetouchIso.name

                if ($null -eq $litetouchIso.enabled) {

                    if ($null -ne $litetouchIsoName) {
                        $litetouchIso.enabled = $true
                    }
                }
                elseif (-not $litetouchIso.enabled) {

                    if ($null -ne $litetouchIsoName) {
                        $Module.FailJson('The enabled parameter must be true if the name parameter is specified for the litetouch_iso parameter.')
                    }
                }

                if ($null -ne $litetouchIsoName) {

                    if ([System.IO.Path]::GetExtension($litetouchIsoName) -ne '.iso') {
                        $Module.FailJson('The name parameter for the litetouch_iso parameter must have an .iso extension.')
                    }

                    $litetouchIsoName | Confirm-MDTPathSegmentIsValid -Module $Module -ParameterName 'x86.litetouch_iso.name' | Out-Null
                }
            }

            if ($null -ne $includeDrivers) {
                if (($null -ne ($includeDrivers | Where-Object { $_ -eq 'all' })) -and $includeDrivers.Count -gt 1) {
                    $Module.FailJson('The all parameter cannot be specified with other include_drivers parameters.')
                }
            }
        }

        $x64 = $Module.Params.x64

        if ($null -ne $x64) {

            $backgroundFile = $x64.background_file
            $extraDirectory = $x64.extra_directory
            $featurePacks = $x64.feature_packs
            $genericIso = $x64.generic_iso
            $genericWim = $x64.generic_wim
            $litetouchIso = $x64.litetouch_iso
            $litetouchWim = $x64.litetouch_wim
            $includeDrivers = $x64.include_drivers
            $scratchSpace = $x64.scratch_space
            $selectionProfile = $x64.selection_profile

            if ($null -eq $x64.enabled) {

                if ($null -ne $backgroundFile -or
                    $null -ne $extraDirectory -or
                    $null -ne $featurePacks -or
                    $null -ne $genericIso -or
                    $null -ne $genericWim -or
                    $null -ne $litetouchIso -or
                    $null -ne $litetouchWim -or
                    $null -ne $includeDrivers -or
                    $null -ne $scratchSpace -or
                    $null -ne $selectionProfile) {
                    $x64.enabled = $true
                }
            }
            elseif (-not $x64.enabled) {

                if ($null -ne $backgroundFile -or
                    $null -ne $extraDirectory -or
                    $null -ne $featurePacks -or
                    $null -ne $genericIso -or
                    $null -ne $genericWim -or
                    $null -ne $litetouchIso -or
                    $null -ne $litetouchWim -or
                    $null -ne $includeDrivers -or
                    $null -ne $scratchSpace -or
                    $null -ne $selectionProfile) {
                    $Module.FailJson('The enabled parameter must be true if any other x64 parameters are specified.')
                }
            }

            if ($null -ne $genericWim) {

                $genericWimDescription = $genericWim.description

                if ($null -eq $genericWim.enabled) {

                    if ($null -ne $genericWimDescription) {
                        $genericWim.enabled = $true
                    }
                }
                elseif (-not $genericWim.enabled) {

                    if ($null -ne $genericWimDescription) {
                        $Module.FailJson('The enabled parameter must be true if the description parameter is specified for the generic_wim parameter.')
                    }
                }
            }

            if ($null -ne $genericIso) {

                $genericIsoName = $genericIso.name

                if ($null -eq $genericIso.enabled) {

                    if ($null -ne $genericIsoName) {
                        $genericIso.enabled = $true
                    }
                }
                elseif (-not $genericIso.enabled) {

                    if ($null -ne $genericIsoName) {
                        $Module.FailJson('The enabled parameter must be true if the name parameter is specified for the generic_iso parameter.')
                    }
                }

                if ($null -eq $genericWim.enabled -and $genericIso.enabled) {
                    $genericWim.enabled = $true
                }
                elseif (-not $genericWim.enabled -and $genericIso.enabled) {
                    $Module.FailJson('The generic_iso parameter cannot be enabled if the generic_wim parameter is not enabled.')
                }

                if ($null -ne $genericIsoName) {

                    if ([System.IO.Path]::GetExtension($genericIsoName) -ne '.iso') {
                        $Module.FailJson('The name parameter for the generic_iso parameter must have an .iso extension.')
                    }

                    $genericIsoName | Confirm-MDTPathSegmentIsValid -Module $Module -ParameterName 'x64.generic_iso.name' | Out-Null
                }
            }

            if ($null -ne $litetouchIso) {

                $litetouchIsoName = $litetouchIso.name

                if ($null -eq $litetouchIso.enabled) {

                    if ($null -ne $litetouchIsoName) {
                        $litetouchIso.enabled = $true
                    }
                }
                elseif (-not $litetouchIso.enabled) {

                    if ($null -ne $litetouchIsoName) {
                        $Module.FailJson('The enabled parameter must be true if the name parameter is specified for the litetouch_iso parameter.')
                    }
                }

                if ($null -ne $litetouchIsoName) {

                    if ([System.IO.Path]::GetExtension($litetouchIsoName) -ne '.iso') {
                        $Module.FailJson('The name parameter for the litetouch_iso parameter must have an .iso extension.')
                    }

                    $litetouchIsoName | Confirm-MDTPathSegmentIsValid -Module $Module -ParameterName 'x64.litetouch_iso.name' | Out-Null
                }
            }

            if ($null -ne $includeDrivers) {
                if (($null -ne ($includeDrivers | Where-Object { $_ -eq 'all' })) -and $includeDrivers.Count -gt 1) {
                    $Module.FailJson('The all parameter cannot be specified with other include_drivers parameters.')
                }
            }
        }
    }
}

function Confirm-DeploymentShareSettingsSelectionProfileParamsAreValid {
    <#
    .SYNOPSIS
    Confirms that the selection profile parameters are valid.

    .DESCRIPTION
    This function confirms that the selection profile parameters are valid.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The MDT drive name.

    .EXAMPLE
    Confirm-DeploymentShareSettingsSelectionProfileParamsAreValid -Module $module -MDTDriveName $mdtDriveName
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true)]
        [string]$MDTDriveName
    )

    process {

        $x86SelectionProfile = $Module.Params.x86.selection_profile

        if ($null -ne $x86SelectionProfile) {

            $matchingSelectionProfile = Get-MDTSelectionProfile -Module $Module -MDTDriveName $MDTDriveName -Name $x86SelectionProfile

            if ($null -eq $matchingSelectionProfile) {
                $Module.FailJson("The x86 selection profile '$x86SelectionProfile' does not exist.")
            }
        }

        $x64SelectionProfile = $Module.Params.x64.selection_profile

        if ($null -ne $x64SelectionProfile) {

            $matchingSelectionProfile = Get-MDTSelectionProfile -Module $Module -MDTDriveName $MDTDriveName -Name $x64SelectionProfile

            if ($null -eq $matchingSelectionProfile) {
                $Module.FailJson("The x64 selection profile '$x64SelectionProfile' does not exist.")
            }
        }
    }
}

function Get-ExpectedDeploymentShareSettingsValue {
    <#
    .SYNOPSIS
    Gets an expected MDT deployment share settings.

    .DESCRIPTION
    This function gets an expected MDT deployment share settings.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER Existing
    The existing deployment share settings.

    .EXAMPLE
    Get-ExpectedDeploymentShareSettingsValue -Module $module -Existing $existing

    .OUTPUTS
    System.Collections.Hashtable
    #>

    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$Existing
    )

    $comments = $Module.Params.comments
    $enableMulticast = $Module.Params.enable_multicast

    $expected = @{
        x86 = Get-ExpectedDeploymentShareArchitecture -Params $Module.Params.x86 -Existing $Existing.x86
        x64 = Get-ExpectedDeploymentShareArchitecture -Params $Module.Params.x64 -Existing $Existing.x64
    }

    if ($null -ne $comments) {
        $expected.comments = $comments
    }
    else {
        $expected.comments = $Existing.comments
    }

    if ($null -ne $enableMulticast) {
        $expected.enable_multicast = $enableMulticast
    }
    else {
        $expected.enable_multicast = $Existing.enable_multicast
    }

    return $expected
}

function Get-ExpectedDeploymentShareArchitecture {
    <#
    .SYNOPSIS
    Gets the expected MDT deployment share architecture settings.

    .DESCRIPTION
    This function gets the expected MDT deployment share architecture settings.

    .PARAMETER Params
    The parameters.

    .PARAMETER Existing
    The existing settings.

    .EXAMPLE
    Get-ExpectedDeploymentShareArchitecture -Params $params -Existing $existing

    .OUTPUTS
    System.Collections.Hashtable
    #>

    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Collections.Hashtable]$Params,
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$Existing
    )

    $genericWim = Get-ExpectedDeploymentShareGenericWim `
        -Params $Params.generic_wim `
        -Existing $Existing.generic_wim

    $genericIso = Get-ExpectedDeploymentShareGenericIso `
        -Params $Params.generic_iso `
        -Existing $Existing.generic_iso `
        -GenericWim $genericWim

    $litetouchIso = Get-ExpectedDeploymentShareLitetouchIso `
        -Params $Params.litetouch_iso `
        -Existing $Existing.litetouch_iso

    if ($null -eq $Params) {

        if ($Existing.enabled) {

            return @{
                enabled = $true
                background_file = $Existing.background_file
                extra_directory = $Existing.extra_directory
                feature_packs = $Existing.feature_packs
                generic_iso = $genericIso
                generic_wim = $genericWim
                litetouch_iso = $litetouchIso
                litetouch_wim = $Existing.litetouch_wim
                include_drivers = $Existing.include_drivers
                scratch_space = $Existing.scratch_space
                selection_profile = $Existing.selection_profile
            }
        }

        return @{
            enabled = $false
        }
    }

    $expected = @{}

    if ($null -ne $Params.enabled) {
        $expected.enabled = $Params.enabled
    }
    else {
        $expected.enabled = $Existing.enabled
    }

    if ($Params.enabled) {

        $expected.generic_iso = $genericIso
        $expected.generic_wim = $genericWim
        $expected.litetouch_iso = $litetouchIso

        if ($null -ne $Params.background_file) {
            $expected.background_file = $Params.background_file
        }
        else {
            $expected.background_file = $Existing.background_file
        }

        if ($null -ne $Params.extra_directory) {
            $expected.extra_directory = $Params.extra_directory
        }
        else {
            $expected.extra_directory = $Existing.extra_directory
        }

        if ($null -ne $Params.feature_packs) {
            $expected.feature_packs = $Params.feature_packs
        }
        else {
            $expected.feature_packs = $Existing.feature_packs
        }

        if ($null -ne $Params.litetouch_wim) {
            $expected.litetouch_wim = $Params.litetouch_wim
        }
        else {
            $expected.litetouch_wim = $Existing.litetouch_wim
        }

        if ($null -ne $Params.include_drivers) {
            $expected.include_drivers = $Params.include_drivers
        }
        else {
            $expected.include_drivers = $Existing.include_drivers
        }

        if ($null -ne $Params.scratch_space) {
            $expected.scratch_space = $Params.scratch_space
        }
        else {
            if ($Existing.scratch_space -ge 0) {
                $expected.scratch_space = $Existing.scratch_space
            }
            else {
                $expected.scratch_space = 32
            }
        }

        if ($null -ne $Params.selection_profile) {
            $expected.selection_profile = $Params.selection_profile
        }
        else {
            $expected.selection_profile = $Existing.selection_profile
        }
    }

    return $expected
}

function Get-ExpectedDeploymentShareGenericIso {
    <#
    .SYNOPSIS
    Gets the expected MDT deployment share generic ISO settings.

    .DESCRIPTION
    This function gets the expected MDT deployment share generic ISO settings.

    .PARAMETER GenericWim
    The generic WIM settings.

    .PARAMETER Params
    The parameters.

    .PARAMETER Existing
    The existing settings.

    .EXAMPLE
    Get-ExpectedDeploymentShareGenericIso -GenericWim $genericWim -Params $params -Existing $existing

    .OUTPUTS
    System.Collections.Hashtable
    #>

    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$GenericWim,
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Collections.Hashtable]$Params,
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$Existing
    )

    if (-not $GenericWim.enabled) {
        return @{
            enabled = $false
        }
    }

    if ($null -eq $Params) {

        if ($Existing.enabled) {
            return $Existing
        }

        return @{
            enabled = $false
        }
    }

    $expected = @{}

    if ($null -ne $Params.enabled) {
        $expected.enabled = $Params.enabled
    }
    else {
        $expected.enabled = $Existing.enabled
    }

    if ($expected.enabled) {
        if ($null -ne $Params.name) {
            $expected.name = $Params.name
        }
        else {
            $expected.name = $Existing.name
        }
    }

    return $expected
}

function Get-ExpectedDeploymentShareGenericWim {
    <#
    .SYNOPSIS
    Gets the expected MDT deployment share generic WIM settings.

    .DESCRIPTION
    This function gets the expected MDT deployment share generic WIM settings.

    .PARAMETER Params
    The parameters.

    .PARAMETER Existing
    The existing settings.

    .EXAMPLE
    Get-ExpectedDeploymentShareGenericWim -Params $params -Existing $existing

    .OUTPUTS
    System.Collections.Hashtable
    #>

    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Collections.Hashtable]$Params,
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$Existing
    )

    if ($null -eq $Params) {

        if ($Existing.enabled) {
            return $Existing
        }

        return @{
            enabled = $false
        }
    }

    $expected = @{}

    if ($null -ne $Params.enabled) {
        $expected.enabled = $Params.enabled
    }
    else {
        $expected.enabled = $Existing.enabled
    }

    if ($expected.enabled) {
        if ($null -ne $Params.description) {
            $expected.description = $Params.description
        }
        else {
            $expected.description = $Existing.description
        }
    }

    return $expected
}

function Get-ExpectedDeploymentShareLitetouchIso {
    <#
    .SYNOPSIS
    Gets the expected MDT deployment share LiteTouch ISO settings.

    .DESCRIPTION
    This function gets the expected MDT deployment share LiteTouch ISO settings.

    .PARAMETER Params
    The parameters.

    .PARAMETER Existing
    The existing settings.

    .EXAMPLE
    Get-ExpectedDeploymentShareLitetouchIso -Params $params -Existing $existing

    .OUTPUTS
    System.Collections.Hashtable
    #>

    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Collections.Hashtable]$Params,
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$Existing
    )

    if ($null -eq $Params) {

        if ($Existing.enabled) {
            return $Existing
        }

        return @{
            enabled = $false
        }
    }

    $expected = @{}

    if ($null -ne $Params.enabled) {
        $expected.enabled = $Params.enabled
    }
    else {
        $expected.enabled = $Existing.enabled
    }

    if ($expected.enabled) {
        if ($null -ne $Params.name) {
            $expected.name = $Params.name
        }
        else {
            $expected.name = $Existing.name
        }
    }

    return $expected
}

function Compare-ExpectedDeploymentShareSettingsToExisting {
    <#
    .SYNOPSIS
    Compares an expected MDT deployment share settings to existing settings.

    .DESCRIPTION
    This function compares an expected MDT deployment share settings to existing settings.

    .PARAMETER Expected
    The expected deployment share settings.

    .PARAMETER Existing
    The existing deployment share settings.

    .EXAMPLE
    Compare-ExpectedDeploymentShareSettingsToExisting -Expected $expected -Existing $existing

    .OUTPUTS
    System.Collections.Hashtable
    #>

    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$Existing,
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$Expected
    )

    $propertyChanges = @{}

    if ($Expected.comments -ne $Existing.comments) {
        if ([string]::IsNullOrWhiteSpace($Expected.comments)) {
            $propertyChanges.CommentsEmpty = $true
        }
        else {
            $propertyChanges.Comments = $Expected.comments
        }
    }

    if ($Expected.enable_multicast -ne $Existing.enable_multicast) {
        $propertyChanges.EnableMulticast = $Expected.enable_multicast
    }

    $x86PropertyChanges = Compare-ExpectedDeploymentShareArchitectureSettingsToExisting -Existing $Existing.x86 -Expected $Expected.x86

    if ($x86PropertyChanges.Count -gt 0) {
        $propertyChanges.X86 = $x86PropertyChanges
    }

    $x64PropertyChanges = Compare-ExpectedDeploymentShareArchitectureSettingsToExisting -Existing $Existing.x64 -Expected $Expected.x64

    if ($x64PropertyChanges.Count -gt 0) {
        $propertyChanges.X64 = $x64PropertyChanges
    }

    return $propertyChanges
}

function Compare-ExpectedDeploymentShareArchitectureSettingsToExisting {

    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$Existing,
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$Expected
    )

    $propertyChanges = @{}

    if ($Expected.enabled -ne $Existing.enabled) {
        $propertyChanges.Enabled = $Expected.enabled
    }

    if (-not $Expected.enabled) {
        return $propertyChanges
    }

    if ($Expected.background_file -ne $Existing.background_file) {
        $propertyChanges.BackgroundFile = $Expected.background_file
    }

    if ($Expected.extra_directory -ne $Existing.extra_directory) {
        if ([string]::IsNullOrWhiteSpace($Expected.extra_directory)) {
            $propertyChanges.ExtraDirectoryEmpty = $true
        }
        else {
            $propertyChanges.ExtraDirectory = $Expected.extra_directory
        }
    }

    $missingFeaturePacks = $Expected.feature_packs | Where-Object { $null -eq ($Existing.feature_packs | Where-Object { $_ -eq $_ }) }
    $extraFeaturePacks = $Existing.feature_packs | Where-Object { $null -eq ($Expected.feature_packs | Where-Object { $_ -eq $_ }) }

    if ($missingFeaturePacks.Count -gt 0 -or $extraFeaturePacks.Count -gt 0) {
        $propertyChanges.FeaturePacks = $Expected.feature_packs
    }

    $genericIsoPropertyChanges = Compare-ExpectedDeploymentShareGenericIsoSettingsToExisting `
        -Existing $Existing.generic_iso `
        -Expected $Expected.generic_iso

    if ($genericIsoPropertyChanges.Count -gt 0) {
        $propertyChanges.GenericIso = $genericIsoPropertyChanges
    }

    $genericWimPropertyChanges = Compare-ExpectedDeploymentShareGenericWimSettingsToExisting `
        -Existing $Existing.generic_wim `
        -Expected $Expected.generic_wim

    if ($genericWimPropertyChanges.Count -gt 0) {
        $propertyChanges.GenericWim = $genericWimPropertyChanges
    }

    $litetouchIsoPropertyChanges = Compare-ExpectedDeploymentShareLitetouchIsoSettingsToExisting `
        -Existing $Existing.litetouch_iso `
        -Expected $Expected.litetouch_iso

    if ($litetouchIsoPropertyChanges.Count -gt 0) {
        $propertyChanges.LitetouchIso = $litetouchIsoPropertyChanges
    }

    if ($Expected.litetouch_wim.description -ne $Existing.litetouch_wim.description) {
        $propertyChanges.LitetouchWimDescription = $Expected.litetouch_wim.description
    }

    return $propertyChanges
}

function Compare-ExpectedDeploymentShareGenericIsoSettingsToExisting {
    <#
    .SYNOPSIS
    Compares expected MDT deployment share generic ISO settings to existing settings.

    .DESCRIPTION
    This function compares expected MDT deployment share generic ISO settings to existing settings.

    .PARAMETER Expected
    The expected settings.

    .PARAMETER Existing
    The existing settings.

    .EXAMPLE
    Compare-ExpectedDeploymentShareGenericIsoSettingsToExisting -Expected $expected -Existing $existing

    .OUTPUTS
    System.Collections.Hashtable
    #>

    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$Existing,
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$Expected
    )

    $propertyChanges = @{}

    if ($Expected.enabled -ne $Existing.enabled) {
        $propertyChanges.Enabled = $Expected.enabled
    }

    if (-not $Expected.enabled) {
        return $propertyChanges
    }

    if ($Expected.name -ne $Existing.name) {
        $propertyChanges.Name = $Expected.name
    }

    return $propertyChanges
}

function Compare-ExpectedDeploymentShareGenericWimSettingsToExisting {
    <#
    .SYNOPSIS
    Compares expected MDT deployment share generic WIM settings to existing settings.

    .DESCRIPTION
    This function compares expected MDT deployment share generic WIM settings to existing settings.

    .PARAMETER Expected
    The expected settings.

    .PARAMETER Existing
    The existing settings.

    .EXAMPLE
    Compare-ExpectedDeploymentShareGenericWimSettingsToExisting -Expected $expected -Existing $existing

    .OUTPUTS
    System.Collections.Hashtable
    #>

    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$Existing,
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$Expected
    )

    $propertyChanges = @{}

    if ($Expected.enabled -ne $Existing.enabled) {
        $propertyChanges.Enabled = $Expected.enabled
    }

    if (-not $Expected.enabled) {
        return $propertyChanges
    }

    if ($Expected.description -ne $Existing.description) {
        $propertyChanges.Description = $Expected.description
    }

    return $propertyChanges
}

function Compare-ExpectedDeploymentShareLitetouchIsoSettingsToExisting {
    <#
    .SYNOPSIS
    Compares expected MDT deployment share LiteTouch ISO settings to existing settings.

    .DESCRIPTION
    This function compares expected MDT deployment share LiteTouch ISO settings to existing settings.

    .PARAMETER Expected
    The expected settings.

    .PARAMETER Existing
    The existing settings.

    .EXAMPLE
    Compare-ExpectedDeploymentShareLitetouchIsoSettingsToExisting -Expected $expected -Existing $existing

    .OUTPUTS
    System.Collections.Hashtable
    #>

    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$Existing,
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$Expected
    )

    $propertyChanges = @{}

    if ($Expected.enabled -ne $Existing.enabled) {
        $propertyChanges.Enabled = $Expected.enabled
    }

    if (-not $Expected.enabled) {
        return $propertyChanges
    }

    if ($Expected.name -ne $Existing.name) {
        $propertyChanges.Name = $Expected.name
    }

    return $propertyChanges
}

function Set-MDTDeploymentShareSettingsValue {
    <#
    .SYNOPSIS
    Sets the MDT deployment share settings.

    .DESCRIPTION
    This function sets the MDT deployment share settings.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDrive
    The MDT drive.

    .PARAMETER CommentsEmpty
    Whether the comments are empty.

    .PARAMETER Comments
    The comments.

    .PARAMETER EnableMulticast
    The enable multicast.

    .PARAMETER X86
    The x86 settings.

    .PARAMETER X64
    The x64 settings.

    .EXAMPLE
    Set-MDTDeploymentShareSettingsValue `
        -Module $module `
        -MDTDrive $mdtDrive `
        -Comments "Comments" `
        -EnableMulticast $true `
        -X86 $X86 `
        -X64 $X64
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSDriveInfo]$MDTDrive,
        [Parameter(Mandatory = $false)]
        [bool]$CommentsEmpty = $false,
        [Parameter(Mandatory = $false)]
        [string]$Comments,
        [Parameter(Mandatory = $false)]
        [ValidateSet($null, $false, $true)]
        [object]$EnableMulticast,
        [Parameter(Mandatory = $false)]
        [System.Collections.Hashtable]$X86,
        [Parameter(Mandatory = $false)]
        [System.Collections.Hashtable]$X64
    )

    $Module.Result.changed = $true

    if ($Module.CheckMode) {
        return
    }

    $rootFolder = $MDTDrive | Get-MDTDeploymentShareRootFolder -Module $Module

    if ($CommentsEmpty) {
        $rootFolder.Item("Comments") = ''
    }
    elseif (-not [string]::IsNullOrEmpty($Comments)) {
        $rootFolder.Item("Comments") = $Comments
    }

    if ($null -ne $EnableMulticast) {
        if ($EnableMulticast) {
            $rootFolder.Item("EnableMulticast") = "True"
        }
        else {
            $rootFolder.Item("EnableMulticast") = "False"
        }
    }

    if ($null -ne $X86) {
        Set-MDTDeploymentShareArchitecture `
            -RootFolder $rootFolder `
            -EnabledProperty "SupportX86" `
            -PropertyPrefix "Boot.x86" @X86
    }

    if ($null -ne $X64) {
        Set-MDTDeploymentShareArchitecture `
            -RootFolder $rootFolder `
            -EnabledProperty "SupportX64" `
            -PropertyPrefix "Boot.x64" @X64
    }
}

function Set-MDTDeploymentShareArchitecture {
    <#
    .SYNOPSIS
    Sets the MDT deployment share architecture settings.

    .DESCRIPTION
    This function sets the MDT deployment share architecture settings.

    .PARAMETER RootFolder
    The root folder.

    .PARAMETER EnabledProperty
    The enabled property.

    .PARAMETER PropertyPrefix
    The property prefix.

    .PARAMETER Enabled
    The enabled property value.

    .PARAMETER BackgroundFile
    The background file.

    .PARAMETER ExtraDirectoryEmpty
    Whether the extra directory is empty.

    .PARAMETER ExtraDirectory
    The extra directory.

    .PARAMETER FeaturePacks
    The feature packs.

    .PARAMETER GenericIso
    The generic ISO settings.

    .PARAMETER GenericWim
    The generic WIM settings.

    .PARAMETER LitetouchIso
    The LiteTouch ISO settings.

    .PARAMETER LitetouchWimDescription
    The LiteTouch WIM description.

    .PARAMETER IncludeDrivers
    The include drivers.

    .PARAMETER ScratchSpace
    The scratch space.

    .PARAMETER SelectionProfile
    The selection profile.

    .EXAMPLE
    Set-MDTDeploymentShareArchitecture `
        -RootFolder $rootFolder `
        -EnabledProperty "SupportX86" `
        -PropertyPrefix "Boot.x86" `
        -Enabled $true `
        -BackgroundFile "background.jpg" `
        -ExtraDirectory "C:\extra" `
        -FeaturePacks @("FeaturePack1", "FeaturePack2") `
        -GenericIso @{"enabled" = $true; "name" = "generic.iso"} `
        -GenericWim @{"enabled" = $true; "description" = "generic"} `
        -LitetouchIso @{"enabled" = $true; "name" = "litetouch.iso"} `
        -LitetouchWimDescription "litetouch" `
        -IncludeDrivers @("all") `
        -ScratchSpace 32 `
        -SelectionProfile "profile"
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true)]
        [Microsoft.BDD.PSSnapIn.MDTObject]$RootFolder,
        [Parameter(Mandatory = $true)]
        [string]$EnabledProperty,
        [Parameter(Mandatory = $true)]
        [string]$PropertyPrefix,
        [Parameter(Mandatory = $false)]
        [ValidateSet($null, $false, $true)]
        [object]$Enabled,
        [Parameter(Mandatory = $false)]
        [string]$BackgroundFile,
        [Parameter(Mandatory = $false)]
        [bool]$ExtraDirectoryEmpty = $false,
        [Parameter(Mandatory = $false)]
        [string]$ExtraDirectory,
        [Parameter(Mandatory = $false)]
        [string[]]$FeaturePacks,
        [Parameter(Mandatory = $false)]
        [System.Collections.Hashtable]$GenericIso,
        [Parameter(Mandatory = $false)]
        [System.Collections.Hashtable]$GenericWim,
        [Parameter(Mandatory = $false)]
        [System.Collections.Hashtable]$LitetouchIso,
        [Parameter(Mandatory = $false)]
        [string]$LitetouchWimDescription,
        [Parameter(Mandatory = $false)]
        [string[]]$IncludeDrivers,
        [Parameter(Mandatory = $false)]
        [int]$ScratchSpace,
        [Parameter(Mandatory = $false)]
        [string]$SelectionProfile
    )

    if ($null -ne $Enabled) {
        if ($Enabled) {
            $RootFolder.Item($EnabledProperty) = "True"
        }
        else {
            $RootFolder.Item($EnabledProperty) = "False"
        }
    }

    if (-not [string]::IsNullOrEmpty($BackgroundFile)) {
        $RootFolder.Item("$($PropertyPrefix).BackgroundFile") = $BackgroundFile
    }

    if ($ExtraDirectoryEmpty) {
        $RootFolder.Item("$($PropertyPrefix).ExtraDirectory") = ''
    }
    elseif (-not [string]::IsNullOrEmpty($ExtraDirectory)) {
        $RootFolder.Item("$($PropertyPrefix).ExtraDirectory") = $ExtraDirectory
    }

    if ($null -ne $FeaturePacks) {
        $RootFolder.Item("$($PropertyPrefix).FeaturePacks") = $FeaturePacks -join ','
    }

    if (-not [string]::IsNullOrEmpty($LitetouchWimDescription)) {
        $RootFolder.Item("$($PropertyPrefix).LiteTouchWIMDescription") = $LitetouchWimDescription
    }

    if ($null -ne $IncludeDrivers) {

        if ($IncludeDrivers -contains 'all') {
            $RootFolder.Item("$($PropertyPrefix).IncludeAllDrivers") = "True"
        }
        else {
            $RootFolder.Item("$($PropertyPrefix).IncludeAllDrivers") = "False"
        }

        if ($IncludeDrivers -contains 'network') {
            $RootFolder.Item("$($PropertyPrefix).IncludeNetworkDrivers") = "True"
        }
        else {
            $RootFolder.Item("$($PropertyPrefix).IncludeNetworkDrivers") = "False"
        }

        if ($IncludeDrivers -contains 'mass_storage') {
            $RootFolder.Item("$($PropertyPrefix).IncludeMassStorageDrivers") = "True"
        }
        else {
            $RootFolder.Item("$($PropertyPrefix).IncludeMassStorageDrivers") = "False"
        }

        if ($IncludeDrivers -contains 'system') {
            $RootFolder.Item("$($PropertyPrefix).IncludeSystemDrivers") = "True"
        }
        else {
            $RootFolder.Item("$($PropertyPrefix).IncludeSystemDrivers") = "False"
        }

        if ($IncludeDrivers -contains 'video') {
            $RootFolder.Item("$($PropertyPrefix).IncludeVideoDrivers") = "True"
        }
        else {
            $RootFolder.Item("$($PropertyPrefix).IncludeVideoDrivers") = "False"
        }
    }

    if ($null -ne $ScratchSpace -and $ScratchSpace -gt 0) {
        $RootFolder.Item("$($PropertyPrefix).ScratchSpace") = $ScratchSpace.ToString()
    }

    if (-not [string]::IsNullOrEmpty($SelectionProfile)) {
        $RootFolder.Item("$($PropertyPrefix).SelectionProfile") = $SelectionProfile
    }

    if ($null -ne $GenericIso) {
        Set-MDTDeploymentShareGenericIso -RootFolder $RootFolder -PropertyPrefix $PropertyPrefix @GenericIso
    }

    if ($null -ne $GenericWim) {
        Set-MDTDeploymentShareGenericWim -RootFolder $RootFolder -PropertyPrefix $PropertyPrefix @GenericWim
    }

    if ($null -ne $LitetouchIso) {
        Set-MDTDeploymentShareLitetouchIso -RootFolder $RootFolder -PropertyPrefix $PropertyPrefix @LitetouchIso
    }
}

function Set-MDTDeploymentShareGenericIso {
    <#
    .SYNOPSIS
    Sets the MDT deployment share generic ISO settings.

    .DESCRIPTION
    This function sets the MDT deployment share generic ISO settings.

    .PARAMETER RootFolder
    The root folder.

    .PARAMETER PropertyPrefix
    The property prefix.

    .PARAMETER Enabled
    The enabled property value.

    .PARAMETER Name
    The name.

    .EXAMPLE
    Set-MDTDeploymentShareGenericIso `
        -RootFolder $rootFolder `
        -PropertyPrefix "Boot.x86" `
        -Enabled $true `
        -Name "generic.iso"
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true)]
        [Microsoft.BDD.PSSnapIn.MDTObject]$RootFolder,
        [Parameter(Mandatory = $true)]
        [string]$PropertyPrefix,
        [Parameter(Mandatory = $false)]
        [ValidateSet($null, $false, $true)]
        [object]$Enabled,
        [Parameter(Mandatory = $false)]
        [string]$Name
    )

    if ($null -ne $Enabled) {
        if ($Enabled) {
            $RootFolder.Item("$($PropertyPrefix).GenerateGenericISO") = "True"
        }
        else {
            $RootFolder.Item("$($PropertyPrefix).GenerateGenericISO") = "False"
        }
    }

    if (-not [string]::IsNullOrEmpty($Name)) {
        $RootFolder.Item("$($PropertyPrefix).GenericISOName") = $Name
    }
}

function Set-MDTDeploymentShareGenericWim {
    <#
    .SYNOPSIS
    Sets the MDT deployment share generic WIM settings.

    .DESCRIPTION
    This function sets the MDT deployment share generic WIM settings.

    .PARAMETER RootFolder
    The root folder.

    .PARAMETER PropertyPrefix
    The property prefix.

    .PARAMETER Enabled
    The enabled property value.

    .PARAMETER Description
    The description.

    .EXAMPLE
    Set-MDTDeploymentShareGenericWim `
        -RootFolder $rootFolder `
        -PropertyPrefix "Boot.x86" `
        -Enabled $true `
        -Description "generic"
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true)]
        [Microsoft.BDD.PSSnapIn.MDTObject]$RootFolder,
        [Parameter(Mandatory = $true)]
        [string]$PropertyPrefix,
        [Parameter(Mandatory = $false)]
        [ValidateSet($null, $false, $true)]
        [object]$Enabled,
        [Parameter(Mandatory = $false)]
        [string]$Description
    )

    if ($null -ne $Enabled) {
        if ($Enabled) {
            $RootFolder.Item("$($PropertyPrefix).GenerateGenericWIM") = "True"
        }
        else {
            $RootFolder.Item("$($PropertyPrefix).GenerateGenericWIM") = "False"
        }
    }

    if (-not [string]::IsNullOrEmpty($Description)) {
        $RootFolder.Item("$($PropertyPrefix).GenericWIMDescription") = $Description
    }
}

function Set-MDTDeploymentShareLitetouchIso {
    <#
    .SYNOPSIS
    Sets the MDT deployment share LiteTouch ISO settings.

    .DESCRIPTION
    This function sets the MDT deployment share LiteTouch ISO settings.

    .PARAMETER RootFolder
    The root folder.

    .PARAMETER PropertyPrefix
    The property prefix.

    .PARAMETER Enabled
    The enabled property value.

    .PARAMETER Name
    The name.

    .EXAMPLE
    Set-MDTDeploymentShareLitetouchIso `
        -RootFolder $rootFolder `
        -PropertyPrefix "Boot.x86" `
        -Enabled $true `
        -Name "litetouch.iso"
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true)]
        [Microsoft.BDD.PSSnapIn.MDTObject]$RootFolder,
        [Parameter(Mandatory = $true)]
        [string]$PropertyPrefix,
        [Parameter(Mandatory = $false)]
        [ValidateSet($null, $false, $true)]
        [object]$Enabled,
        [Parameter(Mandatory = $false)]
        [string]$Name
    )

    if ($null -ne $Enabled) {
        if ($Enabled) {
            $RootFolder.Item("$($PropertyPrefix).GenerateLiteTouchISO") = "True"
        }
        else {
            $RootFolder.Item("$($PropertyPrefix).GenerateLiteTouchISO") = "False"
        }
    }

    if (-not [string]::IsNullOrEmpty($Name)) {
        $RootFolder.Item("$($PropertyPrefix).LiteTouchISOName") = $Name
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
        comments = @{
            type = 'str'
            required = $false
        }
        enable_multicast = @{
            type = 'bool'
            required = $false
        }
        x86 = @{
            type = 'dict'
            required = $false
            options = @{
                enabled = @{
                    type = 'bool'
                    required = $false
                }
                background_file = @{
                    type = 'str'
                    required = $false
                }
                extra_directory = @{
                    type = 'str'
                    required = $false
                }
                feature_packs = @{
                    type = 'list'
                    required = $false
                    elements = 'str'
                }
                generic_iso = @{
                    type = 'dict'
                    required = $false
                    options = @{
                        enabled = @{
                            type = 'bool'
                            required = $false
                        }
                        name = @{
                            type = 'str'
                            required = $false
                        }
                    }
                    required_one_of = @(
                        , @('enabled', 'name')
                    )
                }
                generic_wim = @{
                    type = 'dict'
                    required = $false
                    options = @{
                        enabled = @{
                            type = 'bool'
                            required = $false
                        }
                        description = @{
                            type = 'str'
                            required = $false
                        }
                    }
                    required_one_of = @(
                        , @('enabled', 'description')
                    )
                }
                litetouch_iso = @{
                    type = 'dict'
                    required = $false
                    options = @{
                        enabled = @{
                            type = 'bool'
                            required = $false
                        }
                        name = @{
                            type = 'str'
                            required = $false
                        }
                    }
                    required_one_of = @(
                        , @('enabled', 'name')
                    )
                }
                litetouch_wim = @{
                    type = 'dict'
                    required = $false
                    options = @{
                        description = @{
                            type = 'str'
                            required = $true
                        }
                    }
                }
                include_drivers = @{
                    type = 'list'
                    required = $false
                    elements = 'str'
                    choices = @(
                        'all',
                        'mass_storage',
                        'network',
                        'system',
                        'video'
                    )
                }
                scratch_space = @{
                    type = 'int'
                    required = $false
                    choices = @(
                        32,
                        64,
                        128,
                        256,
                        512
                    )
                }
                selection_profile = @{
                    type = 'str'
                    required = $false
                }
            }
            required_one_of = @(
                , @(
                    'enabled',
                    'background_file',
                    'extra_directory',
                    'feature_packs',
                    'generic_iso',
                    'generic_wim',
                    'litetouch_iso',
                    'litetouch_wim',
                    'include_drivers',
                    'scratch_space',
                    'selection_profile'
                )
            )
        }
        x64 = @{
            type = 'dict'
            required = $false
            options = @{
                enabled = @{
                    type = 'bool'
                    required = $false
                }
                background_file = @{
                    type = 'str'
                    required = $false
                }
                extra_directory = @{
                    type = 'str'
                    required = $false
                }
                feature_packs = @{
                    type = 'list'
                    required = $false
                    elements = 'str'
                }
                generic_iso = @{
                    type = 'dict'
                    required = $false
                    options = @{
                        enabled = @{
                            type = 'bool'
                            required = $false
                        }
                        name = @{
                            type = 'str'
                            required = $false
                        }
                    }
                    required_one_of = @(
                        , @('enabled', 'name')
                    )
                }
                generic_wim = @{
                    type = 'dict'
                    required = $false
                    options = @{
                        enabled = @{
                            type = 'bool'
                            required = $false
                        }
                        description = @{
                            type = 'str'
                            required = $false
                        }
                    }
                    required_one_of = @(
                        , @('enabled', 'description')
                    )
                }
                litetouch_iso = @{
                    type = 'dict'
                    required = $false
                    options = @{
                        enabled = @{
                            type = 'bool'
                            required = $false
                        }
                        name = @{
                            type = 'str'
                            required = $false
                        }
                    }
                    required_one_of = @(
                        , @('enabled', 'name')
                    )
                }
                litetouch_wim = @{
                    type = 'dict'
                    required = $false
                    options = @{
                        description = @{
                            type = 'str'
                            required = $true
                        }
                    }
                }
                include_drivers = @{
                    type = 'list'
                    required = $false
                    elements = 'str'
                    choices = @(
                        'all',
                        'mass_storage',
                        'network',
                        'system',
                        'video'
                    )
                }
                scratch_space = @{
                    type = 'int'
                    required = $false
                    choices = @(
                        32,
                        64,
                        128,
                        256,
                        512
                    )
                }
                selection_profile = @{
                    type = 'str'
                    required = $false
                }
            }
            required_one_of = @(
                , @(
                    'enabled',
                    'background_file',
                    'extra_directory',
                    'feature_packs',
                    'generic_iso',
                    'generic_wim',
                    'litetouch_iso',
                    'litetouch_wim',
                    'include_drivers',
                    'scratch_space',
                    'selection_profile'
                )
            )
        }
    }
    required_one_of = @(
        , @(
            'comments',
            'enable_multicast',
            'x86',
            'x64'
        )
    )
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$module | Confirm-DeploymentShareSettingsParamsAreValid | Out-Null
Import-MDTModule -Module $module | Out-Null

$mdtDrive = Get-MDTPSDrive -Module $module

Confirm-DeploymentShareSettingsSelectionProfileParamsAreValid -MDTDriveName $mdtDrive.Name | Out-Null

$module.Diff.before = $mdtDrive |
    Get-MDTDeploymentShareRootFolder -Module $module |
    Format-MDTDeploymentShare

$existing = $mdtDrive |
    Get-MDTDeploymentShareRootFolder -Module $module |
    Format-MDTDeploymentShare -IncludeHiddenProperties

$expected = Get-ExpectedDeploymentShareSettingsValue -Module $module -Existing $existing

$module.Diff.after = $expected
$module.Result.deployment_share = $expected

$propertyChanges = Compare-ExpectedDeploymentShareSettingsToExisting -Existing $existing -Expected $expected

if ($propertyChanges.Count -gt 0) {
    Set-MDTDeploymentShareSettingsValue -Module $module -MDTDrive $mdtDrive @propertyChanges
}

$mdtDrive | Remove-PSDrive | Out-Null

$module.ExitJson()
