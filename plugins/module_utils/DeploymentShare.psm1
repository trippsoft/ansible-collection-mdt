function Get-MDTDeploymentShareDrive {

    [OutputType([System.Management.Automation.PSDriveInfo])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module
    )

    $mdtSharePath = $Module.Params.mdt_share_path

    $existing = Get-MDTPersistentDrive | Where-Object { $_.Path -ieq $mdtSharePath }

    if ($null -eq $existing) {
        return $null
    }

    return New-PSDrive -Name $existing.Name -Root $mdtSharePath -PSProvider MDTProvider -Scope Global
}

function Get-MDTDeploymentShareRootFolder {
    <#
    .SYNOPSIS
    Gets MDT deployment share root folder.

    .DESCRIPTION
    This function returns MDT deployment share root folder.

    .PARAMETER Module
    The Ansible module.

    .EXAMPLE
    Get-MDTDeploymentShare -Module $Module -MDTDrive $MDTDrive

    .OUTPUTS
    Microsoft.BDD.PSSnapIn.MDTObject
    #>

    [OutputType([Microsoft.BDD.PSSnapIn.MDTObject])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [AllowNull()]
        [System.Management.Automation.PSDriveInfo]$MDTDrive
    )

    process {

        if ($null -eq $MDTDrive) {
            return $null
        }

        $rootFolder = Get-Item -LiteralPath "$($MDTDrive.Name):\" -ErrorAction SilentlyContinue |
            Where-Object { $_.GetType() -eq [Microsoft.BDD.PSSnapIn.MDTObject] -and $_.NodeType -eq "RootFolder" }

        return $rootFolder
    }
}

function Format-MDTDeploymentShare {
    <#
    .SYNOPSIS
    Formats an MDT deployment share root folder to a custom object.

    .DESCRIPTION
    This function formats MDT deployment share root folder objects into a custom object.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER DeploymentShare
    The MDT deployment share to convert.
    These should be an Microsoft.BDD.PSSnapIn.MDTObject object that represents an MDT deployment share root folder.

    .EXAMPLE
    Format-MDTDeploymentShare -DeploymentShare $DeploymentShare

    .OUTPUTS
    System.Collections.Hashtable
    #>

    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [AllowNull()]
        [Microsoft.BDD.PSSnapIn.MDTObject]$DeploymentShare,
        [switch]$IncludeDescription,
        [switch]$IncludeUNCPath,
        [switch]$IncludeMonitor,
        [switch]$IncludeDatabase,
        [switch]$IncludeHiddenProperties
    )

    process {

        if ($null -eq $DeploymentShare -or $DeploymentShare.NodeType -ne "RootFolder") {
            return $null
        }

        $formattedDeploymentShare = @{
            comments = $DeploymentShare.Item("Comments")
            enable_multicast = [bool]::Parse($DeploymentShare.Item("EnableMulticast"))
            x86 = $DeploymentShare | Format-MDTDeploymentShareArchitectureConfig `
                -EnabledProperty "SupportX86" `
                -PropertyPrefix "Boot.x86" `
                -IncludeHiddenProperties:$IncludeHiddenProperties
            x64 = $DeploymentShare | Format-MDTDeploymentShareArchitectureConfig `
                -EnabledProperty "SupportX64" `
                -PropertyPrefix "Boot.x64" `
                -IncludeHiddenProperties:$IncludeHiddenProperties
        }

        if ($IncludeDescription) {
            $formattedDeploymentShare.description = $DeploymentShare.Item("Description")
        }

        if ($IncludeUNCPath) {
            $formattedDeploymentShare.unc_path = $DeploymentShare.Item("UNCPath")
        }

        if ($IncludeMonitor) {
            $formattedDeploymentShare.monitor = $DeploymentShare |
                Format-MDTDeploymentShareMonitorConfig -IncludeHiddenProperties:$IncludeHiddenProperties
        }

        if ($IncludeDatabase) {
            $formattedDeploymentShare.database = $DeploymentShare |
                Format-MDTDeploymentShareDatabaseConfig -IncludeHiddenProperties:$IncludeHiddenProperties
        }

        return $formattedDeploymentShare
    }
}

