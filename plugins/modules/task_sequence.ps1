#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.Common
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.OperatingSystem
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.TaskSequence

function Confirm-TaskSequenceParamsAreValid {
    <#
    .SYNOPSIS
    Confirms that the parameters are valid.

    .DESCRIPTION
    This function confirms that the parameters are valid.

    .PARAMETER Module
    The Ansible module.

    .EXAMPLE
    Confirm-TaskSequenceParamsAreValid -Module $module

    This example confirms that the parameters are valid.
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [string]$MDTDriveName
    )

    process {

        $state = $Module.Params.state

        if ($state -eq "absent") {
            $Module | Confirm-TaskSequenceAbsentParamsAreValid | Out-Null
        }
        elseif ($state -eq "present") {
            $Module | Confirm-TaskSequencePresentParamsAreValid -MDTDriveName $MDTDriveName | Out-Null
        }

        $Module.Params.id | Confirm-TaskSequenceIdIsValid -Module $Module -ParameterName "id" | Out-Null
        $Module.Params.name | Confirm-NameIsValid -Module $Module -ParameterName "name" | Out-Null
    }
}

function Confirm-TaskSequenceAbsentParamsAreValid {
    <#
    .SYNOPSIS
    Confirms that the parameters are valid when state is 'absent'.

    .DESCRIPTION
    This function confirms that the parameters are valid when state is 'absent'.

    .PARAMETER Module
    The Ansible module.

    .EXAMPLE
    Confirm-TaskSequenceAbsentParamsAreValid -Module $module
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [Ansible.Basic.AnsibleModule]$Module
    )

    process {

        if ($null -ne $Module.Params.id -and $null -ne $Module.Params.name) {
            $Module.FailJson("The 'id' and 'name' parameters are mutually exclusive when state is 'absent'.")
        }

        $invalidParams = New-Object -TypeName System.Collections.ArrayList

        if ($null -ne $Module.Params.paths) {
            $invalidParams.Add("paths") | Out-Null
        }

        if ($null -ne $Module.Params.template) {
            $invalidParams.Add("template") | Out-Null
        }

        if ($null -ne $Module.Params.operating_system_guid) {
            $invalidParams.Add("operating_system_guid") | Out-Null
        }

        if ($null -ne $Module.Params.operating_system_name) {
            $invalidParams.Add("operating_system_name") | Out-Null
        }

        if ($null -ne $Module.Params.product_key_type) {
            $invalidParams.Add("product_key_type") | Out-Null
        }

        if ($null -ne $Module.Params.product_key) {
            $invalidParams.Add("product_key") | Out-Null
        }

        if ($null -ne $Module.Params.admin_password) {
            $invalidParams.Add("admin_password") | Out-Null
        }

        if ($null -ne $Module.Params.full_name) {
            $invalidParams.Add("full_name") | Out-Null
        }

        if ($null -ne $Module.Params.organization) {
            $invalidParams.Add("organization") | Out-Null
        }

        if ($null -ne $Module.Params.ie_home_page) {
            $invalidParams.Add("ie_home_page") | Out-Null
        }

        if ($null -ne $Module.Params.version) {
            $invalidParams.Add("version") | Out-Null
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
            $Module.FailJson("The following parameters are not valid when state is 'absent': $($invalidParams -join ", ").")
        }
    }
}

