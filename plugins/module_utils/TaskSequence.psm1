function Get-MDTTaskSequence {
    <#
    .SYNOPSIS
    Gets MDT task sequence objects.

    .DESCRIPTION
    This function returns MDT task sequences within the MDT share that match the supplied criteria.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The MDT drive name.

    .PARAMETER Guid
    The GUID of the MDT task sequence.

    .PARAMETER Id
    The ID of the MDT task sequence.

    .PARAMETER Name
    The name of the MDT task sequence.

    .EXAMPLE
    Get-MDTTaskSequence -Module $Module -MDTDriveName "DS001"

    This example gets all MDT task sequences within the MDT share with the drive name "DS001".

    .EXAMPLE
    Get-MDTTaskSequence -Module $Module -MDTDriveName "DS001" -Guid "{12345678-1234-1234-1234-123456789012}"

    This example gets all paths of an MDT task sequence with the GUID "{12345678-1234-1234-1234-123456789012}" within the MDT share with
    the drive name "DS001".

    .EXAMPLE
    Get-MDTTaskSequence -Module $Module -MDTDriveName "DS001" -Id "ID1"

    This example gets all paths of an MDT task sequence with the ID "ID1" within the MDT share with the drive name "DS001".

    .EXAMPLE
    Get-MDTTaskSequence -Module $Module -MDTDriveName "DS001" -Name "Task Sequence Name"

    This example gets all paths of an MDT task sequence with the name "Task Sequence Name" within the MDT share with the drive name "DS001".

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
        [string]$Id,
        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]$Name
    )

    $taskSequences = Get-ChildItem -LiteralPath "$($MDTDriveName):\Task Sequences" -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.GetType() -eq [Microsoft.BDD.PSSnapIn.MDTObject] -and $_.NodeType -eq "TaskSequence" }

    if (-not [string]::IsNullOrEmpty($Id)) {

        $idMatch = $taskSequences | Where-Object { $_.ID -eq $Id }

        if ($null -ne $idMatch) {
            return $idMatch
        }

        if (-not [string]::IsNullOrEmpty($Name)) {

            $nameMatch = $taskSequences | Where-Object { $_.Name -eq $Name }

            if ($null -ne $nameMatch) {
                $Module.FailJson("No MDT task sequence found with ID '$($Id)' but task sequence named '$($Name)' already exists.")
            }
        }

        return $null
    }

    if (-not [string]::IsNullOrEmpty($Name)) {
        return $taskSequences | Where-Object { $_.Name -eq $Name }
    }

    return $taskSequences
}

function Confirm-TaskSequenceIdIsValid {
    <#
    .SYNOPSIS
    Confirms the specified ID contains only valid characters.

    .DESCRIPTION
    This function confirms the specified ID contains only valid characters.
    If the name contains any invalid characters, the function will fail the Ansible module.
    Valid characters include ASCII letters, digits, and the following symbols: ~!@#$^&()_-+={};,.

    .PARAMETER Module
    The Ansible module object.

    .PARAMETER ParameterName
    The name of the parameter being validated.

    .PARAMETER Value
    The value to validate.

    .EXAMPLE
    "MyName" | Confirm-TaskSequenceIDIsValid -Module $Module -ParameterName "name"

    .INPUTS
    string
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [string]$ParameterName,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]$Value
    )

    process {

        if ([string]::IsNullOrEmpty($Value)) {
            return
        }

        $characters = $Value.ToCharArray()

        if ($characters -contains " ") {
            $Module.FailJson("The value of the parameter '$ParameterName' cannot contain spaces.")
        }

        if ($characters.Length -gt 16) {
            $Module.FailJson("The value of the parameter '$ParameterName' cannot exceed 16 characters.")
        }

        $Value | Confirm-NameIsValid -Module $Module -ParameterName $ParameterName
    }
}

