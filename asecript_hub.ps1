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
    [switch] $SetAsepritePath
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

$AsepritePath = Get-Content -Path .\params.txt

if ($SetAsepritePath -or $null -eq $AsepritePath) {
    do {
        $AsepritePath = Read-Host "Path to your Aseprite installation (leave blank to use 'C:\Program Files (x86)\Steam\steamapps\common\Aseprite')"
    } while ([string]::IsNullOrWhiteSpace($AsepritePath))
    if (-not(Test-Path -Path $AsepritePath)) {
        prt "Aseprite.exe not found at '${AsepritePath}'. Back to default : 'C:\Program Files (x86)\Steam\steamapps\common\Aseprite'" Red Black
        $AsepritePath = "C:\Program Files (x86)\Steam\steamapps\common\Aseprite"
    }
    prt "Path set : '${AsepritePath}' !" Black White
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "The path will be saved in '.\params.txt'"
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "The path will not be saved."
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

    $title = "scripts_hub.ps1 - Aseprite Scripts Collection"
    $message = "Do you want to save this path ?"
    $result = $host.ui.PromptForChoice($title, $message, $options, 1)
    switch ($result) {
        0 {
            prt "Saving Path..." Cyan Black
            Set-Content -Path ./params.txt -Value "${AsepritePath}"
            prt "Path Saved !" Green Black
        } 1 {
            prt "Path not saved." Magenta Black
        }
    }
    Exit
}