function Confirm-TaskSequencePresentParamsAreValid {
    <#
    .SYNOPSIS
    Confirms that the parameters are valid when state is 'present'.

    .DESCRIPTION
    This function confirms that the parameters are valid when state is 'present'.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The MDT drive name.

    .EXAMPLE
    Confirm-TaskSequencePresentParamsAreValid -Module $module -MDTDriveName $mdtDrive.Name
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [string]$MDTDriveName
    )

    process {

        $installationPath = $Module.Params.installation_path
        $mdtSharePath = $Module.Params.mdt_share_path
        $template = $Module.Params.template
        $productKey = $Module.Params.product_key
        $productKeyType = $Module.Params.product_key_type

        if ($null -ne $productKey) {

            if ($productKeyType -eq "none") {
                $Module.FailJson("The 'product_key' parameter is not valid when 'product_key_type' is 'none'.")
            }

            if ($productKey -notmatch '^[A-Za-z0-9]{5}-[A-Za-z0-9]{5}-[A-Za-z0-9]{5}-[A-Za-z0-9]{5}-[A-Za-z0-9]{5}$') {
                $Module.FailJson("The 'product_key' parameter is not formatted correctly.")
            }
        }

        $Module.Params.operating_system_guid = $Module.Params.operating_system_guid | Format-MDTGuid -Module $Module
        $Module.Params.operating_system_name | Confirm-NameIsValid -Module $Module -ParameterName "operating_system_name" | Out-Null

        $operatingSystemGuid = $Module.Params.operating_system_guid
        $operatingSystemName = $Module.Params.operating_system_name

        $operatingSystem = Get-MDTOperatingSystem -Module $Module -MDTDriveName $MDTDriveName -Guid $operatingSystemGuid -Name $operatingSystemName

        if ($null -eq $operatingSystem) {
            if ($null -ne $operatingSystemGuid) {
                $Module.FailJson("No MDT operating system found with GUID '$operatingSystemGuid'.")
            }

            if ($null -ne $operatingSystemName) {
                $Module.FailJson("No MDT operating system found with name '$operatingSystemName'.")
            }
        }

        $mdtShareTemplatePath = "$($mdtSharePath)\Templates\$($template)"

        if (-not (Test-Path -LiteralPath $mdtShareTemplatePath -PathType Leaf)) {

            $installationTemplatePath = "$($installationPath)\Templates\$($template)"

            if (-not (Test-Path -LiteralPath $installationTemplatePath -PathType Leaf)) {
                $Module.FailJson("No MDT task sequence template found with name '$($template)'.")
            }
        }
    }
}

function Get-ExpectedTaskSequence {
    <#
    .SYNOPSIS
    Gets the expected MDT task sequence.

    .DESCRIPTION
    This function gets the expected MDT task sequence.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The MDT drive name.

    .PARAMETER Existing
    The existing MDT task sequence.

    .EXAMPLE
    Get-ExpectedTaskSequence -Module $Module -MDTDriveName $MDTDriveName -Existing $Existing

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
        [AllowNull()]
        [System.Collections.Hashtable]$Existing
    )

    $id = $Module.Params.id
    $name = $Module.Params.name
    $template = $Module.Params.template
    $operatingSystemGuid = $Module.Params.operating_system_guid
    $operatingSystemName = $Module.Params.operating_system_name
    $adminPassword = $Module.Params.admin_password
    $fullName = $Module.Params.full_name
    $organization = $Module.Params.organization
    $ieHomePage = $Module.Params.ie_home_page
    $version = $Module.Params.version
    $comments = $Module.Params.comments
    $enabled = $Module.Params.enabled
    $hidden = $Module.Params.hidden

    $operatingSystem = Get-MDTOperatingSystem -Module $Module -MDTDriveName $MDTDriveName -Guid $operatingSystemGuid -Name $operatingSystemName |
        Format-MDTOperatingSystem -Module $Module -MDTDriveName $MDTDriveName -ExcludePaths

    $expected = @{
        id = $id
        name = $name
        template = $template
        operating_system = @{
            guid = $operatingSystem.guid
            name = $operatingSystem.name
        }
        paths = [string[]](Get-ExpectedTaskSequencePathsValue -Module $Module -Existing $Existing)
        product_key_type = Get-ExpectedTaskSequenceProductKeyTypeValue -Module $Module -Existing $Existing
        full_name = $fullName
        organization = $organization
    }

    if ($expected.paths.Length -eq 0) {
        $Module.FailJson("The 'paths' parameter would remove the operating system.")
    }

    if ($null -ne $Existing) {
        $expected.guid = $Existing.guid
    }

    $expectedProductKey = Get-ExpectedTaskSequenceProductKeyValue -Module $Module -Existing $Existing

    if ($null -ne $expectedProductKey) {
        $expected.product_key = $expectedProductKey
    }

    if ($null -ne $adminPassword) {
        $expected.admin_password = $adminPassword
    }
    elseif ($null -ne $Existing) {
        $expected.admin_password = $Existing.admin_password
    }

    if ($null -ne $ieHomePage) {
        $expected.ie_home_page = $ieHomePage
    }
    elseif ($null -ne $Existing) {
        $expected.ie_home_page = $Existing.ie_home_page
    }
    else {
        $expected.ie_home_page = "about:blank"
    }

    if ($null -ne $version) {
        $expected.version = $version
    }
    elseif ($null -ne $Existing) {
        $expected.version = $Existing.version
    }
    else {
        $expected.version = "1.0"
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

    return $expected
}

