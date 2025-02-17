#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.Common
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.OperatingSystem

function Confirm-OperatingSystemParamsAreValid {
    <#
    .SYNOPSIS
    Confirms that the parameters are valid.

    .DESCRIPTION
    This function confirms that the parameters are valid.

    .PARAMETER Module
    The Ansible module.

    .EXAMPLE
    Confirm-OperatingSystemParamsAreValid -Module $module
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [Ansible.Basic.AnsibleModule]$Module
    )

    process {
        $Module.Params.mdt_share_path = $Module.Params.mdt_share_path.TrimEnd("\")
        $Module.Params.name | Confirm-NameIsValid -Module $Module -ParameterName "name" | Out-Null
        $Module.Params.guid = $Module.Params.guid | Format-MDTGuid -Module $Module
    }
}

function Confirm-OperatingSystemAbsentParamsAreValid {
    <#
    .SYNOPSIS
    Confirms that the parameters are valid for the module when the state is 'absent'.

    .DESCRIPTION
    This function confirms that the parameters are valid for the module when the state is 'absent'.

    .PARAMETER Module
    The module object.

    .EXAMPLE
    Confirm-OperatingSystemAbsentParamsAreValid -Module $Module
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

        if ($null -ne $Module.Params.paths) {
            $invalidParams.Add("paths") | Out-Null
        }

        if ($null -ne $Module.Params.type) {
            $invalidParams.Add("type") | Out-Null
        }

        if ($null -ne $Module.Params.source_path) {
            $invalidParams.Add("source_path") | Out-Null
        }

        if ($null -ne $Module.Params.destination_folder) {
            $invalidParams.Add("destination_folder") | Out-Null
        }

        if ($null -ne $Module.Params.image_index) {
            $invalidParams.Add("image_index") | Out-Null
        }

        if ($null -ne $Module.Params.image_name) {
            $invalidParams.Add("image_name") | Out-Null
        }

        if ($null -ne $Module.Params.image_edition_id) {
            $invalidParams.Add("image_edition_id") | Out-Null
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

function Confirm-OperatingSystemPresentParamsAreValid {
    <#
    .SYNOPSIS
    Confirms that the parameters are valid for the module when the state is 'present'.

    .DESCRIPTION
    This function confirms that the parameters are valid for the module when the state is 'present'.

    .PARAMETER Module
    The module object.

    .EXAMPLE
    Confirm-OperatingSystemPresentParamsAreValid -Module $Module
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [string]$MDTDriveName,
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Collections.Hashtable]$Existing
    )

    process {

        $paths = $Module.Params.paths

        $Module.Params.destination_folder | Confirm-MDTPathSegmentIsValid -Module $Module -ParameterName "destination_folder" | Out-Null

        if ($null -ne $paths) {

            $addPaths = $paths.add
            $removePaths = $paths.remove
            $setPaths = $paths.set

            if ($null -ne $addPaths) {

                if ($addPaths.Count -eq 0) {
                    $Module.FailJson("The 'paths.add' parameter must contain at least one path, if provided.")
                }

                for ($i = 0; $i -lt $addPaths.Count; $i++) {

                    if ([string]::IsNullOrEmpty($addPaths[$i])) {
                        continue
                    }

                    $addPaths[$i] = $addPaths[$i] | Format-MDTPath

                    $addPaths[$i] |
                        Confirm-MDTPathIsValid -Module $Module -ParameterName "paths.add[$($i)]" |
                        Out-Null

                    if (-not (Test-Path -LiteralPath "$($MDTDriveName):\Operating Systems\$($addPaths[$i])" -PathType Container)) {
                        $Module.FailJson("The directory 'Operating Systems\$($addPaths[$i])' does not exist in the MDT share.")
                    }
                }
            }

            if ($null -ne $removePaths) {

                if ($removePaths.Count -eq 0) {
                    $Module.FailJson("The 'paths.remove' parameter must contain at least one path, if provided.")
                }

                for ($i = 0; $i -lt $removePaths.Count; $i++) {

                    if ([string]::IsNullOrEmpty($removePaths[$i])) {
                        continue
                    }

                    $removePaths[$i] = $removePaths[$i] | Format-MDTPath

                    $removePaths[$i] |
                        Confirm-MDTPathIsValid -Module $Module -ParameterName "paths.remove[$($i)]" |
                        Out-Null

                    if (-not (Test-Path -LiteralPath "$($MDTDriveName):\Operating Systems\$($removePaths[$i])" -PathType Container)) {
                        $Module.FailJson("The directory 'Operating Systems\$($removePaths[$i])' does not exist in the MDT share.")
                    }
                }
            }

            if ($null -ne $addPaths -and $null -ne $removePaths) {

                $intersection = [Array]($addPaths | Where-Object { $removePaths -contains $_ })

                if ($intersection.Length -gt 0) {
                    $Module.FailJson("The 'paths.add' and 'paths.remove' parameters must not contain the same path(s).")
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

                    if (-not (Test-Path -LiteralPath "$($MDTDriveName):\Operating Systems\$($setPaths[$i])" -PathType Container)) {
                        $Module.FailJson("The directory 'Operating Systems\$($setPaths[$i])' does not exist in the MDT share.")
                    }
                }
            }
        }

        $Module | Confirm-OperatingSystemWimParamsIsValid | Out-Null
        $Module | Confirm-ExistingOperatingSystemsAreCompatible -MDTDriveName $MDTDriveName -Existing $Existing | Out-Null
    }
}

