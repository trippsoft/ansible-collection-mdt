function Import-MDTModule {
    <#
    .SYNOPSIS
    Ensures the Microsoft Deployment Toolkit PowerShell module is imported.

    .DESCRIPTION
    This function ensures the Microsoft Deployment Toolkit PowerShell module is imported.
    If the module is not already imported, it will attempt to import the module from the specified
    'installation_path' parameter within the module.
    If the module is not found at the specified path, the function will fail the Ansible module.

    .PARAMETER Module
    The Ansible module object.
    The object should have a parameter named 'installation_path' which specifies the path to the Microsoft
    Deployment Toolkit program directory.

    .EXAMPLE
    Import-MDTModule -Module $Module
    #>

    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module
    )

    if (-not (Get-Module -Name MicrosoftDeploymentToolkit)) {

        $mdtModulePath = "$($Module.Params.installation_path)\Bin\MicrosoftDeploymentToolkit.psd1"

        if (-not (Test-Path -LiteralPath $mdtModulePath -PathType Leaf)) {
            $Module.FailJson("Microsoft Deployment Toolkit does not appear to be installed at the specified path: $($Module.Params.installation_path)")
        }

        Import-Module -Name $mdtModulePath -ErrorAction Stop -Global | Out-Null
    }
}

function Get-MDTPSDrive {
    <#
    .SYNOPSIS
    Retrieves the MDT PowerShell drive for the specified MDT share path.

    .DESCRIPTION
    This function retrieves the MDT PowerShell drive for the specified MDT share path.
    If the drive does not exist, the function will attempt to create a new MDT PowerShell drive for the specified
    MDT share path.
    If the drive is read-only and write access is required, the function will fail the Ansible module.

    .PARAMETER Module
    The Ansible module object.
    The object should have a parameter named 'mdt_share_path' which specifies the path to the Microsoft Deployment
    Toolkit share directory.

    .PARAMETER ReadWrite
    Specifies whether write access is required to the MDT share path.
    If write access is required and the MDT PowerShell drive is read-only, the function will fail the Ansible module.

    .EXAMPLE
    Get-MDTPSDrive -Module $Module

    .EXAMPLE
    Get-MDTPSDrive -Module $Module -ReadWrite

    .OUTPUTS
    System.Management.Automation.PSDriveInfo
    #>

    [OutputType([System.Management.Automation.PSDriveInfo])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $false)]
        [switch]$ReadWrite = $false
    )

    $mdtSharePath = $Module.Params.mdt_share_path
    $mdtSharePath = $mdtSharePath.TrimEnd('\')

    if (-not (Test-Path -LiteralPath $mdtSharePath)) {
        $Module.FailJson("MDT share path '$($mdtSharePath)' does not exist.")
    }

    $mdtPSDrives = [Array](Get-PSDrive -Scope Global)

    foreach ($mdtPSDrive in $mdtPSDrives) {

        if ($mdtPSDrive.Root -ieq $mdtSharePath -and $mdtPSDrive.Provider.Name -ieq "MDTProvider") {

            if (-not $mdtPSDrive.ReadOnly -or -not $ReadWrite) {
                return $mdtPSDrive
            }
        }
    }

    for ($i = 1; $i -lt 1000; $i++) {

        $name = "DS$($i.ToString().PadLeft(3, '0'))"

        $matchingDrive = $null
        foreach ($mdtPSDrive in $mdtPSDrives) {

            if ($mdtPSDrive.Name -eq $name) {

                $matchingDrive = $mdtPSDrive
                break
            }
        }

        if ($null -eq $matchingDrive) {

            $mdtPSDrive = New-PSDrive -Name $name -PSProvider MDTProvider -Root $mdtSharePath -Scope Global

            if ($mdtPSDrive.ReadOnly -and $ReadWrite) {
                $Module.FailJson("Write access to the MDT share path '$($mdtSharePath)' is required and has been denied.")
            }

            return $mdtPSDrive
        }
    }

    $Module.FailJson("Failed to find or create MDT PowerShell drive for '$($mdtSharePath)'.")
}

function Confirm-NameIsValid {
    <#
    .SYNOPSIS
    Confirms the specified name contains only valid characters.

    .DESCRIPTION
    This function confirms the specified name contains only valid characters.
    If the name contains any invalid characters, the function will fail the Ansible module.
    Valid characters include ASCII letters, digits, and the following symbols: ~!@#$^&()_-+={};,.

    .PARAMETER Module
    The Ansible module object.

    .PARAMETER ParameterName
    The name of the parameter being validated.

    .PARAMETER Value
    The value to validate.

    .EXAMPLE
    "MyName" | Confirm-NameIsValid -Module $Module -ParameterName "name"

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

        $Value.ToCharArray() | Confirm-CharacterIsValidForName -Module $Module -ParameterName $ParameterName | Out-Null
    }
}