function Get-ExpectedTaskSequencePathsValue {
    <#
    .SYNOPSIS
    Gets the expected paths.

    .DESCRIPTION
    This function gets the expected paths.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER Existing
    The existing MDT task sequence.

    .EXAMPLE
    Get-ExpectedTaskSequencePathsValue -Module $Module -Existing $Existing

    .OUTPUTS
    string[]
    #>

    [OutputType([string[]])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [AllowNull()]
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

function Get-ExpectedTaskSequenceProductKeyTypeValue {
    <#
    .SYNOPSIS
    Gets the expected product key type.

    .DESCRIPTION
    This function gets the expected product key type.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER Existing
    The existing MDT task sequence.

    .EXAMPLE
    Get-ExpectedTaskSequenceProductKeyTypeValue -Module $Module -Existing $Existing

    .OUTPUTS
    string
    #>

    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Collections.Hashtable]$Existing
    )

    $productKeyType = $Module.Params.product_key_type

    if ($null -ne $productKeyType) {
        return $productKeyType
    }

    if ($null -ne $Existing) {
        return $Existing.product_key_type
    }

    return "none"
}

function Get-ExpectedTaskSequenceProductKeyValue {
    <#
    .SYNOPSIS
    Gets the expected product key.

    .DESCRIPTION
    This function gets the expected product key.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER Existing
    The existing MDT task sequence.

    .EXAMPLE
    Get-ExpectedTaskSequenceProductKeyValue -Module $Module -Existing $Existing

    .OUTPUTS
    string
    #>

    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Collections.Hashtable]$Existing
    )

    $productKeyType = Get-ExpectedTaskSequenceProductKeyTypeValue -Module $Module -Existing $Existing

    if ($productKeyType -eq "none") {
        return $null
    }

    $productKey = $Module.Params.product_key

    if ($null -ne $productKey) {
        return $productKey
    }

    if ($null -ne $Existing.product_key) {
        return $Existing.product_key
    }

    return $null
}