function Confirm-OperatingSystemWimParamsIsValid {
    <#
    .SYNOPSIS
    Confirms that the WIM image parameters are valid.

    .DESCRIPTION
    This function confirms that the WIM image parameters are valid.

    .PARAMETER Module
    The Ansible module.

    .EXAMPLE
    Confirm-OperatingSystemWimParamsIsValid -Module $module
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [Ansible.Basic.AnsibleModule]$Module
    )

    process {

        $type = $Module.Params.type
        $sourcePath = $Module.Params.source_path
        $imageIndex = $Module.Params.image_index
        $imageName = $Module.Params.image_name
        $imageEditionId = $Module.Params.image_edition_id

        if ($type -eq "source") {
            $sourceImagePath = "$($sourcePath)\sources\install.wim"
        }
        elseif ($type -eq "wim") {
            $imageExtension = [System.IO.Path]::GetExtension($sourcePath)

            if ($imageExtension -ne ".wim") {
                $Module.FailJson("The 'source_path' parameter must point to a .wim file when 'type' is 'wim'.")
            }

            $sourceImagePath = $sourcePath
        }

        Confirm-WimImageIsValid -Module $Module -ImagePath $sourceImagePath

        if ($null -ne $imageIndex -and $imageIndex -lt 1) {
            $Module.FailJson("The 'image_index' parameter must be greater than or equal to 1.")
        }

        $wimImage = Get-WimImage -ImagePath $sourceImagePath -ImageIndex $imageIndex -ImageName $imageName -ImageEditionId $imageEditionId

        if ($null -eq $wimImage) {

            if ($null -ne $imageIndex) {
                $Module.FailJson("There is no index '$($imageIndex)' in WIM file '$($sourceImagePath)'.")
            }

            if ($null -ne $imageName) {
                $Module.FailJson("There is no image named '$($imageName)' in WIM file '$($sourceImagePath)'.")
            }

            if ($null -ne $imageEditionId) {
                $Module.FailJson("There is no image with edition ID '$($imageEditionId)' in WIM file '$($sourceImagePath)'.")
            }
        }

        if ($wimImage.Architecture -ne 0 -and $wimImage.Architecture -ne 9) {
            $Module.FailJson("The image architecture must be 0 (x86) or 9 (x64).")
        }
    }
}

function Confirm-ExistingOperatingSystemsAreCompatible {

    [OutputType([System.Void])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [string]$MDTDriveName,
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Collections.Hashtable]$Existing
    )

    process {

        $type = $Module.Params.type
        $destinationFolder = $Module.Params.destination_folder
        $sourcePath = $Module.Params.source_path

        $expectedSource = ".\Operating Systems\$($destinationFolder)"

        if ($type -eq "source") {
            $sourceImagePath = "$($sourcePath)\sources\install.wim"
            $expectedImagePath = "$($expectedSource)\sources\install.wim"
        }
        elseif ($type -eq "wim") {
            $imageFileName = [System.IO.Path]::GetFileName($sourcePath)
            $sourceImagePath = $sourcePath
            $expectedImagePath = "$($expectedSource)\$($imageFileName)"
        }

        if ($null -eq $Existing) {
            $sameSourceOperatingSystems = Get-MDTOperatingSystem -Module $Module -MDTDriveName $MDTDriveName |
                Where-Object { $_.Source -eq $expectedSource } |
                Format-MDTOperatingSystem -Module $Module -MDTDriveName $MDTDriveName
        }
        else {
            $sameSourceOperatingSystems = Get-MDTOperatingSystem -Module $Module -MDTDriveName $MDTDriveName |
                Where-Object { $_.Source -eq $expectedSource -and $_.guid -ne $Existing.guid } |
                Format-MDTOperatingSystem -Module $Module -MDTDriveName $MDTDriveName
        }

        if ($null -eq $sameSourceOperatingSystems) {
            return
        }

        $differentTypeOperatingSystems = $sameSourceOperatingSystems |
            Where-Object { $_.type -ne $type }

        if ($null -ne $differentTypeOperatingSystems) {
            $operatingSystemNames = [Array]($differentTypeOperatingSystems | ForEach-Object { $_.name })
            $Module.FailJson("The following operating systems have the same source path but different types: $($operatingSystemNames -join ', ')")
        }

        $differentImagePathOperatingSystems = $sameSourceOperatingSystems |
            Where-Object { $_.image_file -ne $expectedImagePath }

        if ($null -ne $differentImagePathOperatingSystems) {
            $operatingSystemNames = [Array]($differentImagePathOperatingSystems | ForEach-Object { $_.name })
            $Module.FailJson("The following operating systems have the same source path but different image paths: $($operatingSystemNames -join ', ')")
        }

        $incompatibleOperatingSystemNames = New-Object -TypeName System.Collections.ArrayList

        foreach ($operatingSystem in $sameSourceOperatingSystems) {

            $wimImage = Get-WimImage -ImagePath $sourceImagePath -ImageIndex $operatingSystem.image_index -ImageName $null -ImageEditionId $null

            if ($null -eq $wimImage) {
                $incompatibleOperatingSystemNames.Add($operatingSystem.name) | Out-Null
            }

            if ($wimImage.ImageName -ne $operatingSystem.image_name) {
                $incompatibleOperatingSystemNames.Add($operatingSystem.name) | Out-Null
            }

            if ($wimImage.EditionId -ne $operatingSystem.flags) {
                $incompatibleOperatingSystemNames.Add($operatingSystem.name) | Out-Null
            }
        }

        if ($incompatibleOperatingSystemNames.Count -gt 0) {
            $Module.FailJson(
                "The following operating systems are not compatible with the new WIM file to be uploaded: $($incompatibleOperatingSystemNames -join ', ')")
        }
    }
}

