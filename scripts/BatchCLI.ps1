<#
Created by Camille Gouneau
19 July 2023

.Synopsis
Flexible Powershell Script for applying CLI Aseprite command on a batch of .ase and .aseprite files.

.Description
This script allows you to call Aseprite.exe <your command> on an entire folder and every sub-folder of .ase and .aseprite files.
The only mandatory parameter is AsepritePath.
The others parameters will be prompted in CLI.

The script have been created to be used with AsecriptHub ! <https://github.com/Camille-Gouneau/AsecriptHub>

.Example
BatchCLI.ps1 -AsepritePath "C:\Program Files (x86)\Steam\steamapps\common\Aseprite\Aseprite.exe"

#>


Param(
    [string]$AsepritePath,
    [string]$SpritesPath,
    [bool]$Recursion,
    [string[]]$Blacklist,
    [string]$Command
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

function Set-Command {
    do {
        $command = Read-Host "Please enter your commands. They will be applied like so : 'Aseprite.exe -b <filepath> <your commands>' "
    } while ([string]::IsNullOrWhiteSpace($command))
    $script:Command = $command
    prt "Command set : '${script:Command}' !" Black White
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
    prt "Recursion is : ${script:Recursion}"
    Write-Blacklist
    prt "Command : ${script:Command}"
    prt "`n--------------------------------------------------------------`n"
}

function Confirm-Settings {
    $title = "BatchExport - Aseprite Scripts Collection"
    $message = "Confirm the settings and launch the export ?"
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Launch the export."
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Exit the script."
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    $result = $host.ui.PromptForChoice($title, $message, $options, 0)
    switch ($result) {
        0 {
            prt "Launching the batch CLI..." Magenta
        } 1 {
            prt "Batch CLI Cancelled" Red
            Exit
        }
    }
}

function Confirm-File-Ase {
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

function Use-Command-File {
    Param(
        [string]$path,
        [string]$filename
    )
    if (Is-In-Blacklist $filename) {
        return
    }
    
    if (Confirm-File-Ase filename) {
        prt "Executing command [${script:Command}] on [${filename}]..."
        $fullpathSprite = "${path}\${filename}"     
        
        & $script:AsepritePath -b $fullpathSprite $script:command
        
        #Sleep is only useful if you use the -p options for faking the run to not desync the message from Aseprite and BatchExport.
        # Aseprite actually exporting does not print anything to the console.
        #Start-Sleep -Milliseconds 100
    }
}

function Use-Command-Folder {
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
        Use-Command-File ${path} ${file}
    }
    if ($script:Recursion) {
        foreach ($folderName in $foldersInPath) {
            if (!(Is-In-Blacklist $folderName)) {
                Use-Command-Folder "${path}\${folderName}"
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
    Set-Command
    Write-Settings $SpritesPath
    Confirm-Settings

    Use-Command-Folder $script:SpritesPath
    #victory bell (for a future update maybe ?)
    #[console]::beep(2000,300)
}

Main