function Compare-ExpectedTaskSequenceToExisting {
    <#
    .SYNOPSIS
    Compares the expected MDT task sequence to the existing MDT task sequence.

    .DESCRIPTION
    This function compares the expected MDT task sequence to the existing MDT task sequence.

    .PARAMETER Expected
    The expected MDT task sequence.

    .PARAMETER Existing
    The existing MDT task sequence.

    .EXAMPLE
    Compare-ExpectedTaskSequenceToExisting -Expected $expected -Existing $existing

    .OUTPUTS
    System.Collections.Hashtable
    #>

    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [string]$MDTDriveName,
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$Expected,
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$Existing
    )

    $propertyChanges = @{}

    if ($Expected.id -ne $Existing.id) {
        $propertyChanges.Id = $Expected.id
    }

    if ($Expected.name -ne $Existing.name) {
        $propertyChanges.Name = $Expected.name
    }

    if ($Expected.operating_system.guid -ne $Existing.operating_system.guid) {
        $propertyChanges.OperatingSystemGuid = $Expected.operating_system.guid
    }

    if ($Expected.product_key_type -ne $Existing.product_key_type -or $Expected.product_key -ne $Existing.product_key) {
        $propertyChanges.ProductKeyType = $Expected.product_key_type

        if ($null -ne $Expected.product_key) {
            $propertyChanges.ProductKey = $Expected.product_key
        }
    }

    if ([string]::IsNullOrEmpty($Expected.admin_password) -and -not [string]::IsNullOrEmpty($Existing.admin_password)) {
        $propertyChanges.AdminPassEmpty = $true
    }
    elseif (-not [string]::IsNullOrEmpty($Expected.admin_password) -and $Expected.admin_password -ne $Existing.admin_password) {
        $propertyChanges.AdminPass = $Expected.admin_password
    }

    if ($Expected.full_name -ne $Existing.full_name) {
        $propertyChanges.FullName = $Expected.full_name
    }

    if ($Expected.organization -ne $Existing.organization) {
        $propertyChanges.Organization = $Expected.organization
    }

    if ($Expected.ie_home_page -ne $Existing.ie_home_page) {
        $propertyChanges.IEHomePage = $Expected.ie_home_page
    }

    if ($Expected.version -ne $Existing.version) {
        $propertyChanges.Version = $Expected.version
    }

    if ($Expected.comments -ne $Existing.comments) {
        if ([string]::IsNullOrEmpty($Expected.comments)) {
            $propertyChanges.CommentsEmpty = $true
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

    $addPaths = New-Object -TypeName System.Collections.ArrayList

    foreach ($expectedPath in $Expected.paths) {

        if ($Existing.paths -icontains $expectedPath) {
            continue
        }

        $pathSegments = $expectedPath -split "\\" | Where-Object { -not [string]::IsNullOrEmpty($_) }
        $fullPath = @(@("Task Sequences"); $pathSegments) | Get-FullPath -MDTDriveName $MDTDriveName

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
        $fullPath = @(@("Task Sequences"); $pathSegments; @($Expected.name)) | Get-FullPath -MDTDriveName $MDTDriveName

        $removePaths.Add($fullPath) | Out-Null
    }

    if ($removePaths.Count -gt 0) {
        $propertyChanges.RemovePaths = [string[]]$removePaths.ToArray()
    }

    return $propertyChanges
}

function Set-MDTTaskSequence {

    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [string]$MDTDriveName,
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$Existing,
        [Parameter(Mandatory = $false)]
        [string]$Id,
        [Parameter(Mandatory = $false)]
        [string]$Name,
        [Parameter(Mandatory = $false)]
        [string]$OperatingSystemGuid,
        [Parameter(Mandatory = $false)]
        [string]$ProductKeyType,
        [Parameter(Mandatory = $false)]
        [string]$ProductKey,
        [Parameter(Mandatory = $false)]
        [bool]$AdminPassEmpty = $false,
        [Parameter(Mandatory = $false)]
        [string]$AdminPass,
        [Parameter(Mandatory = $false)]
        [string]$FullName,
        [Parameter(Mandatory = $false)]
        [string]$Organization,
        [Parameter(Mandatory = $false)]
        [string]$IEHomePage,
        [Parameter(Mandatory = $false)]
        [string]$Version,
        [Parameter(Mandatory = $false)]
        [bool]$CommentsEmpty = $false,
        [Parameter(Mandatory = $false)]
        [string]$Comments,
        [Parameter(Mandatory = $false)]
        [ValidateSet($null, $true, $false)]
        [object]$Enabled,
        [Parameter(Mandatory = $false)]
        [ValidateSet($null, $true, $false)]
        [object]$Hidden,
        [Parameter(Mandatory = $false)]
        [string[]]$AddPaths,
        [Parameter(Mandatory = $false)]
        [string[]]$RemovePaths
    )

    $module.Result.changed = $true

    if ($Module.CheckMode) {
        return
    }

    $taskSequence = Get-MDTTaskSequence -Module $Module -MDTDriveName $MDTDriveName -Id $Module.Params.id -Name $Module.Params.name |
        Select-Object -First 1

    $pathPrefix = "MicrosoftDeploymentToolkit\MDTProvider::"

    if ($null -ne $AddPaths) {

        foreach ($addPath in $AddPaths) {

            if (Test-Path -LiteralPath "$($addPath)\$($taskSequence.Name)" -PathType Leaf) {
                continue
            }

            $sourcePath = $taskSequence.PSPath -replace [regex]::Escape($pathPrefix), ""

            Copy-Item -LiteralPath $sourcePath -Destination $addPath | Out-Null
        }
    }

    if (-not [string]::IsNullOrEmpty($Id)) {
        $taskSequence.Item("ID") = $Id
    }

    if (-not [string]::IsNullOrEmpty($Version)) {
        $taskSequence.Item("Version") = $Version
    }

    if ($CommentsEmpty) {
        $taskSequence.Item("Comments") = ""
    }
    elseif (-not [string]::IsNullOrEmpty($Comments)) {
        $taskSequence.Item("Comments") = $Comments
    }

    if ($null -ne $Enabled) {
        if ($Enabled) {
            $taskSequence.Item("enable") = "True"
        }
        else {
            $taskSequence.Item("enable") = "False"
        }
    }

    if ($null -ne $Hidden) {
        if ($Hidden) {
            $taskSequence.Item("hide") = "True"
        }
        else {
            $taskSequence.Item("hide") = "False"
        }
    }

    if (-not [string]::IsNullOrEmpty($Name)) {
        $taskSequence.RenameItem($Name)
    }

    if ($null -ne $RemovePaths) {

        foreach ($removePath in $RemovePaths) {

            if (Test-Path -LiteralPath $removePath -PathType Leaf) {
                Remove-Item -LiteralPath $removePath | Out-Null
            }
        }
    }

    $taskSequenceFolder = $taskSequence.GetPhysicalSourcePath()

    $taskSequenceContent = Get-Content -LiteralPath "$($taskSequenceFolder)\ts.xml"

    if (-not [string]::IsNullOrEmpty($OperatingSystemGuid)) {
        $taskSequenceContent |
            ForEach-Object { $_ -replace [regex]::Escape($Existing.operating_system.guid), $OperatingSystemGuid } |
            Set-Content -LiteralPath "$($taskSequenceFolder)\ts.xml" |
            Out-Null
    }

    $unattendXml = [XML](Get-Content -LiteralPath "$($taskSequenceFolder)\Unattend.xml")

    $specializeXml = $unattendXml.unattend.settings | Where-Object { $_.pass -eq "specialize" }
    $shellSetupSpecializeXml = $specializeXml.component | Where-Object { $_.name -eq "Microsoft-Windows-Shell-Setup" }

    if ($null -ne $ProductKeyType) {

        $winPEXml = $unattendXml.unattend.settings | Where-Object { $_.pass -eq "windowsPE" }
        $setupWinPEXml = $winPEXml.component | Where-Object { $_.name -eq "Microsoft-Windows-Setup" }
        $productKeyWinPEXml = $setupWinPEXml.UserData.ProductKey

        if ($ProductKeyType -eq "retail") {
            $productKeyWinPEXml.Key = $ProductKey
        }
        else {
            $productKeyWinPEXml.Key = ""
        }

        if ($ProductKeyType -ne "none") {
            $shellSetupSpecializeXml.ProductKey = $ProductKey
        }
        else {
            $shellSetupSpecializeXml.ProductKey = ""
        }
    }

    $oobeSystemXml = $unattendXml.unattend.settings | Where-Object { $_.pass -eq "oobeSystem" }
    $shellSetupOOBEXml = $oobeSystemXml.component | Where-Object { $_.name -eq "Microsoft-Windows-Shell-Setup" }
    $administratorPasswordXml = $shellSetupOOBEXml.UserAccounts.AdministratorPassword
    $autoLogonPasswordXml = $shellSetupOOBEXml.AutoLogon.Password

    if ($AdminPassEmpty) {
        $administratorPasswordXml.Value = ""
        $autoLogonPasswordXml.Value = ""
    }
    elseif (-not [string]::IsNullOrEmpty($AdminPass)) {
        $administratorPasswordXml.Value = $AdminPass
        $autoLogonPasswordXml.Value = $AdminPass
    }

    if (-not [string]::IsNullOrEmpty($FullName)) {
        $shellSetupSpecializeXml.RegisteredOwner = $FullName
    }

    if (-not [string]::IsNullOrEmpty($Organization)) {
        $shellSetupSpecializeXml.RegisteredOrganization = $Organization
    }

    if (-not [string]::IsNullOrEmpty($IEHomePage)) {
        $internetExplorerXml = $specializeXml.component | Where-Object { $_.name -eq "Microsoft-Windows-IE-InternetExplorer" }
        $internetExplorerXml.Home_Page = $IEHomePage
    }

    $unattendXml.Save("$($taskSequenceFolder)\Unattend.xml")

    $taskSequence = Get-MDTTaskSequence -Module $Module -MDTDriveName $MDTDriveName -Id $taskSequence.id |
        Format-MDTTaskSequence -Module $Module -MDTDriveName $MDTDriveName

    $Module.Diff.after = $taskSequence
    $Module.Result.task_sequence = $taskSequence
}

