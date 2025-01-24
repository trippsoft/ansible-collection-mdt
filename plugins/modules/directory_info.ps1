#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell ansible_collections.trippsc2.mdt.plugins.module_utils.SharedFunctions

function Format-MDTObject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Microsoft.BDD.PSSnapIn.MDTObject]$Object
    )
    
    $formattedObject = @{
        enabled = [bool]::Parse($Object.enable)
        guid = $Object.guid
        is_directory = $Object.PSIsContainer
        name = $Object.Name
        node_type = $Object.NodeType
    }

    return $formattedObject
}

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
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-MDTModule -InstallationPath $module.Params.installation_path

$path = $module.Params.path
$mdtSharePath = $module.Params.mdt_share_path

if (-not (Test-Path -LiteralPath $mdtSharePath))
{
    $module.FailJson("MDT share path '$mdtSharePath' does not exist.")
}

$mdtDrive = Get-MDTPSDrive -Path $mdtSharePath

if ($null -eq $mdtDrive)
{
    $module.FailJson("Failed to find or create MDT PowerShell drive for '$mdtSharePath'.")
}

$path = $path.TrimStart('\')
$path = $path.TrimEnd('\')

$fullPath = "$($mdtDrive.Name):\$($path)"

$module.Result["changed"] = $false

if (-not (Test-Path -LiteralPath $fullPath -PathType Container))
{
    $module.Result["exists"] = $false
}
else
{
    $module.Result["exists"] = $true

    $directory = Get-Item -LiteralPath $fullPath

    $module.Result["info"] = Format-MDTObject -Object $directory

    $children = Get-ChildItem -LiteralPath $fullPath

    $formattedChildren = New-Object System.Collections.Generic.List[System.Collections.IDictionary]

    foreach ($child in $children)
    {
        $formattedChild = Format-MDTObject -Object $child

        $formattedChildren.Add($formattedChild)
    }

    $module.Result["info"]["children"] = $formattedChildren.ToArray()
}

$mdtDrive | Remove-PSDrive | Out-Null

$module.ExitJson()
