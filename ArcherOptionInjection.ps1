<#
    Author: Mr_Superjaffa#5430
    Description: Inject missions options for use on servers
    Version: v1.0.0
    Modified: May 15th/2021
    Notes: N/A
#>

Function Write-Log {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$False)]
    [ValidateSet("INFO","WARN","ERROR","FATAL","DEBUG")]
    [String]
    $Level = "INFO",

    [Parameter(Mandatory=$True)]
    [string]
    $Message,

    [Parameter(Mandatory=$False)]
    [string]
    $logfile
    )

    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $Line = "$Stamp $Level $Message"
    If($LogFile) {
        Add-Content $LogFile -Value $Line
    }
    Else {
        Write-Output $Line
    }
}

<#
    Input: Any string.
    Output: Location of first found matching string in an array of text.
    Remarks: N/A
#>
Function Get-Element($Array, $Search) {
    for($i=1; $i -le $Array.Length; $i++) {
        If($Array[$i] -Match $Search) {
            $Element = $i
            $i = $Array.Length }}
return $Element }

Function Add-Element($ArrayIn, [int]$InsertIndex, $InputString) {
    $ArrayA = $ArrayIn[0..$InsertIndex]
    $ArrayB = $ArrayIn[$InsertIndex..$ArrayIn.Count]
    
    $ArrayA[$InsertIndex] = $InputString
    $ArrayA += $ArrayB

    Return $ArrayA
}