function Confirm-CharacterIsValidForName {
    <#
    .SYNOPSIS
    Confirms the specified character is an ASCII letter or digit.

    .DESCRIPTION
    This function confirms the specified character is an ASCII letter or digit.

    .PARAMETER Character
    The character to validate.

    .EXAMPLE
    'A' | Confirm-CharacterIsValidForName

    .INPUTS
    char

    .OUTPUTS
    bool
    #>

    [OutputType([bool])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [string]$ParameterName,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [char]$Character
    )

    begin {
        $allowedSymbols = @(
            ' ',
            '~',
            '!',
            '@',
            '#',
            '$',
            '^',
            '&',
            '(',
            ')',
            '_',
            '-',
            '+',
            '=',
            '{',
            '}',
            ';',
            ',',
            '.'
        )
    }

    process {

        if ($allowedSymbols -contains $Character) {
            return
        }

        $asciiValue = [int]$Character

        if (-not (($asciiValue -ge 48 -and $asciiValue -le 57) -or
                  ($asciiValue -ge 65 -and $asciiValue -le 90) -or
                  ($asciiValue -ge 97 -and $asciiValue -le 122))) {
            $Module.FailJson("The value of parameter '$($ParameterName)' contains an invalid character: '$($Character)'.")
        }
    }
}

function Format-MDTPath {
    <#
    .SYNOPSIS
    Converts the specified path to the expected format.

    .DESCRIPTION
    This function converts the specified path to the expected format.
    The function will replace all forward slashes with backslashes and trim any leading or trailing slashes.

    .PARAMETER Path
    The path to convert.

    .EXAMPLE
    "C:/Program Files" | Format-MDTPath

    .INPUTS
    string

    .OUTPUTS
    string
    #>

    [OutputType([string])]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]$Path
    )

    process {

        if ($null -eq $Path) {
            return $null
        }

        $Path = $Path -replace '/', '\'
        $Path = $Path.Trim('\')

        return $Path
    }
}

function Format-MDTFilesValue {
    <#
    .SYNOPSIS
    Formats the files of an MDT object to a custom object.

    .DESCRIPTION
    This function formats the files of an MDT object into a custom object.

    .PARAMETER DirectoryPath
    The directory path of the MDT object.

    .EXAMPLE
    Format-MDTOperatingSystemFilesValue -DirectoryPath "C:\test"

    This example converts the files of an MDT object into a formatted custom object within the directory "C:\test".

    .OUTPUTS
    System.Collections.Hashtable[]
    #>

    [OutputType([System.Collections.Hashtable[]])]
    param (
        [Parameter(Mandatory = $true)]
        [string]$DirectoryPath
    )

    $formattedFiles = New-Object -TypeName System.Collections.Generic.List[System.Collections.Hashtable]

    $files = [Array](Get-ChildItem -LiteralPath $DirectoryPath -Recurse -File -ErrorAction SilentlyContinue)

    if ($null -eq $files) {
        return [System.Collections.Hashtable[]]$formattedFiles.ToArray()
    }

    foreach ($file in $files) {

        $path = $file.FullName -replace [regex]::Escape("$($DirectoryPath)\"), ""
        $sha256Checksum = Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256

        $formattedFile = @{
            path = $path
            sha256_checksum = $sha256Checksum.Hash
        }

        $formattedFiles.Add($formattedFile) | Out-Null
    }

    return [System.Collections.Hashtable[]]$formattedFiles.ToArray()
}

function Confirm-MDTPathIsValid {
    <#
    .SYNOPSIS
    Confirms the specified path contains only valid characters.

    .DESCRIPTION
    This function confirms the specified path contains only valid characters.
    If the path contains any invalid characters, the function will fail the Ansible module.
    The path is split into segments and each segment is validated individually.
    Invalid characters are provided by the .NET System.IO.Path.GetInvalidFileNameChars() method.

    .PARAMETER Module
    The Ansible module object.

    .PARAMETER ParameterName
    The name of the parameter being validated.
    This is used in the error message.

    .PARAMETER Value
    The value to validate.

    .EXAMPLE
    "C:\Program Files" | Confirm-MDTPathIsValid -Module $Module -ParameterName "path"

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
        [string]$Value
    )

    process {
        $Value.Split('\') | Confirm-MDTPathSegmentIsValid -Module $Module -ParameterName $ParameterName
    }
}

function Confirm-MDTPathSegmentIsValid {
    <#
    .SYNOPSIS
    Confirms the specified path segment contains only valid characters.

    .DESCRIPTION
    This function confirms the specified path segment contains only valid characters.
    If the path segment contains any invalid characters, the function will fail the Ansible module.
    Invalid characters are provided by the .NET System.IO.Path.GetInvalidFileNameChars() method.
    If the path segment is '.' or '..', the function will fail the Ansible module.

    .PARAMETER Module
    The Ansible module object.

    .PARAMETER ParameterName
    The name of the parameter being validated.
    This is used in the error message.

    .PARAMETER Value
    The value to validate.

    .EXAMPLE
    "Program Files" | Confirm-MDTPathSegmentIsValid -Module $Module -ParameterName "path"

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

        if ($Value -eq '.' -or $Value -eq '..') {
            $Module.FailJson("The value of parameter '$($ParameterName)' cannot use relative path segment '$($Value)'.")
        }

        $Value.ToCharArray() | Confirm-CharacterIsValidForMDTPathSegment -Module $Module -ParameterName $ParameterName | Out-Null
    }
}