function Get-ExpectedOperatingSystem {
    <#
    .SYNOPSIS
    Gets the expected MDT operating system.

    .DESCRIPTION
    This function gets the expected MDT operating system.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER Existing
    The existing operating system.

    .EXAMPLE
    Get-ExpectedOperatingSystem -Module $module -Existing $existing
    #>

    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Collections.Hashtable]$Existing
    )

    $type = $Module.Params.type
    $guid = $Module.Params.guid
    $sourcePath = $Module.Params.source_path
    $mdtSharePath = $Module.Params.mdt_share_path
    $destinationFolder = $Module.Params.destination_folder
    $imageIndex = $Module.Params.image_index
    $imageName = $Module.Params.image_name
    $imageEditionId = $Module.Params.image_edition_id
    $comments = $Module.Params.comments
    $enabled = $Module.Params.enabled
    $hidden = $Module.Params.hidden

    $filesPath = "$($mdtSharePath)\Operating Systems\$($destinationFolder)"

    if ($type -eq "source") {
        $sourceImagePath = "$($sourcePath)\sources\install.wim"
        $imageFile = ".\Operating Systems\$($destinationFolder)\sources\install.wim"
        $files = [System.Collections.Hashtable[]](Format-MDTFilesValue -DirectoryPath $sourcePath)
    }
    elseif ($type -eq "wim") {
        $sourceImagePath = $sourcePath
        $imageFileName = [System.IO.Path]::GetFileName($sourcePath)
        $imageFile = ".\Operating Systems\$($destinationFolder)\$($imageFileName)"

        $imageFileChecksum = Get-FileHash -LiteralPath $sourcePath -Algorithm SHA256

        $files = [System.Collections.Hashtable[]]@(
            @{
                path = $imageFileName
                sha256_checksum = $imageFileChecksum.Hash
            }
        )
    }

    $wimImage = Get-WimImage -ImagePath $sourceImagePath -ImageIndex $imageIndex -ImageName $imageName -ImageEditionId $imageEditionId
    $imageSize = [System.Math]::Floor([System.Math]::Round($wimImage.ImageSize / 1MB, 2))

    if ($wimImage.Architecture -eq 0) {
        $platform = "x86"
    }
    elseif ($wimImage.Architecture -eq 9) {
        $platform = "x64"
    }

    $expected = @{
        type = $type
        name = Get-ExpectedOperatingSystemNameValue -Module $Module -WimImage $wimImage -Existing $Existing
        build = $wimImage.Version
        description = $wimImage.ImageDescription
        flags = $wimImage.EditionId
        image_file = $imageFile
        image_index = [int]$wimImage.ImageIndex
        image_name = $wimImage.ImageName
        languages = [string[]]$wimImage.Languages.ToArray()
        os_type = "Windows IBS"
        platform = $platform
        size = [int]$imageSize
        sms_image = $false
        files_path = $filesPath
        paths = [string[]](Get-ExpectedOperatingSystemPathsValue -Module $Module -Existing $Existing)
        files = $files
    }

    if ($expected.paths.Length -eq 0) {
        $Module.FailJson("The 'paths' parameter would remove the operating system.")
    }

    if ($null -ne $guid) {
        $expected.guid = $guid
    }
    elseif ($null -ne $Existing) {
        $expected.guid = $Existing.guid
    }

    if ($null -ne $comments) {
        $expected.comments = $comments
    }
    elseif ($null -ne $Existing) {
        $expected.comments = $Existing.comments
    }
    else {
        $expected.comments = ""
    }

    if ($null -ne $enabled) {
        $expected.enabled = $enabled
    }
    elseif ($null -ne $Existing) {
        $expected.enabled = $Existing.enabled
    }
    else {
        $expected.enabled = $true
    }

    if ($null -ne $hidden) {
        $expected.hidden = $hidden
    }
    elseif ($null -ne $Existing) {
        $expected.hidden = $Existing.hidden
    }
    else {
        $expected.hidden = $false
    }

    if ($null -ne $wimImage.Hal) {
        $expected.hal = $wimImage.Hal
    }
    else {
        $expected.hal = ""
    }

    return $expected
}

