#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.Common
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.Application

function Confirm-ApplicationParamsAreValid {
    <#
    .SYNOPSIS
    Confirms that the parameters are valid for the module.

    .DESCRIPTION
    This function confirms that the parameters are valid for the module.

    .PARAMETER Module
    The module object.

    .EXAMPLE
    Confirm-ApplicationParamsAreValid -Module $Module
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [Ansible.Basic.AnsibleModule]$Module
    )

    process {

        if ($Module.Params.state -eq "absent") {
            $Module | Confirm-ApplicationParamsAreValidForAbsent | Out-Null
        }

        if ($Module.Params.state -eq "present") {
            $Module | Confirm-ApplicationParamsAreValidForPresent | Out-Null
        }

        $Module.Params.guid = $Module.Params.guid | Format-MDTGuid -Module $Module
        $Module.Params.name | Confirm-NameIsValid -Module $Module -ParameterName "name" | Out-Null
    }
}

function Confirm-ApplicationParamsAreValidForAbsent {
    <#
    .SYNOPSIS
    Confirms that the parameters are valid for the module when the state is 'absent'.

    .DESCRIPTION
    This function confirms that the parameters are valid for the module when the state is 'absent'.

    .PARAMETER Module
    The module object.

    .EXAMPLE
    Confirm-ApplicationParamsAreValidForAbsent -Module $Module
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

        if ($null -ne $Module.Params.publisher) {
            $invalidParams.Add("publisher") | Out-Null
        }

        if ($null -ne $Module.Params.short_name) {
            $invalidParams.Add("short_name") | Out-Null
        }

        if ($null -ne $Module.Params.version) {
            $invalidParams.Add("version") | Out-Null
        }

        if ($null -ne $Module.Params.language) {
            $invalidParams.Add("language") | Out-Null
        }

        if ($null -ne $Module.Params.command_line) {
            $invalidParams.Add("command_line") | Out-Null
        }

        if ($null -ne $Module.Params.working_directory) {
            $invalidParams.Add("working_directory") | Out-Null
        }

        if ($null -ne $Module.Params.source_path) {
            $invalidParams.Add("source_path") | Out-Null
        }

        if ($null -ne $Module.Params.destination_folder) {
            $invalidParams.Add("destination_folder") | Out-Null
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

        if ($null -ne $Module.Params.reboot) {
            $invalidParams.Add("reboot") | Out-Null
        }

        if ($invalidParams.Count -gt 0) {
            $Module.FailJson("The following parameters are invalid when state is absent: $($invalidParams -join ', ')")
        }
    }
}

