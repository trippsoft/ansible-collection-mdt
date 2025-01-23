function Import-MDTModule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]$InstallationPath
    )

    if (-not (Get-Module -Name MicrosoftDeploymentToolkit))
    {
        $mdtBinPath = Join-Path -Path $InstallationPath -ChildPath 'Bin'
        $mdtModulePath = Join-Path -Path $mdtBinPath -ChildPath 'MicrosoftDeploymentToolkit.psd1'
        Import-Module -Name $mdtModulePath -ErrorAction Stop -Global | Out-Null
    }
}

function Get-MDTPSDrive {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]$Path
    )

    $mdtPSDrives = [Array](Get-PSDrive -Scope Global)

    foreach ($mdtPSDrive in $mdtPSDrives)
    {
        if ($mdtPSDrive.Root -ieq $Path -and $mdtPSDrive.Provider.Name -ieq "MDTProvider")
        {
            return $mdtPSDrive
        }
    }

    for ($i = 1; $i -lt 1000; $i++)
    {
        $name = "DS$($i.ToString().PadLeft(3, '0'))"
        
        $matchingDrive = $null
        foreach ($mdtPSDrive in $mdtPSDrives)
        {
            if ($mdtPSDrive.Name -eq $name)
            {
                $matchingDrive = $mdtPSDrive
                break
            }
        }

        if ($null -eq $matchingDrive)
        {
            return New-PSDrive -Name $name -PSProvider MDTProvider -Root $Path -Scope Global
        }
    }

    return $null
}

$exportMembers = @{
    Function = 'Import-MDTModule', 'Get-MDTPSDrive'
}

Export-ModuleMember @exportMembers
