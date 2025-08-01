#Requires -Version 4.0

[CmdletBinding(SupportsShouldProcess)]
Param(
    [ValidateNotNullOrEmpty()]
    [String]$Path,

    [ValidateSet('System', 'User')]
    [String]$Scope = 'System',

    [ValidateSet('Manual', 'Shell')]
    [String]$Method = 'Manual'
)

# Supported font extensions
$ValidExts = @('.otf', '.ttf')
$ValidExtsRegex = '\.(otf|ttf)$'

Function Install-FontManual {
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory)]
        [IO.FileInfo[]]$Fonts,

        [ValidateSet('System', 'User')]
        [String]$Scope = 'System'
    )

    Begin {
        switch ($Scope) {
            'System' {
                $FontsFolder = [Environment]::GetFolderPath('Fonts')
                $FontsRegKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
            }
            'User' {
                $FontsFolder = Join-Path -Path ([Environment]::GetFolderPath('LocalApplicationData')) -ChildPath 'Microsoft\Windows\Fonts'
                $FontsRegKey = 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
            }
        }

        if ($Scope -eq 'User') {
            $null = New-Item -Path $FontsFolder -ItemType Directory -ErrorAction Ignore
            $null = New-Item -Path $FontsRegKey -ErrorAction Ignore
        }

        try {
            $FontsReg = Get-Item -Path $FontsRegKey -ErrorAction Stop
        } catch {
            throw ('Unable to open {0} fonts registry key: {1}' -f $Scope.ToLower(), $FontsRegKey)
        }

        Add-Type -AssemblyName PresentationCore -ErrorAction Stop
    }

    Process {
        foreach ($Font in $Fonts) {
            $FontUri = New-Object -TypeName Uri -ArgumentList $Font.FullName
            try {
                $GlyphTypeface = New-Object -TypeName Windows.Media.GlyphTypeface -ArgumentList $FontUri
            } catch {
                Write-Error -Message ('Unable to import font: {0}' -f $Font.Name)
                continue
            }

            $FontCulture = 'en-US'
            if ($GlyphTypeface.Win32FamilyNames.ContainsKey($FontCulture) -and $GlyphTypeface.Win32FaceNames.ContainsKey($FontCulture)) {
                $FontFamilyName = $GlyphTypeface.Win32FamilyNames[$FontCulture]
                $FontFaceName = $GlyphTypeface.Win32FaceNames[$FontCulture]
            } else {
                Write-Error -Message ('Font does not contain metadata for {0} culture: {1}' -f $FontCulture, $Font.Name)
                continue
            }

            # Matches the convention used by the Explorer shell
            $FontInstallPath = Join-Path -Path $FontsFolder -ChildPath $Font.Name
            $FontInstallSuffixNum = -1
            while (Test-Path -Path $FontInstallPath) {
                $FontInstallSuffixNum++
                $FontInstallName = '{0}_{1}{2}' -f $Font.BaseName, $FontInstallSuffixNum, $Font.Extension
                $FontInstallPath = Join-Path -Path $FontsFolder -ChildPath $FontInstallName
            }
            Write-Debug -Message ('[{0}] Font install path: {1}' -f $Font.Name, $FontInstallPath)

            # Matches the convention used by the Explorer shell
            if ($FontFaceName -eq 'Regular') {
                $FontRegName = '{0} (TrueType)' -f $FontFamilyName
            } else {
                $FontRegName = '{0} {1} (TrueType)' -f $FontFamilyName, $FontFaceName
            }
            Write-Debug -Message ('[{0}] Font registry name: {1}' -f $Font.Name, $FontRegName)

            if ($Scope -eq 'User') {
                $FontRegValue = $FontInstallPath
            } else {
                $FontRegValue = [IO.Path]::GetFileName($FontInstallPath)
            }

            if ($FontsReg.Property.Contains($FontRegName)) {
                Write-Error -Message ('Font registry name already exists: {0}' -f $FontRegName)
                continue
            }

            if ($PSCmdlet.ShouldProcess($Font.Name, 'Install font manually')) {
                Write-Verbose -Message ('Installing font manually: {0}' -f $Font.Name)
                Copy-Item -Path $Font.FullName -Destination $FontInstallPath
                $null = New-ItemProperty -Path $FontsRegKey -Name $FontRegName -PropertyType String -Value $FontRegValue
            }
        }
    }
}

