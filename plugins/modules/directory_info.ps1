#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.Common
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.Application
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.Driver
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.OperatingSystem
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.SelectionProfile
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.TaskSequence

function Confirm-DirectoryInfoParamsAreValid {
    <#
    .SYNOPSIS
    Confirms that the parameters are valid.

    .DESCRIPTION
    This function confirms that the parameters are valid.

    .PARAMETER Module
    The Ansible module.

    .EXAMPLE
    Confirm-DirectoryInfoParamsAreValid -Module $Module
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [Ansible.Basic.AnsibleModule]$Module
    )

    process {

        $Module.Params.path = $Module.Params.path | Format-MDTPath
        $Module.Params.path | Confirm-MDTPathIsValid -Module $Module -ParameterName "path" | Out-Null

        if ([string]::IsNullOrEmpty($Module.Params.path)) {
            $Module.FailJson("The 'path' parameter cannot be empty.")
        }
    }
}

function Format-MDTObject {
    <#
    .SYNOPSIS
    Formats an MDT object.

    .DESCRIPTION
    This function formats an MDT object.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The name of the MDT drive.

    .PARAMETER Object
    The MDT object.

    .EXAMPLE
    Format-MDTObject -Module $module -MDTDriveName "DS001" -Object $directory

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
        [Microsoft.BDD.PSSnapIn.MDTObject]$Object
    )

    $recurse = $Module.Params.recurse
    $path = $Module.Params.path

    $objectPath = $Object.PSPath -replace [regex]::Escape("MicrosoftDeploymentToolkit\MDTProvider::$($MDTDriveName):\"), ""

    if ($Object.PSIsContainer -and ($recurse -or $objectPath -ieq $path)) {

        $fullPath = "$($MDTDriveName):\$($objectPath)"
        $contentObjects = [Array](Get-ChildItem -LiteralPath $fullPath)

        if ($null -eq $contentObjects) {
            $contentObjects = [Array]@()
        }

        $contents = New-Object System.Collections.Generic.List[System.Collections.Hashtable]

        foreach ($contentObject in $contentObjects) {

            $contentObject = Format-MDTObject -Module $Module -MDTDriveName $MDTDriveName -Object $contentObject

            $contents.Add($contentObject) | Out-Null
        }
    }

    switch ($Object.NodeType) {
        "Application" {

            $application = $Object | Format-MDTApplication -Module $Module -MDTDriveName $MDTDriveName -ExcludePaths
            $application.application_type = $application.type
            $application.type = "application"

            return $application
        }
        "ApplicationFolder" {

            $applicationFolder = @{
                guid = $Object.guid
                name = $Object.Name
                type = "application_folder"
                enabled = [bool]::Parse($Object.enable)
            }

            if ($Object.Comments.GetType() -eq [System.DBNull]) {
                $applicationFolder.comments = $null
            }
            else {
                $applicationFolder.comments = $Object.Comments
            }

            if ($null -ne $contents) {
                $applicationFolder.contents = [System.Collections.Hashtable[]]$contents.ToArray()
            }

            return $applicationFolder
        }
        "Driver" {

            $driver = $Object | Format-MDTDriver -Module $Module -MDTDriveName $MDTDriveName -ExcludePaths
            $driver.type = "driver"

            return $driver
        }
        "DriverFolder" {

            $driverFolder = @{
                guid = $Object.guid
                name = $Object.Name
                type = "driver_folder"
                enabled = [bool]::Parse($Object.enable)
            }

            if ($Object.Comments.GetType() -eq [System.DBNull]) {
                $driverFolder.comments = $null
            }
            else {
                $driverFolder.comments = $Object.Comments
            }

            if ($null -ne $contents) {
                $driverFolder.contents = [System.Collections.Hashtable[]]$contents.ToArray()
            }

            return $driverFolder
        }
        "LinkedDeploymentShareFolder" {

            $linkedDeploymentShareFolder = @{
                guid = $Object.guid
                name = $Object.Name
                type = "driver_folder"
                enabled = [bool]::Parse($Object.enable)
            }

            if ($Object.Comments.GetType() -eq [System.DBNull]) {
                $linkedDeploymentShareFolder.comments = $null
            }
            else {
                $linkedDeploymentShareFolder.comments = $Object.Comments
            }

            if ($null -ne $contents) {
                $linkedDeploymentShareFolder.contents = [System.Collections.Hashtable[]]$contents.ToArray()
            }

            return $linkedDeploymentShareFolder
        }
        "MediaFolder" {

            $mediaFolder = @{
                guid = $Object.guid
                name = $Object.Name
                type = "linked_deployment_share_folder"
                enabled = [bool]::Parse($Object.enable)
            }

            if ($Object.Comments.GetType() -eq [System.DBNull]) {
                $mediaFolder.comments = $null
            }
            else {
                $mediaFolder.comments = $Object.Comments
            }

            if ($null -ne $contents) {
                $mediaFolder.contents = [System.Collections.Hashtable[]]$contents.ToArray()
            }

            return $mediaFolder
        }
        "OperatingSystem" {

            $operatingSystem = $Object | Format-MDTOperatingSystem -Module $Module -MDTDriveName $MDTDriveName -ExcludePaths
            $operatingSystem.os_type = $operatingSystem.type
            $operatingSystem.type = "operating_system"

            return $operatingSystem
        }
        "OperatingSystemFolder" {

            $operatingSystemFolder = @{
                guid = $Object.guid
                name = $Object.Name
                type = "operating_system_folder"
                enabled = [bool]::Parse($Object.enable)
            }

            if ($Object.Comments.GetType() -eq [System.DBNull]) {
                $operatingSystemFolder.comments = $null
            }
            else {
                $operatingSystemFolder.comments = $Object.Comments
            }

            if ($null -ne $contents) {
                $operatingSystemFolder.contents = [System.Collections.Hashtable[]]$contents.ToArray()
            }

            return $operatingSystemFolder
        }
        "PackageFolder" {

            $packageFolder = @{
                guid = $Object.guid
                name = $Object.Name
                type = "package_folder"
                enabled = [bool]::Parse($Object.enable)
            }

            if ($Object.Comments.GetType() -eq [System.DBNull]) {
                $packageFolder.comments = $null
            }
            else {
                $packageFolder.comments = $Object.Comments
            }

            if ($null -ne $contents) {
                $packageFolder.contents = [System.Collections.Hashtable[]]$contents.ToArray()
            }

            return $packageFolder
        }
        "SelectionProfile" {

            $selectionProfile = $Object | Format-MDTSelectionProfile -Module $Module -MDTDriveName $MDTDriveName
            $selectionProfile.type = "selection_profile"

            return $selectionProfile
        }
        "SelectionProfileFolder" {

            $selectionProfileFolder = @{
                guid = $Object.guid
                name = $Object.Name
                type = "selection_profile_folder"
                enabled = [bool]::Parse($Object.enable)
            }

            if ($Object.Comments.GetType() -eq [System.DBNull]) {
                $selectionProfileFolder.comments = $null
            }
            else {
                $selectionProfileFolder.comments = $Object.Comments
            }

            if ($null -ne $contents) {
                $selectionProfileFolder.contents = [System.Collections.Hashtable[]]$contents.ToArray()
            }

            return $selectionProfileFolder
        }
        "TaskSequence" {

            $taskSequence = $Object | Format-MDTTaskSequence -Module $Module -MDTDriveName $MDTDriveName -ExcludePaths
            $taskSequence.type = "task_sequence"

            return $taskSequence
        }
        "TaskSequenceFolder" {

            $taskSequenceFolder = @{
                guid = $Object.guid
                name = $Object.Name
                type = "task_sequence_folder"
                enabled = [bool]::Parse($Object.enable)
            }

            if ($Object.Comments.GetType() -eq [System.DBNull]) {
                $taskSequenceFolder.comments = $null
            }
            else {
                $taskSequenceFolder.comments = $Object.Comments
            }

            if ($null -ne $contents) {
                $taskSequenceFolder.contents = [System.Collections.Hashtable[]]$contents.ToArray()
            }

            return $taskSequenceFolder
        }
        Default {

            return @{
                guid = $Object.guid
                name = $Object.Name
                type = $Object.NodeType
            }
        }
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
        path = @{
            type = 'str'
            required = $true
        }
        recurse = @{
            type = 'bool'
            required = $false
            default = $false
        }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$module | Confirm-DirectoryInfoParamsAreValid | Out-Null
Import-MDTModule -Module $module | Out-Null

$mdtDrive = Get-MDTPSDrive -Module $module

$path = $module.Params.path
$fullPath = "$($mdtDrive.Name):\$($path)"

$module.Result.changed = $false

if (Test-Path -LiteralPath $fullPath -PathType Leaf) {
    $module.FailJson("The specified path is a file, not a directory.")
}

$module.Result.exists = Test-Path -LiteralPath $fullPath -PathType Container

if ($module.Result.exists) {
    $directory = Get-Item -LiteralPath $fullPath
    $module.Result.directory = Format-MDTObject -Module $module -MDTDriveName $mdtDrive.Name -Object $directory
}

$mdtDrive | Remove-PSDrive | Out-Null

$module.ExitJson()