function Confirm-ApplicationParamsAreValidForPresent {
    <#
    .SYNOPSIS
    Confirms that the parameters are valid for the module when the state is 'present'.

    .DESCRIPTION
    This function confirms that the parameters are valid for the module when the state is 'present'.

    .PARAMETER Module
    The module object.

    .EXAMPLE
    Confirm-ApplicationParamsAreValidForPresent -Module $Module
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
        $paths = $Module.Params.paths
        $publisher = $Module.Params.publisher
        $shortName = $Module.Params.short_name
        $version = $Module.Params.version
        $language = $Module.Params.language
        $commandLine = $Module.Params.command_line
        $workingDirectory = $Module.Params.working_directory
        $sourcePath = $Module.Params.source_path
        $destinationFolder = $Module.Params.destination_folder

        $invalidParams = New-Object -TypeName System.Collections.ArrayList

        switch ($type) {
            "bundle" {

                if ($null -ne $commandLine) {
                    $invalidParams.Add("command_line") | Out-Null
                }

                if ($null -ne $workingDirectory) {
                    $invalidParams.Add("working_directory") | Out-Null
                }

                if ($null -ne $sourcePath) {
                    $invalidParams.Add("source_path") | Out-Null
                }

                if ($null -ne $destinationFolder) {
                    $invalidParams.Add("destination_folder") | Out-Null
                }
            }
            "no_source" {

                if ($null -eq $commandLine) {
                    $Module.FailJson("The 'command_line' parameter is required for the '$($type)' application type.")
                }

                if ($null -ne $sourcePath) {
                    $invalidParams.Add("source_path") | Out-Null
                }

                if ($null -ne $destinationFolder) {
                    $invalidParams.Add("destination_folder") | Out-Null
                }
            }
            "source" {

                if ($null -eq $commandLine) {
                    $Module.FailJson("The 'command_line' parameter is required for the '$($type)' application type.")
                }

                if ($null -eq $sourcePath) {
                    $Module.FailJson("The 'source_path' parameter is required for the '$($type)' application type.")
                }
            }
            Default {
                $Module.FailJson("The 'type' parameter has an unexpected value. Value: '$($type)'")
            }
        }

        if ($invalidParams.Count -gt 0) {
            $Module.FailJson("The following parameters are invalid for the '$($type)' application type: $($invalidParams -join ', ')")
        }

        $publisher | Confirm-NameIsValid -Module $Module -ParameterName "publisher" | Out-Null
        $shortName | Confirm-NameIsValid -Module $Module -ParameterName "short_name" | Out-Null
        $version | Confirm-NameIsValid -Module $Module -ParameterName "version" | Out-Null
        $language | Confirm-NameIsValid -Module $Module -ParameterName "language" | Out-Null

        if (-not [string]::IsNullOrEmpty($workingDirectory)) {

            $Module.Params.working_directory = $workingDirectory | Format-MDTPath
            $workingDirectory = $Module.Params.working_directory

            $workingDirectory = $workingDirectory -replace "^$([regex]::Escape(".\"))", ""
            $workingDirectory = $workingDirectory -replace "^[a-zA-Z]$([regex]::Escape(":\"))", ""

            $workingDirectory | Confirm-MDTPathIsValid -Module $Module -ParameterName "working_directory" | Out-Null
        }

        $destinationFolder | Confirm-MDTPathSegmentIsValid -Module $Module -ParameterName "destination_folder" | Out-Null

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
                }
            }
        }
    }
}

function Get-ExpectedApplication {
    <#
    .SYNOPSIS
    Gets the expected MDT application.

    .DESCRIPTION
    This function gets the expected MDT application.

    .PARAMETER Module
    The module object.

    .PARAMETER Existing
    The existing MDT application.

    .EXAMPLE
    Get-ExpectedApplication -Module $Module -Existing $Existing

    .OUTPUTS
    System.Collections.Hashtable
    #>

    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $false)]
        [System.Collections.Hashtable]$Existing
    )

    $type = $Module.Params.type
    $guid = $Module.Params.guid
    $shortName = $Module.Params.short_name
    $language = $Module.Params.language
    $comments = $Module.Params.comments
    $enabled = $Module.Params.enabled
    $hidden = $Module.Params.hidden
    $reboot = $Module.Params.reboot

    $expected = @{
        type = $type
        name = Get-ExpectedApplicationNameValue -Module $Module -Existing $Existing
        publisher = Get-ExpectedApplicationPublisherValue -Module $Module -Existing $Existing
        short_name = $shortName
        version = Get-ExpectedApplicationVersionValue -Module $Module -Existing $Existing
        paths = [string[]](Get-ExpectedApplicationPathsValue -Module $Module -Existing $Existing)
    }

    if ($expected.paths.Length -eq 0) {
        $Module.FailJson("The 'paths' parameter would remove the application.")
    }

    if ($null -ne $guid) {
        $expected.guid = $guid
    }
    elseif ($null -ne $Existing) {
        $expected.guid = $Existing.guid
    }

    if ($null -ne $language) {
        $expected.language = $language
    }
    elseif ($null -ne $Existing) {
        $expected.language = $Existing.language
    }
    else {
        $expected.language = ""
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

    if ($null -ne $reboot) {
        $expected.reboot = $reboot
    }
    elseif ($null -ne $Existing) {
        $expected.reboot = $Existing.reboot
    }
    else {
        $expected.reboot = $false
    }

    if ($null -ne $Existing) {
        $expected.dependencies = $Existing.dependencies
    }

    switch ($type) {
        "source" {
            $expected.command_line = $Module.Params.command_line
            $expected.working_directory = Get-ExpectedApplicationWorkingDirectoryValue -Module $Module -Existing $Existing
            $expected.files_path = Get-ExpectedApplicationFilesPathValue -Module $Module -Existing $Existing

            $files = [Array](Format-MDTFilesValue -DirectoryPath $Module.Params.source_path)

            if ($null -ne $files) {
                $expected.files = [System.Collections.Hashtable[]]$files
            }
            else {
                $expected.files = [System.Collections.Hashtable[]]@()
            }
        }
        "no_source" {
            $expected.command_line = $Module.Params.command_line
            $expected.working_directory = Get-ExpectedApplicationWorkingDirectoryValue -Module $Module -Existing $Existing
        }
        Default {}
    }

    return $expected
}

