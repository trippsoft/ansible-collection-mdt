function Get-MDTApplication {
    <#
    .SYNOPSIS
    Gets MDT application objects.

    .DESCRIPTION
    This function returns MDT applications within the MDT share that match the supplied criteria.
    Each object returned represents a path at which an application is found.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The MDT drive name.

    .PARAMETER Guid
    The GUID of the MDT application.

    .PARAMETER Name
    The name of the MDT application.

    .EXAMPLE
    Get-MDTApplication -Module $Module -MDTDriveName "DS001"

    This example gets all MDT applications within the MDT share with the drive name "DS001".

    .EXAMPLE
    Get-MDTApplication -Module $Module -MDTDriveName "DS001" -Guid "{12345678-1234-1234-1234-123456789012}"

    This example gets all paths of an MDT application with the GUID "{12345678-1234-1234-1234-123456789012}" within the MDT share with the drive name "DS001".

    .EXAMPLE
    Get-MDTApplication -Module $Module -MDTDriveName "DS001" -Name "Application Name"

    This example gets all paths of an MDT application with the name "Application Name" within the MDT share with the drive name "DS001".

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

    $applications = Get-ChildItem -LiteralPath "$($MDTDriveName):\Applications" -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.GetType() -eq [Microsoft.BDD.PSSnapIn.MDTObject] -and $_.NodeType -eq "Application" }

    if ( -not [string]::IsNullOrEmpty($Guid)) {

        $guidMatch = $applications | Where-Object { $_.guid -ieq $Guid }

        if ($null -ne $guidMatch) {
            return $guidMatch
        }

        if (-not [string]::IsNullOrEmpty($Name)) {

            $nameMatch = $applications | Where-Object { $_.Name -eq $Name }

            if ($null -ne $nameMatch) {
                $Module.FailJson("No MDT application found with GUID '$($Guid)' but application named '$($Name)' already exists.")
            }
        }

        return $null
    }

    if ( -not [string]::IsNullOrEmpty($Name)) {
        return $applications | Where-Object { $_.Name -eq $Name }
    }

    return $applications
}

