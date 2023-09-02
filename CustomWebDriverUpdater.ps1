<#
_________        ___.                   _____         __              __      __      ___.   ________        .__                    ____ ___            .___       __                
\_   ___ \___.__.\_ |__   ___________  /  _  \_______|  | __         /  \    /  \ ____\_ |__ \______ \_______|__|__  __ ___________|    |   \______   __| _/____ _/  |_  ___________ 
/    \  \<   |  | | __ \_/ __ \_  __ \/  /_\  \_  __ \  |/ /  ______ \   \/\/   // __ \| __ \ |    |  \_  __ \  \  \/ // __ \_  __ \    |   /\____ \ / __ |\__  \\   __\/ __ \_  __ \
\     \___\___  | | \_\ \  ___/|  | \/    |    \  | \/    <  /_____/  \        /\  ___/| \_\ \|    `   \  | \/  |\   /\  ___/|  | \/    |  / |  |_> > /_/ | / __ \|  | \  ___/|  | \/
 \______  / ____| |___  /\___  >__|  \____|__  /__|  |__|_ \           \__/\  /  \___  >___  /_______  /__|  |__| \_/  \___  >__|  |______/  |   __/\____ |(____  /__|  \___  >__|   
        \/\/          \/     \/              \/           \/                \/       \/    \/        \/                    \/                |__|        \/     \/          \/       
__________                __                              .___       _________                              __  ._____.   .__.__  .__  __                                            
\______   \_____    ____ |  | ____  _  _______ _______  __| _/______ \_   ___ \  ____   _____ ___________ _/  |_|__\_ |__ |__|  | |__|/  |_ ___.__.                                  
 |    |  _/\__  \ _/ ___\|  |/ /\ \/ \/ /\__  \\_  __ \/ __ |/  ___/ /    \  \/ /  _ \ /     \\____ \__  \\   __\  || __ \|  |  | |  \   __<   |  |                                  
 |    |   \ / __ \\  \___|    <  \     /  / __ \|  | \/ /_/ |\___ \  \     \___(  <_> )  Y Y  \  |_> > __ \|  | |  || \_\ \  |  |_|  ||  |  \___  |                                  
 |______  /(____  /\___  >__|_ \  \/\_/  (____  /__|  \____ /____  >  \______  /\____/|__|_|  /   __(____  /__| |__||___  /__|____/__||__|  / ____|                                  
        \/      \/     \/     \/              \/           \/    \/          \/             \/|__|       \/             \/                  \/       
#>

###########################
#Author: Joe Agler
#Purpose: Add backwards compatibility (pre v13.2) for CyberArk WebDriverUpdater tool
#Github URL: https://github.com/aglerj/CyberArk-WebDriverUpdater-BackwardsCompatibility

#KeyVault Solutions
#Looking for pre-packaged custom CyberArk plugins, or need help installing and/or creating a plugin of your own? 
#Check out https://www.keyvaultsolutions.com 


#Credit: Builds upon CyberArk Marketplace WebDriverUpdater tool - https://cyberark-customers.force.com/mplace/s/#a35Ht000000rjXlIAI-a39Ht000001kceVIAQ
###########################



# Set the paths to the driver executables and the script to run
$chromeDriverPath = "C:\Path\To\chromedriver.exe" # Default is C:\Program Files (x86)\CyberArk\PSM\Components\chromedriver.exe
$edgeDriverPath = "C:\Path\To\msedgedriver.exe" # Default is C:\Program Files (x86)\CyberArk\PSM\Components\msedgedriver.exe
$appLockerScriptPath = "C:\Path\To\PSMConfigureAppLocker.ps1" # Default is C:\Program Files (x86)\CyberArk\PSM\Hardening\PSMConfigureAppLocker.ps1


# Set the path for the log file with date and time
$dateTimeFormat = $currentDateTime.ToString("MMddyyyy_HHmm")
$logFileName = "WebDriverUpdaterTool" + $currentDateTime.ToString("MMddyyyy_HHmm") + "_driver_check.log"
$logFilePath = "C:\Path\To\CyberArk\PSM\Hardening\$logFileName" # Default to your Hardening folder - C:\Program Files (x86)\CyberArk\PSM\Hardening\


# Initialize the log message
$logMessage = ""

# Check if ChromeDriver file exists
if (Test-Path -Path $chromeDriverPath -PathType Leaf) {
    # Get the creation date and time of the ChromeDriver executable
    $chromeDriverCreationTime = (Get-Item $chromeDriverPath).CreationTime
}
else {
    $chromeDriverCreationTime = $null
    $logMessage += "$(Get-Date) - ChromeDriver file not found. `r`n"
}

# Check if EdgeDriver file exists
if (Test-Path -Path $edgeDriverPath -PathType Leaf) {
    # Get the creation date and time of the EdgeDriver executable
    $edgeDriverCreationTime = (Get-Item $edgeDriverPath).CreationTime
}
else {
    $edgeDriverCreationTime = $null
    $logMessage += "$(Get-Date) - EdgeDriver file not found. `r`n"
}

# Get the current date and time
$currentDateTime = Get-Date

# Initialize the runScript flag
$runScript = $false

# Check if either driver was created in the last 30 minutes
if ($chromeDriverCreationTime -ne $null -and $edgeDriverCreationTime -ne $null) {
    $chromeDriverTimeDifference = ($currentDateTime - $chromeDriverCreationTime).TotalMinutes
    $edgeDriverTimeDifference = ($currentDateTime - $edgeDriverCreationTime).TotalMinutes
    
    if ($chromeDriverTimeDifference -lt 30 -or $edgeDriverTimeDifference -lt 30) {
        $runScript = $true
        $logMessage += "$(Get-Date) - Driver change detected. AppLocker script will be executed.`r`n"
    }
    else {
        $logMessage += "$(Get-Date) - No driver changes detected. AppLocker script will not be executed.`r`n"
    }
}
else {
    $logMessage += "$(Get-Date) - One or both driver files not found. AppLocker script will not be executed.`r`n"
}

# Run the script if the flag is set
if ($runScript) {
    & $appLockerScriptPath
}

# Set the path for the log file with date and time
#$dateTimeFormat = $currentDateTime.ToString("MMddyyyy_HHmm")
#$logFileName = "WebDriverUpdaterTool" + $currentDateTime.ToString("MMddyyyy_HHmm") + "_driver_check.log"
#$logFilePath = "C:\Path\To\CyberArk\PSM\Hardening\$logFileName" # Default to your Hardening folder - C:\Program Files (x86)\CyberArk\PSM\Hardening\


# Log the event to the log file
$logMessage | Out-File -Append -FilePath $logFilePath
