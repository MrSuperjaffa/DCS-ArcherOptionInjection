
# Archer Option Injection for Windows & DCS World

v1.0.2 by Mr_Superjaffa#5430

Archer Option Injection allows for DCS mission settings to be configured from the outside, allowing for flexible mission configs using a single miz.

### Features

+ Automatic fetching of server mission.
+ Ability to force specific mission.
+ It's pretty lightweight. Powershell FTW.

### Requirements

1. Powershell 5.0 or Higher.
2. DCS World 2.5.5 or Higher.

### Install

+ Extract the zip contents into any folder.

### Usage

+ Configure the JSON as needed.
+ Ensure your serverSettings.lua is properly set.
+ Either run it manually through the .bat or directly with the .ps1

### Uninstall

+ Simply delete it.

### Limitations

+ The script will only grab the first mission in the `serverConfig.lua`.
