#requires -Version 2 -Modules posh-git

function Write-Theme {
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )
    $branchSymbol = $sl.GitSymbols.BranchSymbol
    #check the last command state and indicate if failed
    $promtSymbolColor = $sl.Colors.PromptSymbolColor
    If ($lastCommandFailed) {
        $promtSymbolColor = $sl.Colors.WithForegroundColor
    }
    
    #check the python virtual environment
    If (Test-VirtualEnv) {
        $prompt += Write-Prompt -Object ("(" + $(Get-VirtualEnvName) + ")")
    }
    
    # Writes the drive portion
    $drive = $sl.PromptSymbols.HomeSymbol
    $status = Get-VCSStatus
    $activePath = @()
    $currentDirPath = $pwd.Path.Split("\")
    if ($status) {
        # Get the leaf of the git repo
        $gitPath = $status.GitDir.Split("\")
        $gitDirSource = Split-Path -path $(Split-Path -path $status.GitDir -Parent) -Leaf
        $activePath = @()
        foreach ($dir in $currentDirPath) {
            if (!$gitPath.Contains($dir)) {
                $activePath += "\" + $dir
            }
        }
        $drive = "[$($branchSymbol) "
        if (!$path) {
            $drive += "$($gitDirSource)]"
        }
        else {
            $drive += "$($gitDirSource)]"
        }
    }
    elseif ($pwd.Path -ne $HOME) {
        $activePath = $currentDirPath
        $path = ""
        foreach($item in $activePath[-3..-1]) {
            $path += "\$($item)"
        }
        $drive = "..$($path)"
    }

    $prompt += Write-Prompt -Object $drive -ForegroundColor $sl.Colors.DriveForegroundColor
    $prompt += Write-Prompt -Object "::" -ForegroundColor $sl.Colors.WithForegroundColor

    if ($status) {
        $themeInfo = Get-VcsInfo -status ($status)
        # Remove the branch name from the info
        $printedInfo = $themeInfo.VcInfo -replace ($sl.GitSymbols.BranchSymbol + " " + $status.Branch + " "), ""
        $prompt += Write-Prompt -Object ("git=[") -ForegroundColor $sl.Colors.PromptHighlightColor
        if ($status.Upstream) {
            $prompt += Write-Prompt -Object ( $status.Upstream ) -ForegroundColor $sl.Colors.WithForegroundColor
        }
        else {
            $prompt += Write-Prompt -Object ( $sl.GitSymbols.BranchUntrackedSymbol + "/" + $status.Branch ) -ForegroundColor $sl.Colors.WithForegroundColor
        }
        $prompt += Write-Prompt -Object "]-(" -ForegroundColor $sl.Colors.PromptHighlightColor
        $prompt += Write-Prompt -Object " $($printedInfo) " -ForegroundColor $sl.Colors.WithForegroundColor
        $prompt += Write-Prompt -Object ")" -ForegroundColor $sl.Colors.PromptHighlightColor
        
        $path = [string]::Concat($activePath[-3..-1])
        if ($path.Length -ne 0) {
            $prompt += Write-Prompt -Object (" .." + $path) -ForegroundColor $sl.Colors.DriveForegroundColor
        }
    }

    ##################################
    ### Console Line Two
    ##################################
    $prompt += Set-Newline
    # Writes the postfixes to the prompt
    $prompt += Write-Prompt -Object ($sl.PromptSymbols.PromptIndicator + [char]::ConvertFromUtf32(0x25B6) + " ") -ForegroundColor $promtSymbolColor
    $prompt
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0x1F480) # 💀 (0x1F480)
$sl.Colors.PromptSymbolColor = [ConsoleColor]::Green
$sl.Colors.PromptHighlightColor = [ConsoleColor]::Blue
$sl.Colors.DriveForegroundColor = [ConsoleColor]::Cyan
$sl.Colors.WithForegroundColor = [ConsoleColor]::Red
$sl.GitSymbols.LocalWorkingStatusSymbol = [char]::ConvertFromUtf32(0x1F9EA) # 🧪 (0x1F9EA)
$sl.Colors.GitDefaultColor = [ConsoleColor]::Yellow
$sl.PromptSymbols.HomeSymbol = [char]::ConvertFromUtf32(0x1F3E1) # 🏡
$sl.GitSymbols.BranchIdenticalStatusToSymbol = [char]::ConvertFromUtf32(0x1F30C) # 🌌(0x1F30C)
$sl.GitSymbols.BranchAheadStatusSymbol = [char]::ConvertFromUtf32(0x1F6F0) # 🛰️(0x1F6F0)
$sl.GitSymbols.LocalStagedStatusSymbol = [char]::ConvertFromUtf32(0x1F680) # 🚀(0x1F680)
$sl.GitSymbols.BranchUntrackedSymbol = [char]::ConvertFromUtf32(0x1F4E1) # 📡 (0x1F4E1)