Function Install-FontShell {
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory)]
        [IO.FileInfo[]]$Fonts
    )

    Begin {
        # ShellSpecialFolderConstants enumeration
        # https://docs.microsoft.com/en-us/windows/desktop/api/Shldisp/ne-shldisp-shellspecialfolderconstants
        $ssfFONTS = 20

        # _SHFILEOPSTRUCTA structure
        # https://docs.microsoft.com/en-us/windows/desktop/api/shellapi/ns-shellapi-_shfileopstructa
        $FOF_SILENT = 4
        $FOF_NOCONFIRMATION = 16
        $FOF_NOERRORUI = 1024
        $FOF_NOCOPYSECURITYATTRIBS = 2048

        try {
            $ShellApp = New-Object -ComObject Shell.Application
        } catch {
            throw $_
        }

        try {
            $FontsFolder = $ShellApp.NameSpace($ssfFONTS)
        } catch {
            throw $_
        } finally {
            $null = [Runtime.InteropServices.Marshal]::FinalReleaseComObject($ShellApp)
        }

        $CopyOptions = $FOF_SILENT + $FOF_NOCONFIRMATION + $FOF_NOERRORUI + $FOF_NOCOPYSECURITYATTRIBS
    }

    Process {
        foreach ($Font in $Fonts) {
            if ($PSCmdlet.ShouldProcess($Font.Name, 'Install font via shell')) {
                Write-Verbose -Message ('Installing font via shell: {0}' -f $Font.Name)
                $FontsFolder.CopyHere($Font.FullName, $CopyOptions)
            }
        }
    }

    End {
        $null = [Runtime.InteropServices.Marshal]::FinalReleaseComObject($FontsFolder)
        $null = [Runtime.InteropServices.Marshal]::FinalReleaseComObject($ShellApp)
    }
}

Function Test-IsAdministrator {
    [CmdletBinding()]
    Param()

    $User = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    if ($User.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        return $true
    }
    return $false
}

Function Test-PerUserFontsSupported {
    [CmdletBinding()]
    Param()

    # Windows 10 1809 introduced support for installing fonts per-user. The
    # corresponding release build number is 17763 (ignoring Insider builds).
    $BuildNumber = [Int](Get-CimInstance -ClassName 'Win32_OperatingSystem' -Verbose:$false).BuildNumber
    if ($BuildNumber -ge 17763) {
        return $true
    }

    return $false
}

# Validate the install scope and method
if ($Scope -eq 'System') {
    if (!(Test-IsAdministrator)) {
        throw 'Administrator privileges are required to install system-wide fonts.'
    } elseif ($Method -eq 'Shell' -and (Test-PerUserFontsSupported)) {
        throw 'Installing fonts system-wide via the Shell API is unsupported from Windows 10 1809.'
    }
} elseif (!(Test-PerUserFontsSupported)) {
    throw 'Per-user fonts are only supported from Windows 10 1809.'
}

# Get the latest release info from nerd-fonts repository
echo "Getting latest release info from GitHub API..."
$latestReleaseUrl = "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest"
$releaseInfo = Invoke-RestMethod -Uri $latestReleaseUrl
$cascadiaCodeAsset = $releaseInfo.assets | Where-Object { $_.name -eq "CascadiaCode.zip" }

if (-not $cascadiaCodeAsset) {
    throw "CascadiaCode.zip not found in the latest release"
}

echo "Downloading CascadiaCode.zip from: $($cascadiaCodeAsset.browser_download_url)"
Invoke-WebRequest -Uri $cascadiaCodeAsset.browser_download_url -OutFile CascadiaCode.zip
$tmpFolder = New-TemporaryFile | %{ rm $_; mkdir $_ }

echo "Extracting CascadiaCode.zip to temporary folder: $tmpFolder"
Expand-Archive -LiteralPath CascadiaCode.zip -DestinationPath $tmpFolder
Remove-Item -Path .\CascadiaCode.zip

# Validate the source font path
try {
    $SourceFontPath = Get-Item -Path $tmpFolder -ErrorAction Stop
} catch {
    throw ('Provided path is invalid: {0}' -f $tmpFolder)
}

# Enumerate fonts to be installed
if ($SourceFontPath -is [IO.DirectoryInfo]) {
    $SourceFonts = @(Get-ChildItem -Path $SourceFontPath | Where-Object Extension -In $ValidExts)

    if (!$SourceFonts) {
        throw ('Unable to locate any fonts in provided directory: {0}' -f $SourceFontPath)
    }
} elseif ($SourceFontPath -is [IO.FileInfo]) {
    if ($SourceFontPath.Extension -notin $ValidExts) {
        throw ('Provided file does not appear to be a valid font: {0}' -f $SourceFontPath)
    }

    $SourceFonts = @($SourceFontPath)
} else {
    throw ('Expected directory or file but received: {0}' -f $SourceFontPath.GetType().Name)
}

# Install fonts using selected method
if ($SourceFonts) {
    echo "Installing fonts: $($SourceFonts.Name)"
    switch ($Method) {
        'Manual' { Install-FontManual -Fonts $SourceFonts -Scope $Scope }
        'Shell' { Install-FontShell -Fonts $SourceFonts }
    }
}