function New-MDTTaskSequence {
    <#
    .SYNOPSIS
    Creates a new MDT task sequence.

    .DESCRIPTION
    This function creates a new MDT task sequence.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The MDT drive name.

    .PARAMETER Expected
    The expected MDT task sequence.

    .EXAMPLE
    New-MDTTaskSequence -Module $module -MDTDriveName $mdtDrive.Name -Expected $expected

    This example creates a new MDT task sequence.
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

    $module.Result.changed = $true

    if ($Module.CheckMode) {
        return
    }

    $firstPathSegments = $Expected.paths[0] -split "\\" | Where-Object { -not [string]::IsNullOrEmpty($_) }
    $firstFullPath = @(@("Task Sequences"); $firstPathSegments) | Get-FullPath -MDTDriveName $MDTDriveName

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

    $operatingSystem = Get-MDTOperatingSystem -Module $Module -MDTDriveName $MDTDriveName -Guid $Expected.operating_system.guid |
        Format-MDTOperatingSystem -Module $Module -MDTDriveName $MDTDriveName

    if ([string]::IsNullOrEmpty($operatingSystem.paths[0])) {
        $operatingSystemPath = "$($MDTDriveName):\Operating Systems\$($operatingSystem.name)"
    }
    else {
        $operatingSystemPath = "$($MDTDriveName):\Operating Systems\$($operatingSystem.paths[0])\$($operatingSystem.name)"
    }

    $importArgs = @{
        Path = $firstFullPath
        ID = $Expected.id
        Name = $Expected.name
        Template = $Expected.template
        AdminPassword = $Expected.admin_password
        FullName = $Expected.full_name
        OrgName = $Expected.organization
        HomePage = $Expected.ie_home_page
        Version = $Expected.version
        OperatingSystemPath = $operatingSystemPath
        Comments = $Expected.comments
    }

    if ($null -ne $Expected.product_key -and $Expected.product_key_type -eq "mak") {
        $importArgs.OverrideProductKey = $Expected.product_key
    }
    elseif ($null -ne $Expected.product_key -and $Expected.product_key_type -eq "retail") {
        $importArgs.ProductKey = $Expected.product_key
    }

    $taskSequence = Import-MDTTaskSequence @importArgs

    $taskSequence.Item("enable") = $enableValue
    $taskSequence.Item("hide") = $hideValue

    foreach ($path in $Expected.paths) {

        $pathSegments = $path -split "\\" | Where-Object { -not [string]::IsNullOrEmpty($_) }
        $fullPath = @(@("Task Sequences"); $pathSegments) | Get-FullPath -MDTDriveName $MDTDriveName

        if ($firstFullPath -ieq $fullPath) {
            continue
        }

        Copy-Item -LiteralPath "$($firstFullPath)\$($Expected.name)" -Destination $fullPath | Out-Null
    }

    $currentTaskSequence = Get-MDTTaskSequence -Module $Module -MDTDriveName $MDTDriveName -Id $Expected.id -Name $Expected.name |
        Format-MDTTaskSequence -Module $Module -MDTDriveName $MDTDriveName

    $Module.Diff.after = $currentTaskSequence
    $Module.Result.task_sequence = $currentTaskSequence
}

