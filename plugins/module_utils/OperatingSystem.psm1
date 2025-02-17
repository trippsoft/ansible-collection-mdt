function Get-MDTOperatingSystem {
    <#
    .SYNOPSIS
    Gets MDT operating system objects.

    .DESCRIPTION
    This function returns MDT operating systems within the MDT share that match the supplied criteria.
    Each object returned represents a path at which an operating system is found.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The MDT drive name.

    .PARAMETER Guid
    The GUID of the MDT operating system.

    .PARAMETER Name
    The name of the MDT operating system.

    .EXAMPLE
    Get-MDTOperatingSystem -Module $Module -MDTDriveName "DS001"

    This example gets all MDT operating systems within the MDT share with the drive name "DS001".

    .EXAMPLE
    Get-MDTOperatingSystem -Module $Module -MDTDriveName "DS001" -Guid "{12345678-1234-1234-1234-123456789012}"

    This example gets all paths of an MDT operating system with the GUID "{12345678-1234-1234-1234-123456789012}" within the MDT share with
    the drive name "DS001".

    .EXAMPLE
    Get-MDTOperatingSystem -Module $Module -MDTDriveName "DS001" -Name "Operating System Name"

    This example gets all paths of an MDT operating system with the name "Operating System Name" within the MDT share with the drive name "DS001".

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

    $operatingSystems = Get-ChildItem -LiteralPath "$($MDTDriveName):\Operating Systems" -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.GetType() -eq [Microsoft.BDD.PSSnapIn.MDTObject] -and $_.NodeType -eq "OperatingSystem" }

    if (-not [string]::IsNullOrEmpty($Guid)) {

        $guidMatch = $operatingSystems | Where-Object { $_.guid -ieq $Guid }

        if ($null -ne $guidMatch) {
            return $guidMatch
        }

        if (-not [string]::IsNullOrEmpty($Name)) {

            $nameMatch = $operatingSystems | Where-Object { $_.Name -eq $Name }

            if ($null -ne $nameMatch) {
                $Module.FailJson("No MDT operating system found with GUID '$($Guid)' but operating system named '$($Name)' already exists.")
            }
        }

        return $null
    }

    if (-not [string]::IsNullOrEmpty($Name)) {
        return $operatingSystems | Where-Object { $_.Name -eq $Name }
    }

    return $operatingSystems
}