function Confirm-CharacterIsValidForMDTPathSegment {
    <#
    .SYNOPSIS
    Confirms the specified character is valid for an MDT path segment.

    .DESCRIPTION
    This function confirms the specified character is valid for an MDT path segment.

    .PARAMETER Character
    The character to validate.

    .EXAMPLE
    'A' | Confirm-CharacterIsValidForMDTPathSegment

    .INPUTS
    char

    .OUTPUTS
    bool
    #>

    [OutputType([bool])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(Mandatory = $true)]
        [string]$ParameterName,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [char]$Character
    )

    begin {
        $invalidCharacters = [System.IO.Path]::GetInvalidFileNameChars()
    }

    process {

        if ($invalidCharacters -contains $Character) {
            $Module.FailJson("The value of parameter '$($ParameterName)' contains an invalid character: '$($Character)'.")
        }
    }
}

function Get-FullPath {
    <#
    .SYNOPSIS
    Combines the specified path segments into a full path.

    .DESCRIPTION
    This function combines the specified path segments into a full path.
    The function will ensure the path segments are separated by backslashes and do not contain any leading or
    trailing slashes.

    .PARAMETER MDTDriveName
    The name of the MDT PowerShell drive.

    .PARAMETER PathSegment
    The path segment to join to the MDT share path.

    .EXAMPLE
    @("Operating Systems", "Windows 10", "Windows 10 Enterprise") | Get-FullPath -MDTDriveName "DS001"

    This example will return "DS001:\Operating Systems\Windows 10\Windows 10 Enterprise".

    .INPUTS
    string

    .OUTPUTS
    string
    #>

    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [string]$MDTDriveName,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [string]$PathSegment
    )

    begin {
        $fullPath = "$($MDTDriveName):"
    }

    process {
        $fullPath = "$($fullPath)\$($PathSegment)"
    }

    end {
        return $fullPath
    }
}

function Format-MDTGuid {
    <#
    .SYNOPSIS
    Converts the specified GUID to the expected format.

    .DESCRIPTION
    This function converts the specified GUID to the expected format.
    The function will remove any leading or trailing braces and convert the GUID to lowercase.
    If the specified GUID is not in any valid GUID format, the function will fail the Ansible module.

    .PARAMETER Module
    The Ansible module object.

    .PARAMETER Guid
    The GUID to convert.

    .EXAMPLE
    "00000000-0000-0000-0000-000000000000" | Format-MDTGuid -Module $Module

    .INPUTS
    string

    .OUTPUTS
    string
    #>

    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [Ansible.Basic.AnsibleModule]$Module,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]$Guid
    )

    process {

        if ([string]::IsNullOrEmpty($Guid)) {
            return $null
        }

        $originalGuid = $Guid

        $Guid = $Guid.Trim('{')
        $Guid = $Guid.Trim('}')

        $parsed = [System.Guid]::NewGuid()

        if ([System.Guid]::TryParse($Guid, [ref]$parsed)) {
            return "{$($Guid.ToLowerInvariant())}"
        }

        $Module.FailJson("The specified GUID '$($originalGuid)' is not in any valid GUID format.")
    }
}

$exportMembers = @{
    Function = 'Import-MDTModule', `
        'Get-MDTPSDrive', `
        'Confirm-NameIsValid', `
        'Format-MDTPath', `
        'Format-MDTFilesValue', `
        'Confirm-MDTPathIsValid', `
        'Confirm-MDTPathSegmentIsValid', `
        'Get-FullPath', `
        'Format-MDTGuid'
}

Export-ModuleMember @exportMembers