function Get-ExpectedApplicationNameValue {
    <#
    .SYNOPSIS
    Gets the expected name.

    .DESCRIPTION
    This function gets the expected name.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER Existing
    The existing MDT application.

    .EXAMPLE
    Get-ExpectedApplicationNameValue -Module $Module -Existing $Existing

    .OUTPUTS
    string
    #>

    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $false)]
        [System.Collections.Hashtable]$Existing
    )

    $name = $Module.Params.name

    if ($null -ne $name) {
        return $name
    }

    if ($null -ne $Existing) {
        return $Existing.name
    }

    $publisher = Get-ExpectedApplicationPublisherValue -Module $Module -Existing $Existing
    $shortName = $Module.Params.short_name
    $version = Get-ExpectedApplicationVersionValue -Module $Module -Existing $Existing

    if ([string]::IsNullOrEmpty($publisher)) {
        $name = $shortName
    }
    else {
        $name = "$($publisher) $($shortName)"
    }

    if ([string]::IsNullOrEmpty($version)) {
        return $name
    }

    return "$($name) $($version)"
}

function Get-ExpectedApplicationPathsValue {
    <#
    .SYNOPSIS
    Gets the expected paths.

    .DESCRIPTION
    This function gets the expected paths.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER Existing
    The existing MDT application.

    .EXAMPLE
    Get-ExpectedApplicationPathsValue -Module $Module -Existing $Existing

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

function Get-ExpectedApplicationPublisherValue {
    <#
    .SYNOPSIS
    Gets the expected publisher.

    .DESCRIPTION
    This function gets the expected publisher.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER Existing
    The existing MDT application.

    .EXAMPLE
    Get-ExpectedApplicationPublisherValue -Module $Module -Existing $Existing

    .OUTPUTS
    string
    #>

    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $false)]
        [System.Collections.Hashtable]$Existing
    )

    $publisher = $Module.Params.publisher

    if ($null -ne $publisher) {
        return $publisher
    }

    if ($null -ne $Existing) {
        return $Existing.publisher
    }

    return ""
}

function Get-ExpectedApplicationVersionValue {
    <#
    .SYNOPSIS
    Gets the expected version.

    .DESCRIPTION
    This function gets the expected version.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER Existing
    The existing MDT application.

    .EXAMPLE
    Get-ExpectedApplicationVersionValue -Module $Module -Existing $Existing

    .OUTPUTS
    string
    #>

    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $false)]
        [System.Collections.Hashtable]$Existing
    )

    $version = $Module.Params.version

    if ($null -ne $version) {
        return $version
    }

    if ($null -ne $Existing) {
        return $Existing.version
    }

    return ""
}