function Get-ExpectedOperatingSystemNameValue {
    <#
    .SYNOPSIS
    Gets the expected operating system name value.

    .DESCRIPTION
    This function gets the expected operating system name value.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER Existing
    The existing operating system.

    .EXAMPLE
    Get-ExpectedOperatingSystemNameValue -Module $module -Existing $existing

    .OUTPUTS
    System.String
    #>

    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [Microsoft.Dism.Commands.WimImageInfoObject]$WimImage,
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Collections.Hashtable]$Existing
    )

    $name = $Module.Params.name

    if ($null -ne $name) {
        return $name
    }

    if ($null -ne $Existing) {
        return $Existing.name
    }

    $wimFileName = [System.IO.Path]::GetFileName($WimImage.ImagePath)

    return "$($WimImage.ImageName) in $($Module.Params.destination_folder) $($wimFileName)"
}

function Get-ExpectedOperatingSystemPathsValue {
    <#
    .SYNOPSIS
    Gets the expected paths.

    .DESCRIPTION
    This function gets the expected paths.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER Existing
    The existing MDT operating system.

    .EXAMPLE
    Get-ExpectedOperatingSystemPathsValue -Module $Module -Existing $Existing

    .OUTPUTS
    string[]
    #>

    [OutputType([string[]])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $false)]
        [System.Collections.Hashtable]$Existing
    )

    if ($null -eq $Module.Params.paths -and $null -eq $Existing) {
        return [string[]]@("")
    }

    if ($null -eq $Module.Params.paths) {
        return $Existing.paths
    }

    $paths = New-Object -TypeName System.Collections.ArrayList
    $setPaths = $Module.Params.paths.set

    if ($null -ne $setPaths) {
        return [string[]]$setPaths.ToArray()
    }

    if ($null -ne $Existing) {
        $existingPaths = $Existing.paths
    }
    else {
        $existingPaths = [string[]]@("")
    }

    $addPaths = $Module.Params.paths.add

    if ($null -eq $addPaths) {
        $addPaths = @()
    }

    $removePaths = $Module.Params.paths.remove

    if ($null -eq $removePaths) {
        $removePaths = @()
    }

    foreach ($path in $existingPaths) {

        if ($removePaths -inotcontains $path) {
            $paths.Add($path) | Out-Null
        }
    }

    foreach ($path in $addPaths) {

        if ($paths -inotcontains $path) {
            $paths.Add($path) | Out-Null
        }
    }

    return $paths.ToArray()
}

function New-MDTOperatingSystem {
    <#
    .SYNOPSIS
    Creates a new MDT operating system.

    .DESCRIPTION
    This function creates a new MDT operating system.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The name of the MDT drive.

    .PARAMETER Expected
    The expected operating system.

    .EXAMPLE
    New-MDTOperatingSystem -Module $module -MDTDriveName $mdtDrive.Name -Expected $expected
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

    $mdtSharePath = $Module.Params.mdt_share_path
    $sourcePath = $Module.Params.source_path

    $source = $Expected.files_path -replace [regex]::Escape($mdtSharePath), '.'

    if ($Expected.type -eq "source") {

        $includesSetup = "True"

        foreach ($file in $Expected.files) {

            $sourceFilePath = "$($sourcePath)\$($file.path)"
            $destinationFilePath = "$($Expected.files_path)\$($file.path)"

            $destinationDirectoryPath = [System.IO.Path]::GetDirectoryName($destinationFilePath)

            if (-not (Test-Path -LiteralPath $destinationDirectoryPath -PathType Container)) {
                New-Item -Path $destinationDirectoryPath -ItemType Directory | Out-Null
            }

            Copy-Item -LiteralPath $sourceFilePath -Destination $destinationFilePath -Force | Out-Null
        }
    }
    elseif ($Expected.type -eq "wim") {

        $includesSetup = "False"

        if (-not (Test-Path -LiteralPath $Expected.files_path -PathType Container)) {
            New-Item -Path $Expected.files_path -ItemType Directory | Out-Null
        }

        Copy-Item -LiteralPath $sourcePath -Destination $Expected.files_path -Force | Out-Null
    }

    $firstPathSegments = $Expected.paths[0] -split "\\" | Where-Object { -not [string]::IsNullOrEmpty($_) }
    $firstFullPath = @(@("Operating Systems"); $firstPathSegments; $Expected.name) | Get-FullPath -MDTDriveName $MDTDriveName

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
        Path = $firstFullPath
        Build = $Expected.build
        Comments = $Expected.comments
        Description = $Expected.description
        enable = $enableValue
        Flags = $Expected.flags
        HAL = $Expected.hal
        hide = $hideValue
        ImageFile = $Expected.image_file
        ImageIndex = $Expected.image_index
        ImageName = $Expected.image_name
        IncludesSetup = $includesSetup
        Language = [object[]]$Expected.languages
        OSType = $Expected.os_type
        Platform = $Expected.platform
        Size = [string]$Expected.size
        SMSImage = "False"
        Source = $source
    }

    if ($null -ne $Expected.guid) {
        $newItemArgs.guid = $Expected.guid
    }

    New-Item @newItemArgs | Out-Null

    foreach ($path in $Expected.paths) {

        $pathSegments = $path -split "\\" | Where-Object { -not [string]::IsNullOrEmpty($_) }
        $fullPath = @(@("Operating Systems"); $pathSegments) | Get-FullPath -MDTDriveName $MDTDriveName

        if ($firstFullPath -ieq "$($fullPath)\$($Expected.name)") {
            continue
        }

        Copy-Item -LiteralPath $firstFullPath -Destination $fullPath | Out-Null
    }

    $currentOperatingSystem = Get-MDTOperatingSystem -Module $Module -MDTDriveName $MDTDriveName -Guid $Expected.guid -Name $Expected.name |
        Format-MDTOperatingSystem -Module $Module -MDTDriveName $MDTDriveName -IncludeFiles

    $Module.Diff.after = $currentOperatingSystem
    $Module.Result.operating_system = $currentOperatingSystem
}

