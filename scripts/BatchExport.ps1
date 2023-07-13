<#
Created by Camille Gouneau
13 July 2023

.Synopsis
Flexible Powershell Script for mass exporting of .ase and .aseprite files.

.Description
This script allows you to export an entire folder and every sub-folder of .ase and .aseprite files.
The only mandatory parameter is AsepritePath.
The others parameters will be prompted in CLI.

.Example
BatchExport.ps1 -AsepritePath "C:\Program Files (x86)\Steam\steamapps\common\Aseprite\Aseprite.exe"

#>

Param(
    [string]$AsepritePath,
    [string]$SpritesPath,
    [bool]$Recursion,
    [string[]]$Blacklist,
    [string]$ExportPath,
    [uint16]$Size
)

function prt {
    param (
        [string]$Message,
        [ConsoleColor]$ForegroundColor,
        [ConsoleColor]$BackgroundColor
    )
    $params = @{}
    if ($ForegroundColor) {
        $params.ForegroundColor = $ForegroundColor
    }
    if ($BackgroundColor) {
        $params.BackgroundColor = $BackgroundColor
    }
    Write-Host $Message @params
}

function Set-Sprites-Path {
    $CurrentFolder = Get-Location
    $script:SpritesPath = Read-Host "Path to your Sprite Folder.`nBlank for current folder. Current Folder : '${CurrentFolder}'`n"
    if ([string]::IsNullOrWhiteSpace($script:SpritesPath)) {
        $script:SpritesPath = "."
    }
    if (-not(Test-Path -Path $script:SpritesPath)) {
        prt "Folder not found at '${SpritesPath}'. Exiting." Red Black
        Exit
    }
    prt "Sprite Folder Path set : '${script:SpritesPath}' !" Black White
}

function Set-Export-Path {
    $CurrentFolder = Get-Location
    $script:ExportPath = Read-Host "Please enter the Path to your Exported Files Folder.`nUsing Blank or '.' will export the files next to the .ase/.aseprite files. Current Folder : '${CurrentFolder}'`n"
    if ([string]::IsNullOrWhiteSpace($script:ExportPath)) {
        $script:ExportPath = "."
    }
    if (-not(Test-Path -Path $script:ExportPath)) {
        prt "Folder not found at '${ExportPath}'. Exiting." Red Black
        Exit
    }
    prt "Export Path set : '${script:ExportPath}' !" Black White
}

function Set-Size {
    do {
        $exportSize = Read-Host "Please enter the Export Size (must be a number above 25 and under 1000) "
    } while ([string]::IsNullOrWhiteSpace($exportSize) -or !([int]$exportSize -ge 25 -and [int]$exportSize -le 1000))
    $script:Size = [int]$exportSize
    prt "Size set : '${script:Size}' !" Black White
}

function Write-Blacklist {
    if ($null -eq $script:Blacklist) {
        prt "Empty Blacklist"
    }
    else {
        prt "Blacklist :" White
        foreach ($bllist in $script:Blacklist) {
            prt "[${bllist}]"
        }
    }
}

function Set-Blacklist {
    $blacklistString = Read-Host "Enter blacklist. Each filename or foldername must be separated by a ';'. Do not add a ; at the end.`n"
    if ([string]::IsNullOrWhiteSpace($blacklistString)) {
        $script:Blacklist = $null
    }
    else {
        $script:Blacklist = $blacklistString.Split(";")
    }
    Write-Blacklist
    
}