function Format-MDTDeploymentShareDatabaseConfig {
    <#
    .SYNOPSIS
    Formats an MDT deployment share database configuration to a custom object.

    .DESCRIPTION
    This function formats MDT deployment share database configuration objects into a custom object.

    .PARAMETER DeploymentShare
    The MDT deployment share to convert.

    .PARAMETER IncludeInvalidParameters
    Include invalid parameters.

    .EXAMPLE
    Format-MDTDeploymentShareDatabaseConfig -DeploymentShare $DeploymentShare

    .OUTPUTS
    System.Collections.Hashtable
    #>

    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [AllowNull()]
        [Microsoft.BDD.PSSnapIn.MDTObject]$DeploymentShare,
        [switch]$IncludeHiddenProperties
    )

    process {

        if ($null -eq $DeploymentShare -or $DeploymentShare.NodeType -ne "RootFolder") {
            return $null
        }

        if (-not [string]::IsNullOrWhiteSpace($DeploymentShare.Item("Database.SQLServer"))) {

            $formattedDatabase = @{
                enabled = $true
                sql_server = $DeploymentShare.Item("Database.SQLServer")
            }

            if (-not [string]::IsNullOrWhiteSpace($DeploymentShare.Item("Database.Instance"))) {
                $formattedDatabase.instance = $DeploymentShare.Item("Database.Instance")
            }

            if (-not [string]::IsNullOrWhiteSpace($DeploymentShare.Item("Database.Port"))) {
                $formattedDatabase.port = [int]::Parse($DeploymentShare.Item("Database.Port"))
            }

            if (-not [string]::IsNullOrWhiteSpace($DeploymentShare.Item("Database.Netlib"))) {
                $formattedDatabase.netlib = $DeploymentShare.Item("Database.Netlib")
            }

            if (-not [string]::IsNullOrWhiteSpace($DeploymentShare.Item("Database.Name"))) {
                $formattedDatabase.name = $DeploymentShare.Item("Database.Name")
            }

            if (-not [string]::IsNullOrWhiteSpace($DeploymentShare.Item("Database.SQLShare"))) {
                $formattedDatabase.sql_share = $DeploymentShare.Item("Database.SQLShare")
            }
        }
        else {
            $formattedDatabase = @{
                enabled = $false
            }

            if ($IncludeHiddenProperties) {

                if (-not [string]::IsNullOrWhiteSpace($DeploymentShare.Item("Database.Instance"))) {
                    $formattedDatabase.instance = $DeploymentShare.Item("Database.Instance")
                }

                if (-not [string]::IsNullOrWhiteSpace($DeploymentShare.Item("Database.Port"))) {
                    $formattedDatabase.port = [int]::Parse($DeploymentShare.Item("Database.Port"))
                }

                if (-not [string]::IsNullOrWhiteSpace($DeploymentShare.Item("Database.Netlib"))) {
                    $formattedDatabase.netlib = $DeploymentShare.Item("Database.Netlib")
                }

                if (-not [string]::IsNullOrWhiteSpace($DeploymentShare.Item("Database.Name"))) {
                    $formattedDatabase.name = $DeploymentShare.Item("Database.Name")
                }

                if (-not [string]::IsNullOrWhiteSpace($DeploymentShare.Item("Database.SQLShare"))) {
                    $formattedDatabase.sql_share = $DeploymentShare.Item("Database.SQLShare")
                }
            }
        }

        return $formattedDatabase
    }
}

function Format-MDTDeploymentShareMonitorConfig {
    <#
    .SYNOPSIS
    Formats an MDT deployment share monitor configuration to a custom object.

    .DESCRIPTION
    This function formats MDT deployment share monitor configuration objects into a custom object.

    .PARAMETER DeploymentShare
    The MDT deployment share to convert.

    .PARAMETER IncludeInvalidParameters
    Include invalid parameters.

    .EXAMPLE
    Format-MDTDeploymentShareMonitorConfig -DeploymentShare $DeploymentShare

    .OUTPUTS
    System.Collections.Hashtable
    #>

    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [AllowNull()]
        [Microsoft.BDD.PSSnapIn.MDTObject]$DeploymentShare,
        [switch]$IncludeHiddenProperties
    )

    process {

        if ($null -eq $DeploymentShare -or $DeploymentShare.NodeType -ne "RootFolder") {
            return $null
        }

        if (-not [string]::IsNullOrWhiteSpace(($DeploymentShare.Item("MonitorHost"))) -or $IncludeHiddenProperties) {
            $formattedMonitor = @{
                enabled = $true
                host = $DeploymentShare.Item("MonitorHost")
                event_port = [int]::Parse($DeploymentShare.Item("MonitorEventPort"))
                data_port = [int]::Parse($DeploymentShare.Item("MonitorDataPort"))
            }
        }
        else {
            $formattedMonitor = @{
                enabled = $false
            }
        }

        return $formattedMonitor
    }
}