function Compare-ExpectedOperatingSystemToExisting {
    <#
    .SYNOPSIS
    Compares the expected operating system to the existing operating system.

    .DESCRIPTION
    This function compares the expected operating system to the existing operating system.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The name of the MDT drive.

    .PARAMETER Expected
    The expected operating system.

    .PARAMETER Existing
    The existing operating system.

    .EXAMPLE
    Compare-ExpectedOperatingSystemToExisting -Module $module -MDTDriveName $mdtDrive.Name -Expected $expected -Existing $existing

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
        [System.Collections.Hashtable]$Expected,
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$Existing
    )

    $propertyChanges = @{}

    if ($Expected.name -ne $Existing.name) {
        $propertyChanges.Name = $Expected.name
    }

    if ($Expected.build -ne $Existing.build) {
        $propertyChanges.Build = $Expected.build
    }

    if ($Expected.comments -ne $Existing.comments) {
        if ($Expected.comments -eq "") {
            $propertyChanges.CommentsEmpty = $true
        }
        else {
            $propertyChanges.Comments = $Expected.comments
        }
    }

    if ($Expected.description -ne $Existing.description) {
        $propertyChanges.Description = $Expected.description
    }

    if ($Expected.enabled -ne $Existing.enabled) {
        $propertyChanges.Enabled = $Expected.enabled
    }

    if ($Expected.flags -ne $Existing.flags) {
        $propertyChanges.Flags = $Expected.flags
    }

    if ($Expected.hidden -ne $Existing.hidden) {
        $propertyChanges.Hidden = $Expected.hidden
    }

    if ($Expected.image_file -ne $Existing.image_file) {
        $propertyChanges.ImageFile = $Expected.image_file
    }

    if ($Expected.image_index -ne $Existing.image_index) {
        $propertyChanges.ImageIndex = [string]$Expected.image_index
    }

    if ($Expected.image_name -ne $Existing.image_name) {
        $propertyChanges.ImageName = $Expected.image_name
    }

    $missingLanguages = [Array]($Expected.languages | Where-Object { $Existing.languages -notcontains $_ })
    $extraLanguages = [Array]($Existing.languages | Where-Object { $Expected.languages -notcontains $_ })

    if ($null -ne $missingLanguages -or $null -ne $extraLanguages) {
        $propertyChanges.Language = $Expected.languages
    }

    if ($Expected.os_type -ne $Existing.os_type) {
        $propertyChanges.OSType = $Expected.os_type
    }

    if ($Expected.platform -ne $Existing.platform) {
        $propertyChanges.Platform = $Expected.platform
    }

    if ($Expected.size -ne $Existing.size) {
        $propertyChanges.Size = [string]$Expected.size
    }

    if ($Expected.sms_image -ne $Existing.sms_image) {
        $propertyChanges.SMSImage = $Expected.sms_image
    }

    if ($Expected.files_path -ne $Existing.files_path) {
        $propertyChanges.Source = $Expected.files_path -replace [regex]::Escape($Module.Params.mdt_share_path), '.'
    }

    $addPaths = New-Object -TypeName System.Collections.ArrayList

    foreach ($expectedPath in $Expected.paths) {

        if ($Existing.paths -icontains $expectedPath) {
            continue
        }

        $pathSegments = $expectedPath -split "\\" | Where-Object { -not [string]::IsNullOrEmpty($_) }
        $fullPath = @(@("Operating Systems"); $pathSegments) | Get-FullPath -MDTDriveName $MDTDriveName

        $addPaths.Add($fullPath) | Out-Null
    }

    if ($addPaths.Count -gt 0) {
        $propertyChanges.AddPaths = [string[]]$addPaths.ToArray()
    }

    $removePaths = New-Object -TypeName System.Collections.ArrayList

    foreach ($existingPath in $Existing.paths) {

        if ($Expected.paths -icontains $existingPath) {
            continue
        }

        $pathSegments = $existingPath -split "\\" | Where-Object { -not [string]::IsNullOrEmpty($_) }
        $fullPath = @(@("Operating Systems"); $pathSegments; @($Expected.name)) | Get-FullPath -MDTDriveName $MDTDriveName

        $removePaths.Add($fullPath) | Out-Null
    }

    if ($removePaths.Count -gt 0) {
        $propertyChanges.RemovePaths = [string[]]$removePaths.ToArray()
    }

    $sourcePath = $Module.Params.source_path
    $copyFiles = New-Object -TypeName System.Collections.Generic.List[System.Collections.Hashtable]

    if ($null -ne $propertyChanges.FilesPath -and $null -ne $Existing.files -and $Existing.files.Length -gt 0) {

        foreach ($expectedFile in $Expected.files) {

            $sourceFilePath = "$($sourcePath)\$($expectedFile.path)"
            $destinationFilePath = "$($Expected.files_path)\$($expectedFile.path)"

            $destinationDirectoryPath = [System.IO.Path]::GetDirectoryName($destinationFilePath)

            $copyFile = @{
                source = $sourceFilePath
                destination = $destinationDirectoryPath
            }

            $copyFiles.Add($copyFile) | Out-Null
        }
    }
    elseif ($null -ne $Expected.files_path -and $null -ne $Existing.files -and $Existing.files.Length -gt 0) {

        $deleteFiles = New-Object -TypeName System.Collections.ArrayList

        foreach ($existingFile in $Existing.files) {

            $fileNeeded = $false

            foreach ($expectedFile in $Expected.files) {

                if ($existingFile.path -eq $expectedFile.path) {
                    $fileNeeded = $true
                    break
                }
            }

            if ($fileNeeded) {
                continue
            }

            $filePath = "$($Existing.files_path)\$($existingFile.path)"

            $deleteFiles.Add($filePath) | Out-Null
        }

        foreach ($expectedFile in $Expected.files) {

            $fileDoesNotNeedCopying = $false

            foreach ($existingFile in $Existing.files) {

                if ($expectedFile.path -eq $existingFile.path -and $expectedFile.sha256_checksum -eq $existingFile.sha256_checksum) {

                    $fileDoesNotNeedCopying = $true
                    break
                }
            }

            if ($fileDoesNotNeedCopying) {
                continue
            }

            $sourceFilePath = "$($sourcePath)\$($expectedFile.path)"
            $destinationFilePath = "$($Expected.files_path)\$($expectedFile.path)"

            $destinationDirectoryPath = [System.IO.Path]::GetDirectoryName($destinationFilePath)

            $copyFile = @{
                source = $sourceFilePath
                destination = $destinationDirectoryPath
            }

            $copyFiles.Add($copyFile) | Out-Null
        }

        if ($deleteFiles.Count -gt 0) {
            $propertyChanges.DeleteFiles = [string[]]$deleteFiles.ToArray()
        }
    }

    if ($copyFiles.Count -gt 0) {
        $propertyChanges.CopyFiles = [System.Collections.Hashtable[]]$copyFiles.ToArray()
    }

    return $propertyChanges
}

