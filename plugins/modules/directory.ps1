#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.SharedFunctions

$spec = @{
    options = @{
        installation_path = @{
            type = 'path'
            required = $false
            default = 'C:\Program Files\Microsoft Deployment Toolkit'
        }
        name = @{
            type = 'str'
            required = $true
        }
        parent_directory = @{
            type = 'str'
            required = $true
        }
        mdt_directory_path = @{
            type = 'str'
            required = $true
        }
        state = @{
            type = 'str'
            required = $false
            default = 'present'
            choices = @(
                'present',
                'absent'
            )
        }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-MDTModule -InstallationPath $module.Params.installation_path

$name = $module.Params.name
$parentDirectory = $module.Params.parent_directory
$mdtDirectoryPath = $module.Params.mdt_directory_path
$state = $module.Params.state

if (-not (Test-Path -Path $mdtDirectoryPath))
{
    $module.FailJson("MDT directory path '$mdtDirectoryPath' does not exist.")
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

$parentDirectory = $parentDirectory.TrimStart('\')

$parentDirectoryPath = "$($mdtDrive.Name):\$($parentDirectory)"

if (-not (Test-Path -Path $parentDirectoryPath))
{
    $module.FailJson("Parent directory '$parentDirectoryPath' does not exist.")
}

$fullPath = "$($parentDirectoryPath)\$($name)"

$module.Result['changed'] = $false

if ($state -eq 'present')
{
    if (-not (Test-Path -LiteralPath $fullPath))
    {
        $module.Result['changed'] = $true

        if (-not $module.CheckMode)
        {
            New-Item -Path $fullPath -ItemType Directory | Out-Null

            if (-not (Test-Path -LiteralPath $fullPath))
            {
                $module.FailJson("Failed to create directory '$fullPath'.")
            }
        }
    }
}
elseif ($state -eq 'absent')
{
    if (Test-Path -LiteralPath $fullPath)
    {
        $module.Result['changed'] = $true

        if (-not $module.CheckMode)
        {
            Remove-Item -Path $fullPath -Recurse -Force | Out-Null

            if (Test-Path -LiteralPath $fullPath)
            {
                $module.FailJson("Failed to remove directory '$fullPath'.")
            }
        }
    }
}

$mdtDrive | Remove-PSDrive | Out-Null

$module.ExitJson()