function Get-ExpectedApplicationWorkingDirectoryValue {
    <#
    .SYNOPSIS
    Gets the expected working directory.

    .DESCRIPTION
    This function gets the expected working directory.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER Existing
    The existing MDT application.

    .EXAMPLE
    Get-ExpectedApplicationWorkingDirectoryValue -Module $Module -Existing $Existing

    .OUTPUTS
    string
    #>

    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $false)]
        [System.Collections.Hashtable]$Existing
    )

    $workingDirectory = $Module.Params.working_directory

    if ($null -ne $workingDirectory) {
        return $workingDirectory
    }

    $defaultWorkingDirectory = ""

    $type = $Module.Params.type
    $filesPath = Get-ExpectedApplicationFilesPathValue -Module $Module -Existing $Existing
    $mdtSharePath = $Module.Params.mdt_share_path

    if ($type -eq "source") {
        $defaultWorkingDirectory = $filesPath -replace [regex]::Escape($mdtSharePath), "."
    }

    if ($null -eq $Existing -or $null -eq $Existing.working_directory) {
        return $defaultWorkingDirectory
    }

    if ($type -eq $Existing.type) {
        return $Existing.working_directory
    }

    $existingDefaultWorkingDirectory = ""

    if ($Existing.type -eq "source") {
        $existingDefaultWorkingDirectory = $Existing.files_path -replace [regex]::Escape($mdtSharePath), "."
    }

    if ($existingDefaultWorkingDirectory -eq $Existing.working_directory) {
        return $defaultWorkingDirectory
    }

    return $Existing.working_directory
}

function Get-ExpectedApplicationFilesPathValue {
    <#
    .SYNOPSIS
    Gets the expected files path.

    .DESCRIPTION
    This function gets the expected files path.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER Existing
    The existing MDT application.

    .EXAMPLE
    Get-ExpectedApplicationFilesPathValue -Module $Module -Existing $Existing

    .OUTPUTS
    string
    #>

    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $false)]
        [System.Collections.Hashtable]$Existing
    )

    $mdtSharePath = $Module.Params.mdt_share_path
    $destinationFolder = $Module.Params.destination_folder
    $name = Get-ExpectedApplicationNameValue -Module $Module -Existing $Existing

    if ($null -ne $destinationFolder) {
        return "$($mdtSharePath)\Applications\$($destinationFolder)"
    }

    if ($null -ne $Existing -and $null -ne $Existing.files_path) {
        return $Existing.files_path
    }

    return "$($mdtSharePath)\Applications\$($name)"
}

