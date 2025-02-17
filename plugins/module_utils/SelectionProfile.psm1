function Get-MDTSelectionProfile {
    <#
    .SYNOPSIS
    Gets MDT selection profile objects.

    .DESCRIPTION
    This function returns MDT selection profiles within the MDT share that match the supplied criteria.
    Each object returned represents a path at which an selection profile is found.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The MDT drive name.

    .PARAMETER Guid
    The GUID of the MDT selection profile.

    .PARAMETER Name
    The name of the MDT selection profile.

    .EXAMPLE
    Get-MDTSelectionProfile -Module $Module -MDTDriveName "DS001"

    This example gets all MDT selection profiles within the MDT share with the drive name "DS001".

    .EXAMPLE
    Get-MDTSelectionProfile -Module $Module -MDTDriveName "DS001" -Guid "{12345678-1234-1234-1234-123456789012}"

    This example gets all paths of an MDT selection profile with the GUID "{12345678-1234-1234-1234-123456789012}" within the MDT share with
    the drive name "DS001".

    .EXAMPLE
    Get-MDTSelectionProfile -Module $Module -MDTDriveName "DS001" -Name "Operating System Name"

    This example gets all paths of an MDT selection profile with the name "Operating System Name" within the MDT share with the drive name "DS001".

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

    $selectionProfiles = Get-ChildItem -LiteralPath "$($MDTDriveName):\Selection Profiles" -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.GetType() -eq [Microsoft.BDD.PSSnapIn.MDTObject] -and $_.NodeType -eq "SelectionProfile" }

    if ( -not [string]::IsNullOrEmpty($Guid)) {

        $guidMatch = $selectionProfiles | Where-Object { $_.guid -ieq $Guid }

        if ($null -ne $guidMatch) {
            return $guidMatch
        }

        if (-not [string]::IsNullOrEmpty($Name)) {

            $nameMatch = $selectionProfiles | Where-Object { $_.Name -eq $Name }

            if ($null -ne $nameMatch) {
                $Module.FailJson("No MDT selection profile found with GUID '$($Guid)' but selection profile named '$($Name)' already exists.")
            }
        }

        return $null
    }

    if ( -not [string]::IsNullOrEmpty($Name)) {
        return $selectionProfiles | Where-Object { $_.Name -eq $Name }
    }

    return $selectionProfiles
}

function Format-MDTSelectionProfile {
    <#
    .SYNOPSIS
    Formats an MDT selection profile to a custom object.

    .DESCRIPTION
    This function formats MDT selection profile objects into a custom object.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The MDT drive name.

    .PARAMETER SelectionProfile
    The MDT selection profile to convert.
    These should be Microsoft.BDD.PSSnapIn.MDTObject objects representing the same selection profile.
    The first selection profile in the array will be used to determine the shared properties.
    The path of each selection profile will be added to the 'paths' property of the formatted custom object.

    .EXAMPLE
    Format-MDTSelectionProfile -Module $Module -MDTDriveName "DS001" -SelectionProfile $SelectionProfile

    This example converts an array of MDT selection profiles into a formatted custom object within the MDT share with the drive name "DS001".

    .OUTPUTS
    System.Collections.Hashtable
    #>

    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [AllowNull()]
        [Microsoft.BDD.PSSnapIn.MDTObject]$SelectionProfile
    )

    begin {
        $formattedSelectionProfiles = New-Object -TypeName System.Collections.Generic.List[System.Collections.Hashtable]
    }

    process {

        if ($null -eq $SelectionProfile) {
            return $null
        }

        $existingSelectionProfile = $formattedSelectionProfiles | Where-Object { $_.guid -eq $SelectionProfile.guid }

        if ($null -ne $existingSelectionProfile) {
            return $null
        }

        $formattedSelectionProfile = @{
            guid = $SelectionProfile.guid
            name = $SelectionProfile.Name
            read_only = [bool]::Parse($SelectionProfile.ReadOnly)
        }

        $definitionXML = [XML]$SelectionProfile.Definition
        $includedDirectoriesXML = $definitionXML.GetElementsByTagName("Include")

        $definitionPaths = New-Object -TypeName System.Collections.ArrayList

        foreach ($includedDirectoryXML in $includedDirectoriesXML) {
            $definitionPaths.Add($includedDirectoryXML.path) | Out-Null
        }

        $formattedSelectionProfile.definition = [string[]]$definitionPaths.ToArray()

        if ($SelectionProfile.Comments.GetType() -eq [System.DBNull]) {
            $formattedSelectionProfile.comments = ""
        }
        else {
            $formattedSelectionProfile.comments = $SelectionProfile.Comments
        }

        if ($SelectionProfile.enable.GetType() -eq [System.DBNull]) {
            $formattedSelectionProfile.enabled = $true
        }
        else {
            $formattedSelectionProfile.enabled = [bool]::Parse($SelectionProfile.enable)
        }

        if ($SelectionProfile.hide.GetType() -eq [System.DBNull]) {
            $formattedSelectionProfile.hidden = $false
        }
        else {
            $formattedSelectionProfile.hidden = [bool]::Parse($SelectionProfile.hide)
        }

        $formattedSelectionProfiles.Add($formattedSelectionProfile) | Out-Null
    }

    end {
        return [System.Collections.Hashtable[]] $formattedSelectionProfiles.ToArray()
    }
}

function Convert-PathsToMDTSelectionProfileDefinition {
    <#
    .SYNOPSIS
    Converts paths to an MDT selection profile definition.

    .DESCRIPTION
    This function converts paths to an MDT selection profile definition.

    .PARAMETER Paths
    The paths to convert.

    .EXAMPLE
    Convert-PathsToMDTSelectionProfileDefinition -Paths @("Operating Systems\Path1", "Out-of-Box Drivers\Path2")

    This example converts the paths "Operating Systems\Path1" and "Out-of-Box Drivers\Path2" to an MDT selection profile definition.

    .OUTPUTS
    string
    #>

    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [AllowNull()]
        [string[]]$Paths
    )

    $xmlDocument = New-Object -TypeName System.Xml.XmlDocument

    $selectionProfileElement = $xmlDocument.CreateElement("SelectionProfile")

    if ($null -ne $Paths) {

        foreach ($path in $Paths) {
            $includeElement = $xmlDocument.CreateElement("Include")
            $includeElement.SetAttribute("path", $path) | Out-Null
            $selectionProfileElement.AppendChild($includeElement) | Out-Null
        }
    }

    return $selectionProfileElement.OuterXml
}

$exportMembers = @{
    Function = 'Get-MDTSelectionProfile', `
        'Format-MDTSelectionProfile', `
        'Convert-PathsToMDTSelectionProfileDefinition'
}

Export-ModuleMember @exportMembers