function Set-MDTOperatingSystem {
    <#
    .SYNOPSIS
    Sets an MDT operating system.

    .DESCRIPTION
    This function sets an MDT operating system.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The name of the MDT drive.

    .PARAMETER Name
    The name of the operating system.

    .PARAMETER Build
    The build number of the operating system.

    .PARAMETER CommentsEmpty
    Indicates whether the comments should be empty.

    .PARAMETER Comments
    The comments for the operating system.

    .PARAMETER Description
    The description of the operating system.

    .PARAMETER Enabled
    Indicates whether the operating system is enabled.

    .PARAMETER Flags
    The flags for the operating system.

    .PARAMETER Hidden
    Indicates whether the operating system is hidden.

    .PARAMETER ImageFile
    The image file for the operating system.

    .PARAMETER ImageIndex
    The image index for the operating system.

    .PARAMETER ImageName
    The image name for the operating system.

    .PARAMETER Languages
    The languages for the operating system.

    .PARAMETER OSType
    The operating system type.

    .PARAMETER Platform
    The platform for the operating system.

    .PARAMETER Size
    The size of the operating system.

    .PARAMETER SMSImage
    Indicates whether the operating system is an SMS image.

    .PARAMETER Source
    The source path for the operating system.

    .PARAMETER AddPaths
    The paths to add.

    .PARAMETER RemovePaths
    The paths to remove.

    .PARAMETER CopyFiles
    The files to copy.

    .PARAMETER DeleteFiles
    The files to delete.

    .EXAMPLE
    Set-MDTOperatingSystem -Module $module `
        -MDTDriveName $mdtDrive.Name `
        -Name $expected.name `
        -Build $expected.build `
        -CommentsEmpty $expected.commentsEmpty `
        -Comments $expected.comments `
        -Description $expected.description `
        -Enabled $expected.enabled `
        -Flags $expected.flags `
        -Hidden $expected.hidden `
        -ImageFile $expected.image_file `
        -ImageIndex $expected.image_index `
        -ImageName $expected.image_name `
        -Languages $expected.languages `
        -OSType $expected.os_type `
        -Platform $expected.platform `
        -Size $expected.size `
        -SMSImage $expected.sms_image `
        -Source $expected.files_path `
        -AddPaths $expected.paths `
        -RemovePaths $expected.paths `
        -CopyFiles $expected.files `
        -DeleteFiles $expected.deleteFiles
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [string]$MDTDriveName,
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [string]$Name,
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [string]$Build,
        [Parameter(Mandatory = $false)]
        [bool]$CommentsEmpty = $false,
        [Parameter(Mandatory = $false)]
        [string]$Comments,
        [Parameter(Mandatory = $false)]
        [string]$Description,
        [Parameter(Mandatory = $false)]
        [ValidateSet($null, $false, $true)]
        [object]$Enabled,
        [Parameter(Mandatory = $false)]
        [string]$Flags,
        [Parameter(Mandatory = $false)]
        [ValidateSet($null, $false, $true)]
        [object]$Hidden,
        [Parameter(Mandatory = $false)]
        [string]$ImageFile,
        [Parameter(Mandatory = $false)]
        [int]$ImageIndex,
        [Parameter(Mandatory = $false)]
        [string]$ImageName,
        [Parameter(Mandatory = $false)]
        [string[]]$Language,
        [Parameter(Mandatory = $false)]
        [string]$OSType,
        [Parameter(Mandatory = $false)]
        [string]$Platform,
        [Parameter(Mandatory = $false)]
        [int]$Size,
        [Parameter(Mandatory = $false)]
        [ValidateSet($null, $false, $true)]
        [object]$SMSImage,
        [Parameter(Mandatory = $false)]
        [string]$Source,
        [Parameter(Mandatory = $false)]
        [string[]]$AddPaths,
        [Parameter(Mandatory = $false)]
        [string[]]$RemovePaths,
        [Parameter(Mandatory = $false)]
        [System.Collections.Hashtable[]]$CopyFiles,
        [Parameter(Mandatory = $false)]
        [string[]]$DeleteFiles
    )

    if ($Module.CheckMode) {
        return
    }

    $pathPrefix = "MicrosoftDeploymentToolkit\MDTProvider::"

    if ($null -ne $CopyFiles) {

        foreach ($copyFile in $CopyFiles) {

            if (-not (Test-Path -LiteralPath $copyFile.destination -PathType Container)) {
                New-Item -Path $copyFile.destination -ItemType Directory | Out-Null
            }

            Copy-Item -LiteralPath $copyFile.source -Destination $copyFile.destination -Force | Out-Null
        }
    }

    if ($null -ne $DeleteFiles) {

        foreach ($deleteFile in $DeleteFiles) {

            if (Test-Path -LiteralPath $deleteFile -PathType Leaf) {
                Remove-Item -LiteralPath $deleteFile -Force | Out-Null
            }
        }
    }

    $operatingSystems = [Array](Get-MDTOperatingSystem -Module $Module -MDTDriveName $MDTDriveName -Guid $Module.Params.guid -Name $Module.Params.name)
    $operatingSystem = $operatingSystems[0]

    if ($null -ne $AddPaths) {

        foreach ($addPath in $AddPaths) {

            if (Test-Path -LiteralPath "$($addPath)\$($operatingSystem.Name)" -PathType Leaf) {
                continue
            }

            $sourcePath = $operatingSystem.PSPath -replace [regex]::Escape($pathPrefix), ""

            Copy-Item -LiteralPath $sourcePath -Destination $addPath | Out-Null
        }
    }

    if (-not [string]::IsNullOrEmpty($Build)) {
        $operatingSystem.Item("Build") = $Build
    }

    if ($CommentsEmpty) {
        $operatingSystem.Item("Comments") = ""
    }
    elseif (-not [string]::IsNullOrEmpty($Comments)) {
        $operatingSystem.Item("Comments") = $Comments
    }

    if (-not [string]::IsNullOrEmpty($Description)) {
        $operatingSystem.Item("Description") = $Description
    }

    if ($null -ne $Enabled) {
        if ($Enabled) {
            $operatingSystem.Item("enable") = "True"
        }
        else {
            $operatingSystem.Item("enable") = "False"
        }
    }

    if (-not [string]::IsNullOrEmpty($Flags)) {
        $operatingSystem.Item("Flags") = $Flags
    }

    if ($null -ne $Hidden) {
        if ($Hidden) {
            $operatingSystem.Item("hide") = "True"
        }
        else {
            $operatingSystem.Item("hide") = "False"
        }
    }

    if (-not [string]::IsNullOrEmpty($ImageFile)) {
        $operatingSystem.Item("ImageFile") = $ImageFile
    }

    if ($null -ne $ImageIndex -and $ImageIndex -gt 0) {
        $operatingSystem.Item("ImageIndex") = [string]$ImageIndex
    }

    if (-not [string]::IsNullOrEmpty($ImageName)) {
        $operatingSystem.Item("ImageName") = $ImageName
    }

    if ($null -ne $Language) {
        $operatingSystem.Item("Language") = [object[]]$Language
    }

    if (-not [string]::IsNullOrEmpty($OSType)) {
        $operatingSystem.Item("OSType") = $OSType
    }

    if (-not [string]::IsNullOrEmpty($Platform)) {
        $operatingSystem.Item("Platform") = $Platform
    }

    if ($null -ne $Size -and $Size -gt 0) {
        $operatingSystem.Item("Size") = [string]$Size
    }

    if ($null -ne $SMSImage) {

        if ($SMSImage) {
            $operatingSystem.Item("SMSImage") = "True"
        }
        else {
            $operatingSystem.Item("SMSImage") = "False"
        }
    }

    if (-not [string]::IsNullOrEmpty($Source)) {
        $operatingSystem.Item("Source") = $Source
    }

    if (-not [string]::IsNullOrEmpty($Name)) {
        $operatingSystem.RenameItem($Name)
    }

    if ($null -ne $RemovePaths) {

        foreach ($removePath in $RemovePaths) {

            if (Test-Path -LiteralPath $removePath -PathType Leaf) {
                Remove-Item -LiteralPath $removePath | Out-Null
            }
        }
    }

    $operatingSystem = Get-MDTOperatingSystem -Module $Module -MDTDriveName $MDTDriveName -Guid $Module.Params.guid -Name $Module.Params.name |
        Format-MDTOperatingSystem -Module $Module -MDTDriveName $MDTDriveName -IncludeFiles

    $Module.Result.operating_system = $operatingSystem
    $Module.Diff.after = $operatingSystem
}