function Format-MDTDeploymentShareArchitectureConfig {
    <#
    .SYNOPSIS
    Formats an MDT deployment share architecture configuration to a custom object.

    .DESCRIPTION
    This function formats MDT deployment share architecture configuration objects into a custom object.

    .PARAMETER DeploymentShare
    The MDT deployment share to convert.

    .PARAMETER Prefix
    The prefix to use for the architecture configuration.

    .PARAMETER IncludeInvalidParameters
    Include invalid parameters.
    #>

    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [Microsoft.BDD.PSSnapIn.MDTObject]$DeploymentShare,
        [Parameter(Mandatory = $true)]
        [string]$EnabledProperty,
        [Parameter(Mandatory = $true)]
        [string]$PropertyPrefix,
        [switch]$IncludeHiddenProperties
    )

    process {

        $architecture = @{
            enabled = [bool]::Parse($DeploymentShare.Item($EnabledProperty))
        }

        if ($architecture.enabled -or $IncludeHiddenProperties) {

            $architecture.background_file = $DeploymentShare.Item("$($PropertyPrefix).BackgroundFile")
            $architecture.extra_directory = $DeploymentShare.Item("$($PropertyPrefix).ExtraDirectory")
            $architecture.generic_iso = $DeploymentShare |
                Format-MDTDeploymentShareGenericIsoConfig -PropertyPrefix $PropertyPrefix -IncludeHiddenProperties:$IncludeHiddenProperties
            $architecture.generic_wim = $DeploymentShare |
                Format-MDTDeploymentShareGenericWimConfig -PropertyPrefix $PropertyPrefix -IncludeHiddenProperties:$IncludeHiddenProperties
            $architecture.litetouch_iso = $DeploymentShare |
                Format-MDTDeploymentShareLiteTouchIsoConfig -PropertyPrefix $PropertyPrefix -IncludeHiddenProperties:$IncludeHiddenProperties
            $architecture.litetouch_wim = @{
                description = $DeploymentShare.Item("$($PropertyPrefix).LiteTouchWIMDescription")
            }
            $architecture.scratch_space = [int]::Parse($DeploymentShare.Item("$($PropertyPrefix).ScratchSpace"))
            $architecture.selection_profile = $DeploymentShare.Item("$($PropertyPrefix).SelectionProfile")

            if ([bool]::Parse($DeploymentShare.Item("$($PropertyPrefix).IncludeAllDrivers"))) {
                $architecture.include_drivers = [string[]]@("all")
            }
            else {

                $includedX86Drivers = New-Object -TypeName System.Collections.ArrayList

                if ([bool]::Parse($DeploymentShare.Item("$($PropertyPrefix).IncludeMassStorageDrivers"))) {
                    $includedX86Drivers.Add("mass_storage") | Out-Null
                }

                if ([bool]::Parse($DeploymentShare.Item("$($PropertyPrefix).IncludeNetworkDrivers"))) {
                    $includedX86Drivers.Add("network") | Out-Null
                }

                if ([bool]::Parse($DeploymentShare.Item("$($PropertyPrefix).IncludeSystemDrivers"))) {
                    $includedX86Drivers.Add("system") | Out-Null
                }

                if ([bool]::Parse($DeploymentShare.Item("$($PropertyPrefix).IncludeVideoDrivers"))) {
                    $includedX86Drivers.Add("video") | Out-Null
                }

                $architecture.include_drivers = [string[]]$includedX86Drivers.ToArray()
            }

            if ([string]::IsNullOrWhiteSpace($DeploymentShare.Item("$($PropertyPrefix).FeaturePacks"))) {
                $architecture.feature_packs = [string[]]@()
            }
            else {
                $architecture.feature_packs = [string[]]$DeploymentShare.Item("$($PropertyPrefix).FeaturePacks").Split(",")
            }
        }

        return $architecture
    }
}