function Format-MDTApplication {
    <#
    .SYNOPSIS
    Formats an MDT application to a custom object.

    .DESCRIPTION
    This function formats MDT application objects into a custom object.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The MDT drive name.

    .PARAMETER Application
    The MDT application to convert.
    These should be Microsoft.BDD.PSSnapIn.MDTObject objects representing the same application.
    The first application in the array will be used to determine the shared properties.
    The path of each application will be added to the 'paths' property of the formatted custom object.

    .EXAMPLE
    Format-MDTApplication -Module $Module -MDTDriveName "DS001" -Applications $Applications

    This example converts an array of MDT applications into a formatted custom object within the MDT share with the drive name "DS001".

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
        [Microsoft.BDD.PSSnapIn.MDTObject]$Application,
        [Switch]$ExcludePaths,
        [Switch]$IncludeFiles
    )

    begin {
        $pathPrefix = "MicrosoftDeploymentToolkit\MDTProvider::$($MDTDriveName):\Applications"
        $formattedApplications = New-Object -TypeName System.Collections.Generic.List[System.Collections.Hashtable]
    }

    process {

        if ($null -eq $Application) {
            return
        }

        $existingApplication = $formattedApplications | Where-Object { $_.guid -eq $Application.guid }

        if ($null -ne $existingApplication) {

            if ($ExcludePaths) {
                return
            }

            $path = $Application.PSParentPath -replace [regex]::Escape($pathPrefix), ""
            $path = $path.Trim('\')

            $existingApplication.paths = [string[]] @( $existingApplication.paths; @($path))

            return
        }

        $formattedApplication = @{
            guid = $Application.guid
            name = $Application.Name
            publisher = $Application.Publisher
            short_name = $Application.ShortName
            version = $Application.Version
            language = $Application.Language
        }

        if ($application.CommandLine.GetType() -eq [System.DBNull]) {
            $formattedApplication["type"] = "bundle"
        }
        elseif ($application.Source.GetType() -eq [System.DBNull]) {

            $formattedApplication["type"] = "no_source"
            $formattedApplication["command_line"] = $application.CommandLine
            $formattedApplication["working_directory"] = $application.WorkingDirectory
        }
        else {

            $mdtSharePath = $Module.Params.mdt_share_path

            $filesPath = $application.Source
            $filesPath = $filesPath -replace [regex]::Escape('.'), $mdtSharePath

            $formattedApplication["type"] = "source"
            $formattedApplication["command_line"] = $application.CommandLine
            $formattedApplication["working_directory"] = $application.WorkingDirectory
            $formattedApplication["files_path"] = $filesPath
        }

        if ($application.Comments.GetType() -eq [System.DBNull]) {
            $formattedApplication["comments"] = ""
        }
        else {
            $formattedApplication["comments"] = $application.Comments
        }

        if ($application.enable.GetType() -eq [System.DBNull]) {
            $formattedApplication["enabled"] = $true
        }
        else {
            $formattedApplication["enabled"] = [bool]::Parse($application.enable)
        }

        if ($application.hide.GetType() -eq [System.DBNull]) {
            $formattedApplication["hidden"] = $false
        }
        else {
            $formattedApplication["hidden"] = [bool]::Parse($application.hide)
        }

        if ($application.Reboot.GetType() -eq [System.DBNull]) {
            $formattedApplication["reboot"] = $false
        }
        else {
            $formattedApplication["reboot"] = [bool]::Parse($application.Reboot)
        }

        $formattedDependencies = New-Object -TypeName System.Collections.Generic.List[System.Collections.Hashtable]

        foreach ($dependency in $application.Dependency) {

            $dependencyApplications = [Array](Get-MDTApplication -Module $Module -MDTDriveName $MDTDriveName -Guid $dependency)

            if ($null -eq $dependencyApplications) {

                $formattedDependency = @{
                    guid = $dependency
                }
            }
            else {
                $dependencyApplication = $dependencyApplications[0]
                $formattedDependency = Format-MDTApplicationDependency -Module $Module -MDTDriveName $MDTDriveName -Application $dependencyApplication
            }

            $formattedDependencies.Add($formattedDependency)
        }

        $formattedApplication["dependencies"] = $formattedDependencies.ToArray()

        if (-not $ExcludePaths) {
            $path = $Application.PSParentPath -replace [regex]::Escape($pathPrefix), ""
            $path = $path.Trim('\')
            $formattedApplication["paths"] = [string[]] @($path)
        }

        if ($IncludeFiles -and $formattedApplication["type"] -eq "source") {
            $files = [Array](Format-MDTFilesValue -DirectoryPath $formattedApplication["files_path"])

            if ($null -ne $files) {
                $formattedApplication["files"] = $files
            }
            else {
                $formattedApplication["files"] = @()
            }
        }

        $formattedApplications.Add($formattedApplication)
    }

    end {
        return [System.Collections.Hashtable[]] $formattedApplications.ToArray()
    }
}

function Format-MDTApplicationDependency {
    <#
    .SYNOPSIS
    Convert an MDT application to a formatted custom object for a dependency.

    .DESCRIPTION
    This function converts an MDT application object into a formatted custom object for a dependency.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The MDT drive name.

    .PARAMETER Application
    The MDT application to convert.

    .EXAMPLE
    Format-MDTApplicationDependency -Module $Module -MDTDriveName "DS001" -Application $Application

    This example converts an MDT application into a formatted custom object for a dependency within the MDT share with the drive name "DS001".

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
        [Microsoft.BDD.PSSnapIn.MDTObject]$Application
    )

    begin {
        $formattedDependencies = New-Object -TypeName System.Collections.Generic.List[System.Collections.Hashtable]
    }

    process {

        if ($null -eq $Application) {
            return
        }

        $existingDependency = $formattedDependencies | Where-Object { $_.guid -eq $Application.guid }

        if ($null -ne $existingDependency) {
            return
        }

        $formattedDependency = @{
            guid = $Application.guid
            name = $Application.Name
        }

        $formattedDependencies.Add($formattedDependency)
    }

    end {
        return [System.Collections.Hashtable[]] $formattedDependencies.ToArray()
    }
}

$exportMembers = @{
    Function = 'Get-MDTApplication', `
        'Format-MDTApplication', `
        'Format-MDTApplicationFilesValue', `
        'Format-MDTApplicationDependency'
}

Export-ModuleMember @exportMembers