function Format-MDTOperatingSystem {
    <#
    .SYNOPSIS
    Formats an MDT operating system to a custom object.

    .DESCRIPTION
    This function formats MDT operating system objects into a custom object.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The MDT drive name.

    .PARAMETER OperatingSystem
    The MDT operating system to convert.
    These should be Microsoft.BDD.PSSnapIn.MDTObject objects representing the same operating system.
    The first operating system in the array will be used to determine the shared properties.
    The path of each operating system will be added to the 'paths' property of the formatted custom object.

    .EXAMPLE
    Format-MDTOperatingSystem -Module $Module -MDTDriveName "DS001" -OperatingSystem $OperatingSystem

    This example converts an array of MDT operating systems into a formatted custom object within the MDT share with the drive name "DS001".

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
        [Microsoft.BDD.PSSnapIn.MDTObject]$OperatingSystem,
        [Switch]$ExcludePaths,
        [Switch]$IncludeFiles
    )

    begin {
        $pathPrefix = "MicrosoftDeploymentToolkit\MDTProvider::$($MDTDriveName):\Operating Systems"
        $formattedOperatingSystems = New-Object -TypeName System.Collections.Generic.List[System.Collections.Hashtable]
    }

    process {

        if ($null -eq $OperatingSystem) {
            return
        }

        $existingOperatingSystem = $formattedOperatingSystems | Where-Object { $_.guid -eq $OperatingSystem.guid }

        if ($null -ne $existingOperatingSystem) {

            if ($ExcludePaths) {
                return
            }

            $path = $OperatingSystem.PSParentPath -replace [regex]::Escape($pathPrefix), ""
            $path = $path.Trim('\')

            $existingOperatingSystem.paths = [string[]] @( $existingOperatingSystem.paths; @($path))

            return
        }

        $formattedOperatingSystem = @{
            guid = $OperatingSystem.guid
            name = $OperatingSystem.Name
            build = $OperatingSystem.Build
            description = $OperatingSystem.Description
            flags = $OperatingSystem.Flags
            hal = $OperatingSystem.HAL
            image_file = $OperatingSystem.ImageFile
            image_index = [int]::Parse($OperatingSystem.ImageIndex)
            image_name = $OperatingSystem.ImageName
            languages = [string[]]$OperatingSystem.Language
            os_type = $OperatingSystem.OSType
            platform = $OperatingSystem.Platform
            size = [int]::Parse($OperatingSystem.Size)
            sms_image = [bool]::Parse($OperatingSystem.SMSImage)
            files_path = $OperatingSystem.Source -replace '^\.', $Module.Params.mdt_share_path
        }

        if ([bool]::Parse($OperatingSystem.IncludesSetup)) {
            $formattedOperatingSystem.type = "source"
        }
        else {
            $formattedOperatingSystem.type = "wim"
        }

        if ($OperatingSystem.Comments.GetType() -eq [System.DBNull]) {
            $formattedOperatingSystem.comments = ""
        }
        else {
            $formattedOperatingSystem.comments = $OperatingSystem.Comments
        }

        if ($OperatingSystem.enable.GetType() -eq [System.DBNull]) {
            $formattedOperatingSystem.enabled = $true
        }
        else {
            $formattedOperatingSystem.enabled = [bool]::Parse($OperatingSystem.enable)
        }

        if ($OperatingSystem.hide.GetType() -eq [System.DBNull]) {
            $formattedOperatingSystem.hidden = $false
        }
        else {
            $formattedOperatingSystem.hidden = [bool]::Parse($OperatingSystem.hide)
        }

        if (-not $ExcludePaths) {
            $path = $OperatingSystem.PSParentPath -replace [regex]::Escape($pathPrefix), ""
            $path = $path.Trim('\')
            $formattedOperatingSystem.paths = [string[]] @($path)
        }

        if ($IncludeFiles) {
            $files = [Array](Format-MDTFilesValue -DirectoryPath $formattedOperatingSystem.files_path)

            if ($null -ne $files) {
                $formattedOperatingSystem.files = $files
            }
            else {
                $formattedOperatingSystem.files = @()
            }
        }

        $formattedOperatingSystems.Add($formattedOperatingSystem)
    }

    end {
        return [System.Collections.Hashtable[]] $formattedOperatingSystems.ToArray()
    }
}

function Get-WimImage {

    [OutputType([Microsoft.Dism.Commands.WimImageInfoObject[]])]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ImagePath,
        [Parameter(Mandatory = $false)]
        [int]$ImageIndex,
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [string]$ImageName,
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [string]$ImageEditionId
    )

    if ($null -ne $ImageIndex -and $ImageIndex -gt 0) {
        return Get-WindowsImage -ImagePath $ImagePath -Index $ImageIndex -ErrorAction SilentlyContinue
    }

    if (-not [string]::IsNullOrEmpty($ImageName)) {
        return Get-WindowsImage -ImagePath $ImagePath -Name $ImageName -ErrorAction SilentlyContinue
    }

    if (-not [string]::IsNullOrEmpty($ImageEditionId)) {

        $basicImages = [Array](Get-WindowsImage -ImagePath $ImagePath)

        foreach ($basicImage in $basicImages) {

            $image = Get-WindowsImage -ImagePath $ImagePath -Index $basicImage.ImageIndex

            if ($image.EditionId -eq $ImageEditionId) {
                return $image
            }
        }

        return $null
    }

    throw "An image index, image name, or image edition ID must be specified."
}

function Confirm-WimImageIsValid {

    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [string]$ImagePath
    )

    if (-not (Test-Path -LiteralPath $ImagePath -PathType Leaf)) {
        $Module.FailJson("The image file '$($ImagePath)' does not exist.")
    }

    try {
        $basicImages = Get-WindowsImage -ImagePath $ImagePath
    }
    catch {
        $Module.FailJson("The image file '$($ImagePath)' is not a valid WIM file.", $_.Exception)
    }

    if ($null -eq $basicImages) {
        $Module.FailJson("The image file '$($ImagePath)' does not contain any images.")
    }
}

$exportMembers = @{
    Function = 'Get-MDTOperatingSystem', `
        'Format-MDTOperatingSystem', `
        'Get-WimImage', `
        'Confirm-WimImageIsValid'
}

Export-ModuleMember @exportMembers
