<#
Created by Camille Gouneau
12 July 2023

.Synopsis
Hub script for launching my aseprite lua scripts

.Description


.Parameter -SetAsepritePath
If this is your first time using the script or if you moved Aseprite.exe, you can change the path with this command

.Example
Setup.ps1
See description

.Example
Setup.ps1 -SetAsepritePath

#>

Param(
    [switch] $SetAsepritePath,
    [switch] $SetScriptFolderPath
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

$params = (Get-Content -Raw -Path .\params.txt) -split '\r?\n'
$AsepritePath = $params[0]
$ScriptFolderPath = $params[1]
$ScriptsArray

function Write-Saved-Params {
    prt "Aseprite Path = '${AsepritePath}'"
    prt "Script Folder Path = '${ScriptFolderPath}'"
}

function Set-Aseprite-Path {
    do {
        $script:AsepritePath = Read-Host "Path to your Aseprite installation (Enter wrong path to return to default : : 'C:\Program Files (x86)\Steam\steamapps\common\Aseprite')"
    } while ([string]::IsNullOrWhiteSpace($script:AsepritePath))
    if (-not(Test-Path -Path $script:AsepritePath)) {
        prt "Aseprite.exe not found at '${AsepritePath}'. Back to default : 'C:\Program Files (x86)\Steam\steamapps\common\Aseprite'" Red Black
        $script:AsepritePath = "C:\Program Files (x86)\Steam\steamapps\common\Aseprite"
    }
    prt "Path set : '${script:AsepritePath}' !" Black White
}

function Set-Script-Path {
    do {
        $script:ScriptFolderPath = Read-Host "Path to your script folder (Enter wrong path to return to default : '.\scripts')"
    } while ([string]::IsNullOrWhiteSpace($script:ScriptFolderPath))
    if (-not(Test-Path -Path $script:ScriptFolderPath)) {
        prt "Folder not found at '${ScriptFolderPath}'. Back to default : '.\scripts'" Red Black
        $script:ScriptFolderPath = ".\scripts"
    }
    prt "Path set : '${ScriptFolderPath}' !" Black White
}

function Test-Saved-Params {
    $var = $true
    if ($SetAsepritePath -or $null -eq $script:AsepritePath -or -not(Test-Path -Path $script:AsepritePath)) {
        prt "Aseprite not found !" Black Red
        Set-Aseprite-Path
        $var = $false
    }
    if ($SetScriptFolderPath -or $null -eq $script:ScriptFolderPath -or -not(Test-Path -Path $script:ScriptFolderPath)) {
        prt "Script Folder not found !" Black Red
        Set-Script-Path
        $var = $false
    }
    return $var
}

function Save-Params {
    $title = "scripts_hub.ps1 - Aseprite Scripts Collection"
    $message = "Do you want to save the paramaters in .\params.txt ?"
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "The path will be saved in '.\params.txt'"
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "The path will not be saved."
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    $result = $host.ui.PromptForChoice($title, $message, $options, 1)
    switch ($result) {
        0 {
            prt "Saving Path..." Cyan Black
            prt $script:AsepritePath
            Set-Content -Path params.txt -Value "${AsepritePath}"
            prt $script:ScriptFolderPath
            Add-Content -Path params.txt -Value "${ScriptFolderPath}"
            prt "Path Saved !" Green Black
        } 1 {
            prt "Path not saved." Magenta Black
        }
    }
}

function Write-Scripts {
    foreach ($script in $script:ScriptArray) {
        prt $script
    }
}

function Get-Scripts {
    prt "Scripts Founds :"
    $script:ScriptArray = Get-ChildItem -Path $script:ScriptFolderPath | Where-Object {!$_.PSIsContainer} | ForEach-Object {$_.Name}
}

function Invoke-Script {
    param (
        [string]$ScriptName
    )
    if ($ScriptName.Substring($ScriptName.Length - 4) -eq ".lua") {
        & $script:AsepritePath -b -script "${script:ScriptFolderPath}\${ScriptName}"
    }
    elseif ($ScriptName.Substring($ScriptName.Length - 4) -eq ".ps1") {
        & ${script:ScriptFolderPath}\${ScriptName} -AsepritePath ${script:AsepritePath}
    }
}

function Select-Script {
    $title = "scripts_hub.ps1 - Aseprite Scripts Collection"
    $message = "Select your script !"
    [System.Management.Automation.Host.ChoiceDescription[]]$options = @()
    foreach ($script in $script:ScriptArray) {
        $option = New-Object System.Management.Automation.Host.ChoiceDescription "&${script}"
        $options += $option
    }
    $result = $host.ui.PromptForChoice($title, $message, $options, 0)
    $name = $script:ScriptArray[$result]
    prt "${name} Output :`n--------------------------------------------------------------`n" Blue
    Invoke-Script -ScriptName $name
}

function Main {
    Write-Saved-Params
    if (!(Test-Saved-Params)) {
        Save-Params
    }
    prt "Setup finished !`n--------------------------------------------------------------`n"

    Get-Scripts
    Select-Script
}

Main