function Remove-MDTOperatingSystem {
    <#
    .SYNOPSIS
    Removes an MDT operating system.

    .DESCRIPTION
    This function removes an MDT operating system.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The name of the MDT drive.

    .EXAMPLE
    Remove-MDTOperatingSystem -Module $module -MDTDriveName $mdtDrive.Name
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [string]$MDTDriveName
    )

    if ($Module.CheckMode) {
        return
    }

    $operatingSystems = [Array](Get-MDTOperatingSystem -Module $Module -MDTDriveName $MDTDriveName -Guid $Module.Params.guid -Name $Module.Params.name)

    if ($null -eq $operatingSystems) {
        return
    }

    $pathPrefix = "MicrosoftDeploymentToolkit\MDTProvider::"

    foreach ($operatingSystem in $operatingSystems) {
        $operatingSystemPath = $operatingSystem.PSPath -replace [regex]::Escape($pathPrefix), ""
        Remove-Item -LiteralPath $operatingSystemPath | Out-Null
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
        guid = @{
            type = 'str'
            required = $false
        }
        name = @{
            type = 'str'
            required = $false
        }
        paths = @{
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
        type = @{
            type = 'str'
            required = $false
            choices = @(
                'source',
                'wim'
            )
        }
        source_path = @{
            type = 'path'
            required = $false
        }
        destination_folder = @{
            type = 'str'
            required = $false
        }
        image_index = @{
            type = 'int'
            required = $false
        }
        image_name = @{
            type = 'str'
            required = $false
        }
        image_edition_id = @{
            type = 'str'
            required = $false
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
    mutually_exclusive = @(
        , @('image_index', 'image_name', 'image_edition_id')
    )
    required_if = @(
        @('state', 'present', @('type', 'source_path', 'destination_folder')),
        @('state', 'present', @('image_index', 'image_name', 'image_edition_id'), $true)
    )
    required_one_of = @(
        , @('name', 'guid')
    )
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$module | Confirm-OperatingSystemParamsAreValid | Out-Null
Import-MDTModule -Module $module | Out-Null
Import-Module -Name Dism | Out-Null

$mdtDrive = Get-MDTPSDrive -Module $module -ReadWrite

$existing = Get-MDTOperatingSystem -Module $module -MDTDriveName $mdtDrive.Name -Guid $module.Params.guid -Name $module.Params.name |
    Format-MDTOperatingSystem -Module $module -MDTDriveName $mdtDrive.Name -IncludeFiles

$module.Result.changed = $false
$module.Diff.before = $existing

$state = $module.Params.state

if ($state -eq "present") {

    $module | Confirm-OperatingSystemPresentParamsAreValid -MDTDriveName $mdtDrive.Name -Existing $existing | Out-Null

    $expected = Get-ExpectedOperatingSystem -Module $module -Existing $existing

    $module.Diff.after = $expected
    $module.Result.operating_system = $expected

    if ($null -eq $existing) {
        $module.Result.changed = $true
        New-MDTOperatingSystem -Module $module -MDTDriveName $mdtDrive.Name -Expected $expected | Out-Null
    }
    else {

        $propertyChanges = Compare-ExpectedOperatingSystemToExisting -Module $module -MDTDriveName $mdtDrive.Name -Expected $expected -Existing $existing

        if ($propertyChanges.Count -gt 0) {

            $module.Result.changed = $true
            Set-MDTOperatingSystem -Module $module -MDTDriveName $mdtDrive.Name @propertyChanges | Out-Null
        }
    }
}
elseif ($state -eq "absent") {

    $module | Confirm-OperatingSystemAbsentParamsAreValid | Out-Null

    $module.Diff.after = $null

    if ($null -ne $existing) {
        $module.Result.changed = $true
        Remove-MDTOperatingSystem -Module $module -MDTDriveName $mdtDrive.Name | Out-Null
    }
}

$mdtDrive | Remove-PSDrive | Out-Null

$module.ExitJson()