function Remove-MDTTaskSequence {
    <#
    .SYNOPSIS
    Removes an MDT task sequence.

    .DESCRIPTION
    This function removes an MDT task sequence.

    .PARAMETER Module
    The Ansible module.

    .PARAMETER MDTDriveName
    The MDT drive name.

    .EXAMPLE
    Remove-MDTTaskSequence -Module $module -MDTDriveName $mdtDrive.Name

    This example removes an MDT task sequence.
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [string]$MDTDriveName
    )

    $Module.Result.changed = $true

    if ($Module.CheckMode) {
        return
    }

    $taskSequences = Get-MDTTaskSequence -Module $Module -MDTDriveName $MDTDriveName -Id $Module.Params.id -Name $Module.Params.name

    $pathPrefix = "MicrosoftDeploymentToolkit\MDTProvider::"

    foreach ($taskSequence in [Array]$taskSequences) {
        $taskSequencePath = $taskSequence.PSPath -replace [regex]::Escape($pathPrefix), ""
        Remove-Item -LiteralPath $taskSequencePath | Out-Null
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
        id = @{
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
                    required = $false
                    elements = 'str'
                }
                remove = @{
                    type = 'list'
                    required = $false
                    elements = 'str'
                }
                set = @{
                    type = 'list'
                    required = $false
                    elements = 'str'
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
        template = @{
            type = 'str'
            required = $false
        }
        operating_system_guid = @{
            type = 'str'
            required = $false
        }
        operating_system_name = @{
            type = 'str'
            required = $false
        }
        product_key_type = @{
            type = 'str'
            required = $false
            choices = @('none', 'mak', 'retail')
        }
        product_key = @{
            type = 'str'
            required = $false
            no_log = $true
        }
        admin_password = @{
            type = 'str'
            required = $false
            no_log = $true
        }
        full_name = @{
            type = 'str'
            required = $false
        }
        organization = @{
            type = 'str'
            required = $false
        }
        ie_home_page = @{
            type = 'str'
            required = $false
        }
        version = @{
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
            choices = @('present', 'absent')
            default = 'present'
        }
    }
    mutually_exclusive = @(
        , @('operating_system_guid', 'operating_system_name')
    )
    required_by = @{
        'product_key' = @(, 'product_key_type')
    }
    required_if = @(
        @('state', 'present', @('id', 'name', 'template', 'full_name', 'organization')),
        @('state', 'present', @('operating_system_guid', 'operating_system_name'), $true)
    )
    required_one_of = @(
        , @('name', 'id')
    )
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-MDTModule -Module $module | Out-Null

$mdtDrive = Get-MDTPSDrive -Module $module

$module | Confirm-TaskSequenceParamsAreValid -MDTDriveName $mdtDrive.Name | Out-Null

$module.Result.changed = $false

$module.Diff.before = Get-MDTTaskSequence -Module $module -MDTDriveName $mdtDrive.Name -Id $module.Params.id -Name $module.Params.name |
    Format-MDTTaskSequence -Module $module -MDTDriveName $mdtDrive.Name

$existing = Get-MDTTaskSequence -Module $module -MDTDriveName $mdtDrive.Name -Id $module.Params.id -Name $module.Params.name |
    Format-MDTTaskSequence -Module $module -MDTDriveName $mdtDrive.Name -IncludeSecrets

if ($module.Params.state -eq "present") {

    $expected = Get-ExpectedTaskSequence -Module $module -MDTDriveName $mdtDrive.Name -Existing $existing

    $expectedWithoutSecrets = $expected.Clone()
    $expectedWithoutSecrets.Remove("admin_password")
    $expectedWithoutSecrets.Remove("product_key")

    $module.Diff.after = $expectedWithoutSecrets
    $module.Result.task_sequence = $expectedWithoutSecrets

    if ($null -ne $existing) {

        if ($existing.template -ne $expected.template) {
            $module.Warn("The 'template' parameter cannot be changed.")
        }

        $propertyChanges = Compare-ExpectedTaskSequenceToExisting -MDTDriveName $mdtDrive.Name -Expected $expected -Existing $existing

        if ($propertyChanges.Count -gt 0) {
            Set-MDTTaskSequence -Module $module -MDTDriveName $mdtDrive.Name -Existing $existing @propertyChanges | Out-Null
        }
    }
    else {
        New-MDTTaskSequence -Module $module -MDTDriveName $mdtDrive.Name -Expected $expected | Out-Null
    }
}
elseif ($module.Params.state -eq "absent") {

    $module.Diff.after = $null

    if ($null -ne $existing) {
        Remove-MDTTaskSequence -Module $module -MDTDriveName $mdtDrive.Name | Out-Null
    }
}

$mdtDrive | Remove-PSDrive | Out-Null

$module.ExitJson()