Function Export-Data ($Name, $Array, $Search, $Data, $Export) {
    Try {
        If ((Get-Element -Array $Array -Search $Search) -and $Data) {
            Write-Log "INFO" "Exporting ${Name}: $Data" $Log
            $Array[(Get-Element -Array $Array -Search $Search)] = $Export
        } ElseIf ($Data) {
            Write-Log "INFO" "Creating and Exporting ${Name}: $Data" $Log
            Switch -regex ($Array[0]) {
                ("mission") {$Array = Add-Element -ArrayIn $Array -InsertIndex ((Get-Element -Array $Array -Search "\[`"forcedOptions`"\]") + 2) -InputString $Export}
                ("options") {$Array = Add-Element -ArrayIn $Array -InsertIndex ((Get-Element -Array $Array -Search "\[`"miscellaneous`"\]") + 2) -InputString $Export}
            }
        }
    
        Return $Array
    } Catch {Write-Log "ERROR" "Error exporting options data: $Name" $Log}
}

####
# INITIALIZING
####

#$ErrorActionPreference = "Stop"
$Version = "v1.0.0"
$Settings = Get-Content "./OptionInjectionSettings.json" | ConvertFrom-Json
$Log = $Settings.Setup.Log
$SavedGamesFolder = $Settings.Setup.SavedGamesFolder
$ForceMission = $Settings.Setup.Mission
$DEBUG = $Settings.General.DEBUG

Try {
If (!(Test-Path $Log) -and $Log){
    New-Item -Path $Log
    Write-Log "WARN" "Log not found. Creating log at @Log" $Log
} Elseif (!(Test-Path $Log) -and !$Log) {
    New-Item -Path "./" -Name "OptionInjection.log"
    Write-Log "WARN" "Log not found. Creating log at @Log" $Log
}
} Catch {Write-Log "FATAL" "Log creation failed!" $Log}

Write-Log "INFO" "---------- Initializing Archer Option Injection $Version ----------" $Log
#Write-Log "INFO" $MissionFolder $Log

# Exit if disabled. Nothing to do here.
If ($InjectionSettings.Settings.Enabled -eq "False") {
    Write-Log "INFO" "Script Disabled. Exiting..." $Log
    Exit
} Else {
    Write-Log "INFO" "Script Enabled. Continuing..." $Log
}

If (Test-Path ".\TempMiz") {
    Write-Log "INFO" "Cleaning up temp miz..." $Log
    Remove-Item ".\TempMiz" -Force
}

If ($Settings.Setup.Mission) {
    If (Test-Path $ForceMission) {
        $miz = $ForceMission
        Write-Log "INFO" "Fetched Mission: $miz" $Log
    }
} Elseif (Test-Path (Join-Path -path $SavedGamesFolder -childPath "Config\serverSettings.lua")) {
    Write-Log "INFO" "Found Saved Games Folder: $SavedGamesFolder" $Log
    $serverConfigLocation = Join-Path -Path $SavedGamesFolder -ChildPath "Config\serverSettings.lua"
    $serverConfig = Get-Content $serverConfigLocation
    If($serverConfig) {Write-Log "INFO" "Found Server Config: $serverConfigLocation" $Log}
    $miz = $ServerConfig[(Get-Element -Array $serverConfig -Search "\[1\]")]|%{$_.split('"')[1]}
    Write-Log "INFO" "Fetched Mission: $miz" $Log
}

Write-Log "INFO" "Unzipping miz..." $Log
Try {
    # Gets the latest modified mission in the mission folder.
    $miz | Rename-Item -NewName {$miz -replace ".miz",".zip"} -PassThru |  Set-Variable -Name Mizzip # Renaming it to a .zip.
    Get-ChildItem -Path $mizzip | Expand-Archive -DestinationPath "./TempMiz" -Force # Extracting it into ./TempMiz for editing.
    $mission = Get-Content ./TempMiz/mission # Finally getting the contents of the mission.
    $options = Get-Content ./TempMiz/options
    $mizzip = $mizzip.fullname
} Catch {Write-Log "FATAL" "Mission extraction failed!" $Log}

Write-Log "INFO" "Making sense out the settings..." $Log
Try {
    $Mission_External_Views = ($Settings.Options.Mission_External_Views).ToString().ToLower()
    $Player_External_Views = ($Settings.Options.Player_External_Views).ToString().ToLower()
    $Spectator_External_Views = ($Settings.Options.Spectator_External_Views).ToString().ToLower()
    $F5_Nearest_Aircraft = ($Settings.Options.F5_Nearest_Aircraft).ToString().ToLower()
    $F11_Free_Camera = ($Settings.Options.F11_Free_Camera).ToString().ToLower()
    $F10_Map_Enable = ($Settings.Options.F10_Map_Enable).ToString().ToLower()
    $Padlock = ($Settings.Options.Padlock).ToString().ToLower()

    $Game_Flight_Mode = ($Settings.Options.Game_Flight_Mode).ToString().ToLower()
    $Game_Avionic_Mode = ($Settings.Options.Game_Avionic_Mode).ToString().ToLower()
    $Immortal = ($Settings.Options.Immortal).ToString().ToLower()
    $Unlimited_Fuel = ($Settings.Options.Unlimited_Fuel).ToString().ToLower()
    $Unlimited_Weapons = ($Settings.Options.Unlimited_Weapons).ToString().ToLower()
    $Easy_Communication = ($Settings.Options.Easy_Communication).ToString().ToLower()
    $Radio_Assists = ($Settings.Options.Radio_Assists).ToString().ToLower()
    $Unrestricted_SATNAV = ($Settings.Options.Unrestricted_SATNAV).ToString().ToLower()
    $Wake_Turbulence = ($Settings.Options.Wake_Turbulence).ToString().ToLower()
    $Random_System_Failures = ($Settings.Options.Random_System_Failures).ToString().ToLower()
    $Mini_HUD = ($Settings.Options.Mini_HUD).ToString().ToLower()
    $Cockpit_Vis_Recon = ($Settings.Options.Cockpit_Vis_Recon).ToString().ToLower()
    $F10_Map_User_Marks = ($Settings.Options.F10_Map_User_Marks).ToString().ToLower()
    $Cockpit_Status_Bar = ($Settings.Options.Cockpit_Status_Bar).ToString().ToLower()
    $Battle_Damage_Assess = ($Settings.Options.Battle_Damage_Assess).ToString().ToLower()

    $Birds = $Settings.Options.Birds
} Catch {}

Switch ($Settings.Options.F10_View_Options) {
    1 {$F10_View_Options = "optview_onlymap"}
    2 {$F10_View_Options = "optview_myaircraft"}
    3 {$F10_View_Options = "optview_allies"}
    4 {$F10_View_Options = "optview_onlyallies"}
    5 {$F10_View_Options = "optview_all"}
    default {$F10_View_Options = $null}
}

If ($Settings.Options.Labels -In 1..5) {
    $Labels = $Settings.Options.Labels
} Else {
    $Labels = $null
}

Switch ($Settings.Options.Civ_Traffic) {
    1 {$Civ_Traffic = ""}
    2 {$Civ_Traffic = "low"}
    3 {$Civ_Traffic = "medium"}
    4 {$Civ_Traffic = "high"}
    default {$Civ_Traffic = $null}
}

Switch ($Settings.Options.G_Effects) {
    1 {$G_Effects = "none"}
    2 {$G_Effects = "reduced"}
    3 {$G_Effects = "realistic"}
    default {$G_Effects = $null}
}

Write-Log "INFO" "Exporting options..." $Log

Try {
    $mission = Export-Data -Name "Mission External Views" -Array $mission -Search "\[`"externalViews`"\]" -Data $Mission_External_Views -Export "`t`t[`"externalViews`"] = $Mission_External_Views,"
    $options = Export-Data -Name "Player External Views" -Array $options -Search "\[`"externalViews`"\]" -Data $Player_External_Views -Export "`t`t[`"externalViews`"] = $Player_External_Views,"
    $options = Export-Data -Name "Spectator External Views" -Array $options -Search "\[`"spectatorExternalViews`"\]" -Data $Spectator_External_Views-Export "`t`t[`"spectatorExternalViews`"] = $Spectator_External_Views,"
    $options = Export-Data -Name "F5 View" -Array $options -Search "\[`"f5_nearest_ac`"\]" -Data $F5_Nearest_Aircraft -Export "`t`t[`"f5_nearest_ac`"] = $F5_Nearest_Aircraft,"
    $options = Export-Data -Name "F11 View" -Array $options -Search "\[`"f11_free_camera`"\]" -Data $F11_Free_Camera -Export "`t`t[`"f11_free_camera`"] = $F11_Free_Camera,"
    $options = Export-Data -Name "F10 View" -Array $options -Search "\[`"f10_awacs`"\]" -Data $F10_Map_Enable -Export "`t`t[`"f10_awacs`"] = $F10_Map_Enable,"
    $mission = Export-Data -Name "Padlock" -Array $mission -Search "\[`"padlock`"\]" -Data $Padlock -Export "`t`t[`"padlock`"] = $Padlock,"
    $mission = Export-Data -Name "Easy Flight Mode" -Array $mission -Search "\[`"easyFlight`"\]" -Data $Game_Flight_Mode -Export "`t`t[`"easyFlight`"] = $Game_Flight_Mode,"
    $mission = Export-Data -Name "Easy Avionics Mode" -Array $mission -Search "\[`"easyRadar`"\]" -Data $Game_Avionic_Mode -Export "`t`t[`"easyRadar`"] = $Game_Avionic_Mode,"
    $mission = Export-Data -Name "Immortality" -Array $mission -Search "\[`"immortal`"\]" -Data $Immortal -Export "`t`t[`"immortal`"] = $Immortal,"
    $mission = Export-Data -Name "Unlimited Fuel" -Array $mission -Search "\[`"fuel`"\]" -Data $Unlimited_Fuel -Export "`t`t[`"fuel`"] = $Unlimited_Fuel,"
    $mission = Export-Data -Name "Unlimited Weapons" -Array $mission -Search "\[`"weapons`"\]" -Data $Unlimited_Weapons -Export "`t`t[`"weapons`"] = $Unlimited_Fuel,"
    $mission = Export-Data -Name "Easy Communication" -Array $mission -Search "\[`"easyCommunication`"\]" -Data $Easy_Communication -Export "`t`t[`"easyCommunication`"] = $Easy_Communication,"
    $mission = Export-Data -Name "Radio Assists" -Array $mission -Search "\[`"radio`"\]" -Data $Radio_Assists -Export "`t`t[`"radio`"] = $Radio_Assists,"
    $mission = Export-Data -Name "Unrestricted SATNAV" -Array $mission -Search "\[`"unrestrictedSATNAV`"\]" -Data $Unrestricted_SATNAV -Export "`t`t[`"unrestrictedSATNAV`"] = $Unrestricted_SATNAV,"
    $mission = Export-Data -Name "Wake Turbulence" -Array $mission -Search "\[`"wakeTurbulence`"\]" -Data $Wake_Turbulence -Export "`t`t[`"wakeTurbulence`"] = $Wake_Turbulence,"
    $mission = Export-Data -Name "Random System Failures" -Array $mission -Search "\[`"accidental_failures`"\]" -Data $Random_System_Failures -Export "`t`t[`"accidental_failures`"] = $Random_System_Failures,"
    $mission = Export-Data -Name "Mini HUD" -Array $mission -Search "\[`"miniHUD`"\]" -Data $Mini_HUD -Export "`t`t[`"miniHUD`"] = $Mini_HUD,"
    $mission = Export-Data -Name "Cockpit Visual Recon" -Array $mission -Search "\[`"cockpitVisualRM`"\]" -Data $Cockpit_Vis_Recon -Export "`t`t[`"cockpitVisualRM`"] = $Cockpit_Vis_Recon,"
    $mission = Export-Data -Name "F10 User Marks" -Array $mission -Search "\[`"userMarks`"\]" -Data $F10_Map_User_Marks -Export "`t`t[`"userMarks`"] = $F10_Map_User_Marks,"
    $mission = Export-Data -Name "Cockpit Status Bar" -Array $mission -Search "\[`"cockpitStatusBarAllowed`"\]" -Data $Cockpit_Status_Bar -Export "`t`t[`"cockpitStatusBarAllowed`"] = $Cockpit_Status_Bar,"
    $mission = Export-Data -Name "Battle Damage Assessment" -Array $mission -Search "\[`"RBDAI`"\]" -Data $Battle_Damage_Assess -Export "`t`t[`"RBDAI`"] = $Battle_Damage_Assess,"
    $mission = Export-Data -Name "Birds" -Array $mission -Search "\[`"birds`"\]" -Data $Birds -Export "`t`t[`"birds`"] = $Birds,"
    $mission = Export-Data -Name "F10 View Options" -Array $mission -Search "\[`"optionsView`"\]" -Data $F10_View_Options -Export "`t`t[`"optionsView`"] = `"$F10_View_Options`","
    $mission = Export-Data -Name "Labels" -Array $mission -Search "\[`"labels`"\]" -Data $Labels -Export "`t`t[`"labels`"] = $Labels,"
    $mission = Export-Data -Name "Civ Traffic" -Array $mission -Search "\[`"civTraffic`"\]" -Data $Civ_Traffic -Export "`t`t[`"civTraffic`"] = `"$Civ_Traffic`","
    $mission = Export-Data -Name "G Effects" -Array $mission -Search "\[`"geffect`"\]" -Data $G_Effects -Export "`t`t[`"geffect`"] = `"$G_Effects`","
} Catch {Write-Log "FATAL" "Error exporting option data!" $Log}

Write-Log "INFO" "Finished Export." $Log

Try {Set-Content -Path "./TempMiz/mission" -Value $mission -Force} Catch {Write-Log "FATAL" "Mission export failed!"}
Try {Set-Content -Path "./TempMiz/options" -Value $options -Force} Catch {Write-Log "FATAL" "Options export failed!"}

Try {
Compress-Archive -Path "./TempMiz/mission" -Update -DestinationPath $mizzip
$mizzip | Rename-Item -NewName {$mizzip -replace ".zip",".miz"} -Force # Renaming it to a .zip.
Remove-Item "./TempMiz" -Recurse -Force
} Catch {Write-Log "FATAL" "Zipping failed!" $Log}

Write-Log "INFO" "Script complete. Exiting..." $Log
Exit