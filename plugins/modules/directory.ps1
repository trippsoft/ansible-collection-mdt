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
        path = @{
            type = 'str'
            required = $true
        }
        mdt_share_path = @{
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

$path = $module.Params.path
$mdtSharePath = $module.Params.mdt_share_path
$state = $module.Params.state

if (-not (Test-Path -Path $mdtSharePath))
{
    $module.FailJson("MDT share path '$mdtSharePath' does not exist.")
}

$mdtDrive = Get-MDTPSDrive -Path $mdtSharePath

if ($null -eq $mdtDrive)
{
    $module.FailJson("Failed to find or create MDT PowerShell drive for '$mdtSharePath'.")
}

if ($mdtDrive.ReadOnly)
{
    $module.FailJson("MDT drive '$($mdtDrive.Name)' is read-only.")
}

$path = $path.TrimStart('\')
$path = $path.TrimEnd('\')
$path = $path.Replace('/', '\')

$module.Result['changed'] = $false

if ($state -eq 'present')
{
    $pathSegments = $path.Split('\')

    $fullPath = "$($mdtDrive.Name):"

    foreach ($segment in $pathSegments)
    {
        $fullPath = "$($fullPath)\$($segment)"

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
}
elseif ($state -eq 'absent')
{
    $fullPath = "$($mdtDrive.Name):\$path"

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