function Is-In-Blacklist {
    Param(
        [string]$path
    )
    $names = $path.Split("\")
    $name = $names[-1]
    foreach ($bl in $script:Blacklist) {
        if ($bl -eq $name) {
            prt "[${path}] is blacklisted, skipping" Red
            return $true
        }
    }
    return $false
}

function Set-Recursion {
    $title = "BatchExport - Aseprite Scripts Collection"
    $message = "Do you want to export recursively ?"
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "The script will export files in every sub-folder."
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "The script will only export files of this folder."
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    $result = $host.ui.PromptForChoice($title, $message, $options, 0)
    switch ($result) {
        0 {
            $script:Recursion = $true
        } 1 {
            $script:Recursion = $false
        }
    }
    prt "Recursion is : ${script:Recursion}" Black White
}

function Write-Settings {
    prt "Settings`n--------------------------------------------------------------`n"
    prt "Source folder : ${script:SpritesPath}"
    #if (${Recursion}) {prt "Recursion : ON"} else {prt "Recursion : OFF"}
    prt "Recursion is : ${script:Recursion}"
    Write-Blacklist
    prt "Export folder : ${script:ExportPath}"
    prt "Size : ${script:Size}"
    prt "`n--------------------------------------------------------------`n"
}

function Validate-Settings {
    $title = "BatchExport - Aseprite Scripts Collection"
    $message = "Validate the settings and launch the export ?"
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Launch the export."
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Exit the script."
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    $result = $host.ui.PromptForChoice($title, $message, $options, 0)
    switch ($result) {
        0 {
            prt "Launching the export..." Magenta
        } 1 {
            prt "Export Cancelled" Red
            Exit
        }
    }
}

function Write-Names {
    Param(
        [string[]]$files
    )
    foreach ($file in $files) {
        prt $file
    }
}

function Check-File-Ase {
    Param(
        [string]$filePath
    )
    $splitt = $file.Split(".")
    $extension = $splitt[-1]
    if ($extension -eq "ase" -or $extension -eq "aseprite") {
        return $true
    }
    return $false
}

function Build-Export-Path {
    Param(
        [string]$currentPath,
        [string]$filename
    )
    $filenameNoExt = $filename.Split(".")[0]
    $exportName = "${filenameNoExt}_${script:Size}.png"
    if ($script:ExportPath -eq ".") {

        return "${currentPath}\${exportName}"
    }
    return = "${script:ExportPath}\${exportName}"

}

function Export-File {
    Param(
        [string]$path,
        [string]$filename
    )
    if (Is-In-Blacklist $filename) {
        return
    }
    
    if (Check-File-Ase filename) {
        prt "Exporting [${filename}]..."
        $fullpathSprite = "${path}\${filename}"
        $fullPathExport = Build-Export-Path $path $filename        
        $exportSize = $script:Size / 100
        & $script:AsepritePath -b $fullpathSprite --scale $exportSize --save-as $fullPathExport
        prt "Exported [${filename}] at [${fullPathExport}]" Green
        #is only useful if you use the -p options for faking the run to not desync the message from Aseprite and BatchExport.
        # Aseprite actually exporting does not print anything to the console.
        #Start-Sleep -Milliseconds 100
    }
    
    else {
        #prt "[${filename}] not an exportable file, skipping"
    }
}

function Export-Folder {
    Param(
        $path
    )
    prt "Entering folder [${path}]" Blue
    if (Is-In-Blacklist $path) {
        return
    }
    $filesInPath = Get-ChildItem -Path $path | Where-Object {!$_.PSIsContainer} | ForEach-Object {$_.Name}
    $foldersInPath = Get-ChildItem -Path $path | Where-Object {$_.PSIsContainer} | ForEach-Object {$_.Name}
    foreach ($file in $filesInPath) {
        Export-File ${path} ${file}
    }
    if ($script:Recursion) {
        foreach ($folderName in $foldersInPath) {
            if (!(Is-In-Blacklist $folderName)) {
                Export-Folder "${path}\${folderName}"
            }
        }
    }
}

#$CurrentPath

function Main {
    prt "Please set the parameters for the source files" Blue
    Set-Sprites-Path
    Set-Recursion
    Set-Blacklist
    prt "Please set the parameters for the source files" Blue
    Set-Export-Path
    Set-Size
    Write-Settings $SpritesPath
    Validate-Settings

    Export-Folder $script:SpritesPath
    #victory bell (for a future update maybe ?)
    #[console]::beep(2000,300)
}

Main