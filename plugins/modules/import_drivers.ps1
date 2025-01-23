#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.SharedFunctions

function Format-ImportedDriver {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Microsoft.BDD.PSSnapIn.MDTObject[]]$Drivers
    )

    $formattedDrivers = New-Object System.Collections.Generic.List[System.Collections.IDictionary]

    foreach ($driver in $Drivers)
    {
        $formattedDriver = @{
            class = $driver.Class
            guid = $driver.guid
            hash = $driver.Hash
            name = $driver.Name
            os_version = $driver.OSVersion
            platform = $driver.Platform
            source = $driver.Source
            version = $driver.Version
            whql_signed = [bool]::Parse($driver.WHQLSigned)
        }

        $formattedDrivers.Add($formattedDriver)
    }

    return $formattedDrivers
}

$spec = @{
    options = @{
        installation_path = @{
            type = 'path'
            required = $false
            default = 'C:\Program Files\Microsoft Deployment Toolkit'
        }
        source_paths = @{
            type = 'list'
            required = $true
            elements = 'path'
        }
        path = @{
            type = 'str'
            required = $true
        }
        import_duplicates = @{
            type = 'bool'
            required = $false
            default = $false
        }
        mdt_directory_path = @{
            type = 'str'
            required = $true
        }
    }
    supports_check_mode = $false
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-MDTModule -InstallationPath $module.Params.installation_path

$sourcePaths = $module.Params.source_paths
$path = $module.Params.path
$importDuplicates = $module.Params.import_duplicates
$mdtDirectoryPath = $module.Params.mdt_directory_path

if (-not (Test-Path -Path $mdtDirectoryPath))
{
    $module.FailJson("MDT directory path '$mdtDirectoryPath' does not exist.")
}

foreach ($sourcePath in $sourcePaths)
{
    if (-not (Test-Path -Path $sourcePath))
    {
        $module.FailJson("Source path '$sourcePath' does not exist.")
    }
}

$mdtDrive = Get-MDTPSDrive -Path $mdtDirectoryPath

if ($null -eq $mdtDrive)
{
    $module.FailJson("Failed to find or create MDT PowerShell drive for '$mdtDirectoryPath'.")
}

if ($mdtDrive.ReadOnly)
{
    $module.FailJson("MDT drive '$($mdtDrive.Name)' is read-only.")
}

$path = $path.TrimStart('\')
$fullPath = "$($mdtDrive.Name):/$($path)"

if (-not (Test-Path -Path $fullPath))
{
    $module.FailJson("Path '$fullPath' does not exist.")
}

$importedDrivers = [Array](Import-MDTDriver -Path $fullPath -SourcePath $sourcePaths -ImportDuplicates:$importDuplicates)

$module.Result["changed"] = $importedDrivers.Count -gt 0

if ($module.Result["changed"])
{
    $module.Result["drivers"] = Format-ImportedDriver -Drivers $importedDrivers
}

$mdtDrive | Remove-PSDrive

$module.ExitJson()