function Format-MDTTaskSequence {
    <#
    .SYNOPSIS
    Formats an MDT task sequence object.

    .DESCRIPTION
    This function formats an MDT task sequence object into a hashtable.

    .PARAMETER TaskSequence
    The MDT task sequence object.

    .OUTPUTS
    Hashtable
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
        [Microsoft.BDD.PSSnapIn.MDTObject]$TaskSequence,
        [switch]$ExcludePaths,
        [switch]$IncludeSecrets
    )

    begin {
        $pathPrefix = "MicrosoftDeploymentToolkit\MDTProvider::$($MDTDriveName):\Task Sequences"
        $formattedTaskSequences = New-Object -TypeName System.Collections.Generic.List[System.Collections.Hashtable]
    }

    process {

        if ($null -eq $TaskSequence) {
            return
        }

        $existingTaskSequence = $formattedTaskSequences | Where-Object { $_.guid -eq $TaskSequence.guid }

        if ($null -ne $existingTaskSequence) {

            if ($ExcludePaths) {
                return
            }

            $path = $TaskSequence.PSParentPath -replace [regex]::Escape($pathPrefix), ""
            $path = $path.Trim('\')

            $existingTaskSequence.paths = [string[]] @( $existingTaskSequence.paths; @($path))

            return
        }

        $formattedTaskSequence = @{
            guid = $TaskSequence.guid
            name = $TaskSequence.Name
            id = $TaskSequence.ID
            template = $TaskSequence.TaskSequenceTemplate
            version = $TaskSequence.Version
        }

        if ($TaskSequence.Comments.GetType() -eq [System.DBNull]) {
            $formattedTaskSequence.comments = ""
        }
        else {
            $formattedTaskSequence.comments = $TaskSequence.Comments
        }

        if ($TaskSequence.enable.GetType() -eq [System.DBNull]) {
            $formattedTaskSequence.enabled = $true
        }
        else {
            $formattedTaskSequence.enabled = [bool]::Parse($TaskSequence.enable)
        }

        if ($TaskSequence.hide.GetType() -eq [System.DBNull]) {
            $formattedTaskSequence.hidden = $false
        }
        else {
            $formattedTaskSequence.hidden = [bool]::Parse($TaskSequence.hide)
        }

        if (-not $ExcludePaths) {
            $path = $TaskSequence.PSParentPath -replace [regex]::Escape($pathPrefix), ""
            $path = $path.Trim('\')
            $formattedTaskSequence.paths = [string[]] @($path)
        }

        $tsDirectory = $TaskSequence.GetPhysicalSourcePath()

        $tsXml = [XML](Get-Content -LiteralPath "$($tsDirectory)\ts.xml")

        $operatingSystemGuid = $tsXml.sequence.globalVarList.variable | Where-Object { $_.name -eq "OSGUID" } | Select-Object -ExpandProperty '#text'

        $operatingSystem = Get-MDTOperatingSystem -Module $Module -MDTDriveName $MDTDriveName -Guid $operatingSystemGuid |
            Format-MDTOperatingSystem -Module $Module -MDTDriveName $MDTDriveName -ExcludePaths

        if ($null -eq $operatingSystem) {
            $formattedTaskSequence.operating_system = @{
                guid = $operatingSystemGuid
            }
        }
        else {
            $formattedTaskSequence.operating_system = @{
                guid = $operatingSystem.guid
                name = $operatingSystem.name
            }
        }

        $unattendXml = [XML](Get-Content -LiteralPath "$($tsDirectory)\unattend.xml")

        $windowsPEXml = $unattendXml.unattend.settings | Where-Object { $_.pass -eq "windowsPE" }
        $setupXml = $windowsPEXml.component | Where-Object { $_.name -eq "Microsoft-Windows-Setup" }

        $specializeXml = $unattendXml.unattend.settings | Where-Object { $_.pass -eq "specialize" }
        $shellSetupXml = $specializeXml.component | Where-Object { $_.name -eq "Microsoft-Windows-Shell-Setup" }

        $oobeSystemXml = $unattendXml.unattend.settings | Where-Object { $_.pass -eq "oobeSystem" }
        $oobeShellSetupXml = $oobeSystemXml.component | Where-Object { $_.name -eq "Microsoft-Windows-Shell-Setup" }

        $formattedTaskSequence.full_name = $shellSetupXml.RegisteredOwner
        $formattedTaskSequence.organization = $shellSetupXml.RegisteredOrganization

        $ieXml = $specializeXml.component | Where-Object { $_.name -eq "Microsoft-Windows-IE-InternetExplorer" }

        $formattedTaskSequence.ie_home_page = $ieXml.Home_Page

        $retailKey = $setupXml.UserData.ProductKey.Key
        $makKey = $shellSetupXml.ProductKey
        $adminPassword = $oobeShellSetupXml.UserAccounts.AdministratorPassword.Value

        if (-not [string]::IsNullOrWhiteSpace($retailKey)) {

            $formattedTaskSequence.product_key_type = "retail"

            if ($IncludeSecrets) {
                $formattedTaskSequence.product_key = $retailKey
            }
        }
        elseif (-not [string]::IsNullOrWhiteSpace($makKey)) {

            $formattedTaskSequence.product_key_type = "mak"

            if ($IncludeSecrets) {
                $formattedTaskSequence.product_key = $makKey
            }
        }
        else {
            $formattedTaskSequence.product_key_type = "none"
        }

        if ($IncludeSecrets -and -not [string]::IsNullOrWhiteSpace($adminPassword)) {
            $formattedTaskSequence.admin_password = $adminPassword
        }

        $formattedTaskSequences.Add($formattedTaskSequence)
    }

    end {
        return [System.Collections.Hashtable[]] $formattedTaskSequences.ToArray()
    }
}

$exportMembers = @{
    Function = 'Get-MDTTaskSequence', `
        'Confirm-TaskSequenceIdIsValid', `
        'Format-MDTTaskSequence'
}

Export-ModuleMember @exportMembers