function Format-MDTDeploymentShareGenericWimConfig {
    <#
    .SYNOPSIS
    Formats an MDT deployment share generic WIM configuration to a custom object.

    .DESCRIPTION
    This function formats MDT deployment share generic WIM configuration objects into a custom object.

    .PARAMETER DeploymentShare
    The MDT deployment share to convert.

    .PARAMETER PropertyPrefix
    The prefix to use for the generic WIM configuration.

    .PARAMETER IncludeInvalidParameters
    Include invalid parameters.

    .EXAMPLE
    Format-MDTDeploymentShareGenericWimConfig -DeploymentShare $DeploymentShare -PropertyPrefix "Boot.x86"

    .OUTPUTS
    System.Collections.Hashtable
    #>

    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [Microsoft.BDD.PSSnapIn.MDTObject]$DeploymentShare,
        [Parameter(Mandatory = $true)]
        [string]$PropertyPrefix,
        [switch]$IncludeHiddenProperties
    )

    process {

        $genericWim = @{
            enabled = [bool]::Parse($DeploymentShare.Item("$($PropertyPrefix).GenerateGenericWIM"))
        }

        if ($genericWim.enabled -or $IncludeHiddenProperties) {
            $genericWim.description = $DeploymentShare.Item("$($PropertyPrefix).GenericWIMDescription")
        }

        return $genericWim
    }
}

function Format-MDTDeploymentShareGenericIsoConfig {
    <#
    .SYNOPSIS
    Formats an MDT deployment share generic ISO configuration to a custom object.

    .DESCRIPTION
    This function formats MDT deployment share generic ISO configuration objects into a custom object.

    .PARAMETER DeploymentShare
    The MDT deployment share to convert.

    .PARAMETER PropertyPrefix
    The prefix to use for the generic ISO configuration.

    .PARAMETER IncludeInvalidParameters
    Include invalid parameters.

    .EXAMPLE
    Format-MDTDeploymentShareGenericIsoConfig -DeploymentShare $DeploymentShare -PropertyPrefix "Boot.x86"

    .OUTPUTS
    System.Collections.Hashtable
    #>

    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [Microsoft.BDD.PSSnapIn.MDTObject]$DeploymentShare,
        [Parameter(Mandatory = $true)]
        [string]$PropertyPrefix,
        [switch]$IncludeHiddenProperties
    )

    process {

        if ([bool]::Parse($DeploymentShare.Item("$($PropertyPrefix).GenerateGenericWIM"))) {
            $genericIso = @{
                enabled = [bool]::Parse($DeploymentShare.Item("$($PropertyPrefix).GenerateGenericISO"))
            }
        }
        else {
            $genericIso = @{
                enabled = $false
            }
        }

        if ($genericIso.enabled -or $IncludeHiddenProperties) {
            $genericIso.name = $DeploymentShare.Item("$($PropertyPrefix).GenericISOName")
        }

        return $genericIso
    }
}

function Format-MDTDeploymentShareLiteTouchIsoConfig {
    <#
    .SYNOPSIS
    Formats an MDT deployment share Lite Touch ISO configuration to a custom object.

    .DESCRIPTION
    This function formats MDT deployment share Lite Touch ISO configuration objects into a custom object.

    .PARAMETER DeploymentShare
    The MDT deployment share to convert.

    .PARAMETER PropertyPrefix
    The prefix to use for the Lite Touch ISO configuration.

    .PARAMETER IncludeInvalidParameters
    Include invalid parameters.

    .EXAMPLE
    Format-MDTDeploymentShareLiteTouchIsoConfig -DeploymentShare $DeploymentShare -PropertyPrefix "Boot.x86"

    .OUTPUTS
    System.Collections.Hashtable
    #>

    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [Microsoft.BDD.PSSnapIn.MDTObject]$DeploymentShare,
        [Parameter(Mandatory = $true)]
        [string]$PropertyPrefix,
        [switch]$IncludeHiddenProperties
    )

    process {

        $litetouchIso = @{
            enabled = [bool]::Parse($DeploymentShare.Item("$($PropertyPrefix).GenerateLiteTouchISO"))
        }

        if ($litetouchIso.enabled -or $IncludeHiddenProperties) {
            $litetouchIso.name = $DeploymentShare.Item("$($PropertyPrefix).LiteTouchISOName")
        }

        return $litetouchIso
    }
}

$exportMembers = @{
    Function = 'Get-MDTDeploymentShareDrive', `
        'Get-MDTDeploymentShareRootFolder', `
        'Format-MDTDeploymentShare', `
        'Format-MDTDeploymentShareDatabaseConfig', `
        'Format-MDTDeploymentShareMonitorConfig'
}

Export-ModuleMember @exportMembers
