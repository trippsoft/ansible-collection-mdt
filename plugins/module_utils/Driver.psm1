function Get-MDTDriver {
    <#
    .SYNOPSIS
    Gets MDT driver objects.

    .DESCRIPTION
    This function returns MDT drivers within the MDT share that match the supplied criteria.
    Each object returned represents a path at which an driver is found.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The MDT drive name.

    .PARAMETER Guid
    The GUID of the MDT driver.

    .PARAMETER Name
    The name of the MDT driver.

    .EXAMPLE
    Get-MDTDriver -Module $Module -MDTDriveName "DS001"

    This example gets all MDT drivers within the MDT share with the drive name "DS001".

    .EXAMPLE
    Get-MDTDriver -Module $Module -MDTDriveName "DS001" -Guid "{12345678-1234-1234-1234-123456789012}"

    This example gets all paths of an MDT driver with the GUID "{12345678-1234-1234-1234-123456789012}" within the MDT share with the drive name "DS001".

    .EXAMPLE
    Get-MDTDriver -Module $Module -MDTDriveName "DS001" -Name "Intel(R) Ethernet Connection I219-LM"

    This example gets all paths of an MDT driver with the name "Intel(R) Ethernet Connection I219-LM" within the MDT share with the drive name "DS001".

    .OUTPUTS
    Microsoft.BDD.PSSnapIn.MDTObject[]
    #>

    [OutputType([Microsoft.BDD.PSSnapIn.MDTObject[]])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [string]$MDTDriveName,
        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]$Guid,
        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]$Name
    )

    $drivers = Get-ChildItem -LiteralPath "$($MDTDriveName):\Out-of-Box Drivers" -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.GetType() -eq [Microsoft.BDD.PSSnapIn.MDTObject] -and $_.NodeType -eq "Driver" }

    if ( -not [string]::IsNullOrEmpty($Guid)) {

        $guidMatch = $drivers | Where-Object { $_.guid -ieq $Guid }

        if ($null -ne $guidMatch) {
            return $guidMatch
        }

        if (-not [string]::IsNullOrEmpty($Name)) {

            $nameMatch = $drivers | Where-Object { $_.Name -eq $Name }

            if ($null -ne $nameMatch) {
                $Module.FailJson("No MDT driver found with GUID '$($Guid)' but driver named '$($Name)' already exists.")
            }
        }

        return $null
    }

    if ( -not [string]::IsNullOrEmpty($Name)) {
        return $drivers | Where-Object { $_.Name -eq $Name }
    }

    return $drivers
}