function New-MDTApplication {
    <#
    .SYNOPSIS
    Creates a new MDT application.

    .DESCRIPTION
    This function creates a new MDT application.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The MDT drive name.

    .PARAMETER Expected
    The expected MDT application configuration.

    .EXAMPLE

    New-MDTApplication -Module $Module -MDTDriveName "DS001" -Expected $Expected
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

    $Module.Result.changed = $true

    if ($Module.CheckMode) {

        $Module.Result.application = $Expected
        return
    }

    $firstPathSegments = $Expected.paths[0] -split "\\" | Where-Object { -not [string]::IsNullOrEmpty($_) }
    $firstFullPath = @(@("Applications"); $firstPathSegments) | Get-FullPath -MDTDriveName $MDTDriveName

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

    $importArgs = @{
        Path = $firstFullPath
        enable = $enableValue
        hide = $hideValue
        Name = $Expected.name
        Publisher = $Expected.publisher
        ShortName = $Expected.short_name
        Version = $Expected.version
        Language = $Expected.language
        Comments = $Expected.comments
        Reboot = $Expected.reboot
    }

    if ($null -ne $Expected.guid) {
        $importArgs.guid = $Expected.guid
    }

    if ($Expected.type -eq "source") {

        $importArgs.ApplicationSourcePath = $Module.Params.source_path
        $importArgs.DestinationFolder = $Expected.files_path -replace [regex]::Escape("$($Module.Params.mdt_share_path)\Applications\"), ""
    }

    if ($Expected.type -ne "bundle") {

        $importArgs.CommandLine = $Expected.command_line
        $importArgs.WorkingDirectory = $Expected.working_directory
    }
    else {
        $importArgs.Bundle = $true
    }

    if ($Module.Params.type -eq "no_source") {
        $importArgs.NoSource = $true
    }

    Import-MDTApplication @importArgs | Out-Null

    $newApplication = Get-MDTApplication -Module $Module -MDTDriveName $MDTDriveName -Guid $Expected.guid -Name $Expected.name

    if ($null -eq $newApplication) {
        $Module.FailJson("Failed to import application '$($Expected.name)'.")
    }

    foreach ($path in $Expected.paths) {

        $pathSegments = $path -split "\\" | Where-Object { -not [string]::IsNullOrEmpty($_) }
        $fullPath = @(@("Applications"); $pathSegments) | Get-FullPath -MDTDriveName $MDTDriveName

        if ($firstFullPath -ieq $fullPath) {
            continue
        }

        Copy-Item -LiteralPath "$($firstFullPath)\$($Expected.name)" -Destination $fullPath | Out-Null
    }

    $currentApplication = Get-MDTApplication -Module $Module -MDTDriveName $MDTDriveName -Guid $Expected.guid -Name $Expected.name |
        Format-MDTApplication -Module $Module -MDTDriveName $MDTDriveName -IncludeFiles

    $Module.Diff.after = $currentApplication
    $Module.Result.application = $currentApplication
}

function Compare-ExpectedApplicationToExisting {
    <#
    .SYNOPSIS
    Compares the expected MDT application to the existing MDT application.

    .DESCRIPTION
    This function compares the expected MDT application to the existing MDT application and produces a hashtable of changes.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER Expected
    The expected MDT application configuration.

    .PARAMETER Existing
    The existing MDT application configuration.

    .EXAMPLE
    Compare-ExpectedApplicationToExisting -Module $Module -Expected $Expected -Existing $Existing

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

    if ($Expected.publisher -ne $Existing.publisher) {

        if ($Expected.publisher -eq "") {
            $propertyChanges.PublisherEmpty = $true
        }
        else {
            $propertyChanges.Publisher = $Expected.publisher
        }
    }

    if ($Expected.short_name -ne $Existing.short_name) {
        $propertyChanges.ShortName = $Expected.short_name
    }

    if ($Expected.version -ne $Existing.version) {

        if ($Expected.version -eq "") {
            $propertyChanges.VersionEmpty = $true
        }
        else {
            $propertyChanges.Version = $Expected.version
        }
    }

    if ($Expected.language -ne $Existing.language) {

        if ($Expected.language -eq "") {
            $propertyChanges.LanguageEmpty = $true
        }
        else {
            $propertyChanges.Language = $Expected.language
        }
    }

    if ($Expected.command_line -ne $Existing.command_line) {

        if ($null -eq $Expected.command_line) {
            $propertyChanges.CommandLineNull = $true
        }
        else {
            $propertyChanges.CommandLine = $Expected.command_line
        }
    }

    if ($Expected.working_directory -ne $Existing.working_directory) {

        if ($null -eq $Expected.working_directory) {
            $propertyChanges.WorkingDirectoryNull = $true
        }
        elseif ($Expected.working_directory -eq "") {
            $propertyChanges.WorkingDirectoryEmpty = $true
        }
        else {
            $propertyChanges.WorkingDirectory = $Expected.working_directory
        }
    }

    if ($Expected.comments -ne $Existing.comments) {

        if ($null -eq $Expected.comments) {
            $propertyChanges.CommentsNull = $true
        }
        else {
            $propertyChanges.Comments = $Expected.comments
        }
    }

    if ($Expected.enabled -ne $Existing.enabled) {
        $propertyChanges.Enabled = $Expected.enabled
    }

    if ($Expected.hidden -ne $Existing.hidden) {
        $propertyChanges.Hidden = $Expected.hidden
    }

    if ($Expected.reboot -ne $Existing.reboot) {
        $propertyChanges.Reboot = $Expected.reboot
    }

    if ($Expected.files_path -ne $Existing.files_path) {

        if ($null -ne $Expected.files_path -and (Test-Path -LiteralPath $Expected.files_path -PathType Container)) {
            $Module.FailJson("The directory '$($Expected.files_path)' already exists.")
        }

        if ($null -ne $Existing.files_path) {
            $propertyChanges.DeleteFolder = $Existing.files_path
        }

        if ($null -eq $Expected.files_path) {
            $propertyChanges.SourceNull = $true
        }
        else {
            $propertyChanges.Source = $Expected.files_path -replace [regex]::Escape($Module.Params.mdt_share_path), "."
        }
    }

    if ($Expected.name -ne $Existing.name) {
        $propertyChanges.Name = $Expected.name
    }

    $addPaths = New-Object -TypeName System.Collections.ArrayList

    foreach ($expectedPath in $Expected.paths) {

        if ($Existing.paths -icontains $expectedPath) {
            continue
        }

        $pathSegments = $expectedPath -split "\\" | Where-Object { -not [string]::IsNullOrEmpty($_) }
        $fullPath = @(@("Applications"); $pathSegments) | Get-FullPath -MDTDriveName $MDTDriveName

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
        $fullPath = @(@("Applications"); $pathSegments; @($Expected.name)) | Get-FullPath -MDTDriveName $MDTDriveName

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

function Set-MDTApplication {
    <#
    .SYNOPSIS
    Sets the MDT application.

    .DESCRIPTION
    This function sets properties on an existing MDT application.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The MDT drive name.

    .PARAMETER Publisher
    The publisher.

    .PARAMETER ShortName
    The short name.

    .PARAMETER Version
    The version.

    .PARAMETER Language
    The language.

    .PARAMETER CommandLineNull
    The command line null flag.

    .PARAMETER CommandLine
    The command line.

    .PARAMETER WorkingDirectoryNull
    The working directory null flag.

    .PARAMETER WorkingDirectory
    The working directory.

    .PARAMETER Comments
    The comments.

    .PARAMETER Enabled
    The enabled flag.

    .PARAMETER Hidden
    The hidden flag.

    .PARAMETER Reboot
    The reboot flag.

    .PARAMETER SourceNull
    The source null flag.

    .PARAMETER Source
    The source.

    .PARAMETER DeleteFolder
    Folder from the previous source to delete.

    .PARAMETER Name
    The name.

    .PARAMETER AddPaths
    The paths to add.

    .PARAMETER RemovePaths
    The paths to remove.

    .PARAMETER CopyFiles
    The files to copy.

    .PARAMETER DeleteFiles
    The files to delete.

    .EXAMPLE
    Set-MDTApplication -Module $Module `
        -MDTDriveName "DS001" `
        -Publisher "Publisher" `
        -ShortName "ShortName" `
        -Version "1.0" `
        -Language "en-US" `
        -CommandLineNull $false `
        -CommandLine "Command Line" `
        -WorkingDirectoryNull $false `
        -WorkingDirectory "Working Directory" `
        -Comments "Comments" `
        -Enabled $true `
        -Hidden $false `
        -Reboot $false `
        -SourceNull $false `
        -Source "Source" `
        -DeleteFolder "Delete Folder" `
        -Name "Name" `
        -AddPaths @("Add Path") `
        -RemovePaths @("Remove Path") `
        -CopyFiles @(@{ source = "Source"; destination = "Destination" }) `
        -DeleteFiles @("Delete File")
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [string]$MDTDriveName,
        [Parameter(Mandatory = $false)]
        [bool]$PublisherEmpty = $false,
        [Parameter(Mandatory = $false)]
        [string]$Publisher,
        [Parameter(Mandatory = $false)]
        [string]$ShortName,
        [Parameter(Mandatory = $false)]
        [bool]$VersionEmpty = $false,
        [Parameter(Mandatory = $false)]
        [string]$Version,
        [Parameter(Mandatory = $false)]
        [bool]$LanguageEmpty = $false,
        [Parameter(Mandatory = $false)]
        [string]$Language,
        [Parameter(Mandatory = $false)]
        [bool]$CommandLineNull = $false,
        [Parameter(Mandatory = $false)]
        [string]$CommandLine,
        [Parameter(Mandatory = $false)]
        [bool]$WorkingDirectoryNull = $false,
        [Parameter(Mandatory = $false)]
        [bool]$WorkingDirectoryEmpty = $false,
        [Parameter(Mandatory = $false)]
        [string]$WorkingDirectory,
        [Parameter(Mandatory = $false)]
        [bool]$CommentsEmpty = $false,
        [Parameter(Mandatory = $false)]
        [string]$Comments,
        [Parameter(Mandatory = $false)]
        [ValidateSet($null, $false, $true)]
        [object]$Enabled = $null,
        [Parameter(Mandatory = $false)]
        [ValidateSet($null, $false, $true)]
        [object]$Hidden = $null,
        [Parameter(Mandatory = $false)]
        [ValidateSet($null, $false, $true)]
        [object]$Reboot = $null,
        [Parameter(Mandatory = $false)]
        [bool]$SourceNull = $false,
        [Parameter(Mandatory = $false)]
        [string]$Source,
        [Parameter(Mandatory = $false)]
        [string]$DeleteFolder,
        [Parameter(Mandatory = $false)]
        [string]$Name,
        [Parameter(Mandatory = $false)]
        [string[]]$AddPaths = $null,
        [Parameter(Mandatory = $false)]
        [string[]]$RemovePaths = $null,
        [Parameter(Mandatory = $false)]
        [System.Collections.Hashtable[]]$CopyFiles = $null,
        [Parameter(Mandatory = $false)]
        [string[]]$DeleteFiles = $null
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

    $applications = [Array](Get-MDTApplication -Module $Module -MDTDriveName $MDTDriveName -Guid $Module.Params.guid -Name $Module.Params.name)
    $application = $applications[0]

    if ($null -ne $AddPaths) {

        foreach ($addPath in $AddPaths) {

            if (Test-Path -LiteralPath "$($addPath)\$($application.Name)" -PathType Leaf) {
                continue
            }

            $sourcePath = $application.PSPath -replace [regex]::Escape($pathPrefix), ""

            Copy-Item -LiteralPath $sourcePath -Destination $addPath | Out-Null
        }
    }

    if ($PublisherEmpty) {
        $application.Item("Publisher") = ""
    }
    elseif (-not [string]::IsNullOrEmpty($Publisher)) {
        $application.Item("Publisher") = $Publisher
    }

    if (-not [string]::IsNullOrEmpty($ShortName)) {
        $application.Item("ShortName") = $ShortName
    }

    if ($VersionEmpty) {
        $application.Item("Version") = ""
    }
    elseif (-not [string]::IsNullOrEmpty($Version)) {
        $application.Item("Version") = $Version
    }

    if ($LanguageEmpty) {
        $application.Item("Language") = ""
    }
    elseif (-not [string]::IsNullOrEmpty($Language)) {
        $application.Item("Language") = $Language
    }

    if ($CommandLineNull) {
        $application.Item("CommandLine") = [System.DBNull]::Value
    }
    elseif (-not [string]::IsNullOrEmpty($CommandLine)) {
        $application.Item("CommandLine") = $CommandLine
    }

    if ($WorkingDirectoryNull) {
        $application.Item("WorkingDirectory") = [System.DBNull]::Value
    }
    elseif ($WorkingDirectoryEmpty) {
        $application.Item("WorkingDirectory") = ""
    }
    elseif (-not [string]::IsNullOrEmpty($WorkingDirectory)) {
        $application.Item("WorkingDirectory") = $WorkingDirectory
    }

    if ($CommentsEmpty) {
        $application.Item("Comments") = ""
    }
    elseif (-not [string]::IsNullOrEmpty($Comments)) {
        $application.Item("Comments") = $Comments
    }

    if ($null -ne $Enabled) {

        if ($Enabled) {
            $application.Item("enable") = "True"
        }
        else {
            $application.Item("enable") = "False"
        }
    }

    if ($null -ne $Hidden) {

        if ($Hidden) {
            $application.Item("hide") = "True"
        }
        else {
            $application.Item("hide") = "False"
        }
    }

    if ($null -ne $Reboot) {

        if ($Reboot) {
            $application.Item("Reboot") = "True"
        }
        else {
            $application.Item("Reboot") = "False"
        }
    }

    if ($SourceNull) {
        $application.Item("Source") = [System.DBNull]::Value
    }
    elseif (-not [string]::IsNullOrEmpty($Source)) {
        $application.Item("Source") = $Source
    }

    if (-not [string]::IsNullOrEmpty($Name)) {
        $application.RenameItem($Name) | Out-Null
    }

    if ($null -ne $RemovePaths) {

        foreach ($removePath in $RemovePaths) {

            if (Test-Path -LiteralPath $removePath -PathType Leaf) {
                Remove-Item -LiteralPath $removePath | Out-Null
            }
        }
    }

    $application = Get-MDTApplication -Module $Module -MDTDriveName $MDTDriveName -Guid $Module.Params.guid -Name $Module.Params.name |
        Format-MDTApplication -Module $Module -MDTDriveName $MDTDriveName -IncludeFiles

    $Module.Result.application = $application
    $Module.Diff.after = $application
}

function Remove-MDTApplication {
    <#
    .SYNOPSIS
    Removes an MDT application.

    .DESCRIPTION
    This function removes an MDT application.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The MDT drive name.

    .EXAMPLE
    Remove-MDTApplication -Module $Module -MDTDriveName "DS001"
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

    $applications = [Array](Get-MDTApplication -Module $Module -MDTDriveName $MDTDriveName -Guid $Module.Params.guid -Name $Module.Params.name)

    if ($null -eq $applications) {
        return
    }

    $pathPrefix = "MicrosoftDeploymentToolkit\MDTProvider::"

    foreach ($application in $applications) {

        $applicationPath = $application.PSPath -replace [regex]::Escape($pathPrefix), ""
        Remove-Item -LiteralPath $applicationPath | Out-Null
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
            choices = @('source', 'no_source', 'bundle')
        }
        publisher = @{
            type = 'str'
            required = $false
        }
        short_name = @{
            type = 'str'
            required = $false
        }
        version = @{
            type = 'str'
            required = $false
        }
        language = @{
            type = 'str'
            required = $false
        }
        command_line = @{
            type = 'str'
            required = $false
        }
        working_directory = @{
            type = 'path'
            required = $false
        }
        source_path = @{
            type = 'path'
            required = $false
        }
        destination_folder = @{
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
        reboot = @{
            type = 'bool'
            required = $false
        }
        state = @{
            type = 'str'
            required = $false
            default = 'present'
            choices = @('present', 'absent')
        }
    }
    required_if = @(
        , @('state', 'present', @('type', 'short_name'))
    )
    required_one_of = @(
        , @('name', 'guid')
    )
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$module | Confirm-ApplicationParamsAreValid | Out-Null
Import-MDTModule -Module $module | Out-Null

$mdtDrive = Get-MDTPSDrive -Module $module -ReadWrite

$existing = Get-MDTApplication -Module $module -MDTDriveName $mdtDrive.Name -Guid $module.Params.guid -Name $module.Params.name |
    Format-MDTApplication -Module $module -MDTDriveName $mdtDrive.Name -IncludeFiles

$state = $module.Params.state

$module.Diff.before = $existing
$module.Result.changed = $false

if ($state -eq "present") {

    $expected = Get-ExpectedApplication -Module $module -Existing $existing

    foreach ($path in $expected.paths) {

        $pathSegments = $path -split "\\" | Where-Object { -not [string]::IsNullOrEmpty($_) }
        $fullPath = @(@("Applications"); $pathSegments) | Get-FullPath -MDTDriveName $mdtDrive.Name

        if (-not (Test-Path -LiteralPath $fullPath -PathType Container)) {
            $module.FailJson("The directory 'Applications\$($path)' does not exist in the MDT share.")
        }
    }

    $module.Diff.after = $expected
    $module.Result.application = $expected

    if ($null -eq $existing) {
        New-MDTApplication -Module $module -MDTDriveName $mdtDrive.Name -Expected $expected | Out-Null
    }
    else {

        $propertyChanges = Compare-ExpectedApplicationToExisting -Module $module -MDTDriveName $mdtDrive.Name -Expected $expected -Existing $existing

        if ($propertyChanges.Count -gt 0) {

            $module.Result.changed = $true
            Set-MDTApplication -Module $module -MDTDriveName $mdtDrive.Name @propertyChanges | Out-Null
        }
    }
}
elseif ($state -eq "absent") {

    $module.Diff.after = $null

    if ($null -ne $existing) {
        $module.Result.changed = $true
        Remove-MDTApplication -Module $Module -MDTDriveName $mdtDrive.Name | Out-Null
    }
}

$mdtDrive | Remove-PSDrive | Out-Null

$module.ExitJson()