function Format-MDTDriver {
    <#
    .SYNOPSIS
    Formats an MDT driver to a custom object.

    .DESCRIPTION
    This function formats MDT driver objects into a custom object.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The MDT drive name.

    .PARAMETER Driver
    The MDT driver to convert.
    These should be Microsoft.BDD.PSSnapIn.MDTObject objects representing the same driver.
    The first driver in the array will be used to determine the shared properties.
    The path of each driver will be added to the 'paths' property of the formatted custom object.

    .EXAMPLE
    Format-MDTDriver -Module $Module -MDTDriveName "DS001" -Drivers $Drivers

    This example converts an array of MDT drivers into a formatted custom object within the MDT share with the drive name "DS001".

    .OUTPUTS
    System.Collections.Hashtable
    #>

    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [string]$MDTDriveName,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [AllowNull()]
        [Microsoft.BDD.PSSnapIn.MDTObject]$Driver,
        [Switch]$ExcludePaths
    )

    begin {
        $pathPrefix = "MicrosoftDeploymentToolkit\MDTProvider::$($MDTDriveName):\Out-of-Box Drivers"
        $formattedDrivers = New-Object -TypeName System.Collections.Generic.List[System.Collections.Hashtable]
    }

    process {

        if ($null -eq $Driver) {
            return
        }

        $existingDriver = $formattedDrivers | Where-Object { $_.guid -eq $Driver.guid }

        if ($null -ne $existingDriver) {

            if ($ExcludePaths) {
                return
            }

            $path = $Driver.PSParentPath -replace [regex]::Escape($pathPrefix), ""
            $path = $path.Trim('\')

            $existingDriver.paths = [string[]] @( $existingDriver.paths; @($path))

            return
        }

        $formattedDriver = @{
            guid = $driver.guid
            name = $driver.Name
            class = $driver.Class
            hash = $driver.Hash
            manufacturer = $driver.Manufacturer
            os_version = [string[]]$driver.OSVersion
            platform = [string[]]$driver.Platform
            pnp_ids = [string[]]$driver.PnPID
            files_path = $driver.Source -replace '^\.', $mdtSharePath
            version = $driver.Version
            whql_signed = [bool]::Parse($driver.WHQLSigned)
        }

        if ($driver.comments.GetType() -eq [System.DBNull]) {
            $formattedDriver['comments'] = ""
        }
        else {
            $formattedDriver['comments'] = $driver.Comments
        }

        if ($driver.enable.GetType() -eq [System.DBNull]) {
            $formattedDriver['enabled'] = $true
        }
        else {
            $formattedDriver['enabled'] = [bool]::Parse($driver.enable)
        }

        if ($driver.hide.GetType() -eq [System.DBNull]) {
            $formattedDriver['hidden'] = $false
        }
        else {
            $formattedDriver['hidden'] = [bool]::Parse($driver.hide)
        }

        if (-not $ExcludePaths) {
            $path = $Driver.PSParentPath -replace [regex]::Escape($pathPrefix), ""
            $path = $path.Trim('\')
            $formattedDriver["paths"] = [string[]] @($path)
        }

        $formattedDrivers.Add($formattedDriver)
    }

    end {
        return [System.Collections.Hashtable[]] $formattedDrivers.ToArray()
    }
}

function Convert-MDTDriver {
    <#
    .SYNOPSIS
    Convert an MDT driver to a System.Collections.Hashtable.

    .DESCRIPTION
    This function converts an MDT driver to a formatted custom object.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The name of the MDT drive from which the driver is retrieved.

    .PARAMETER Drivers
    The MDT drivers to convert.
    These should be Microsoft.BDD.PSSnapIn.MDTObject objects representing the same driver.
    The first driver in the array will be used to determine the shared properties.
    The path of each driver will be added to the 'paths' property of the formatted custom object.

    .EXAMPLE
    Convert-MDTDriver -Module $Module -MDTDriveName "DS001" -Drivers $drivers

    This example converts the MDT drivers in the $drivers array to formatted custom objects.

    .OUTPUTS
    System.Collections.Hashtable
    #>

    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [string]$MDTDriveName,
        [Parameter(Mandatory = $true)]
        [Microsoft.BDD.PSSnapIn.MDTObject[]]$Drivers
    )

    $mdtSharePath = $Module.Params.mdt_share_path

    $driver = $Drivers[0]

    $formattedDriver = @{
        guid = $driver.guid
        name = $driver.Name
        class = $driver.Class
        hash = $driver.Hash
        manufacturer = $driver.Manufacturer
        os_version = [string[]]$driver.OSVersion
        platform = [string[]]$driver.Platform
        pnp_ids = [string[]]$driver.PnPID
        files_path = $driver.Source -replace '^\.', $mdtSharePath
        version = $driver.Version
        whql_signed = [bool]::Parse($driver.WHQLSigned)
    }

    if ($driver.comments.GetType() -eq [System.DBNull]) {
        $formattedDriver['comments'] = ""
    }
    else {
        $formattedDriver['comments'] = $driver.Comments
    }

    if ($driver.enable.GetType() -eq [System.DBNull]) {
        $formattedDriver['enabled'] = $true
    }
    else {
        $formattedDriver['enabled'] = [bool]::Parse($driver.enable)
    }

    if ($driver.hide.GetType() -eq [System.DBNull]) {
        $formattedDriver['hidden'] = $false
    }
    else {
        $formattedDriver['hidden'] = [bool]::Parse($driver.hide)
    }

    $paths = New-Object -TypeName System.Collections.ArrayList

    foreach ($driver in $Drivers) {

        $path = $driver.PSParentPath -replace [regex]::Escape("MicrosoftDeploymentToolkit\MDTProvider::$($MDTDriveName):\Out-of-Box Drivers\"), ""
        $paths.Add($path) | Out-Null
    }

    $formattedDriver['paths'] = [string[]]$paths.ToArray()

    return $formattedDriver
}

$exportMembers = @{
    Function = 'Get-MDTDriver', `
        'Format-MDTDriver'
}

Export-ModuleMember @exportMembers
