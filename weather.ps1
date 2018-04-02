#######################
#######################
#######################

# Don't change options in this file, instead edit the .ini file
Get-Content ".\weather.ini" | foreach-object -begin {$h = @{}} -process { $k = [regex]::split($_, '='); if (($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }

# Set variables pulled in from .ini file
#x# Maybe this can be pulled in with a loop in future? seems a lot of code.
$api_key = $h.Get_Item("api_key")
$verbose = $h.Get_Item("verbose")
$temp_low_sketchy = $h.Get_Item("temp_low_sketchy")
$temp_low_good = $h.Get_Item("temp_low_good")
$temp_sweetspot = $h.Get_Item("temp_sweetspot")
$temp_sweetspot_range = $h.Get_Item("temp_sweetspot_range")
$temp_high_good = $h.Get_Item("temp_high_good")
$temp_high_sketchy = $h.Get_Item("temp_high_sketchy")
$windspeed_sketchy = $h.Get_Item("windspeed_sketchy")
$windspeed_bad = $h.Get_Item("windspeed_bad")
$rain_sketchy = $h.Get_Item("rain_sketchy")
$rain_bad = $h.Get_Item("rain_bad")

#x# Put something in here to chose the json id for time slot. 0 = nowest, 1=+3 hrs, 2=+6hrs, etc

#x# Need to find somewhere tidier to put this.
$locations = @(
    [PSCustomObject]@{Location = "Start" ; CityID = "2657356"; Name = "Amersham"}
    [PSCustomObject]@{Location = "Mid1" ; CityID = "2639381"; Name = "Rickmansworth"}
    [PSCustomObject]@{Location = "Mid2" ; CityID = "2651378"; Name = "Denham"}
    #[PSCustomObject]@{Location = "Mid3" ; CityID = "3333154"; Name = "Hillingdon"}
    [PSCustomObject]@{Location = "Finish" ; CityID = "2647262"; Name = "Hayes"}
)

#x# these are only feel because I keep re-running in the same session
$good = 0
$sketchy = 0
$bad = 0

#Fault Checking. 
# Are the cities correct?
# Did we get results? (one missing, retry, !then sketchy++;)
# all cod value shows 200
#

###### MainLoop ######
$locations | ForEach-Object {
    $CityID = $_.CityID
    $CityName = $_.Name
    $Location = $_.Location

    $y = (Invoke-RestMethod -Uri ("http://api.openweathermap.org/data/2.5/forecast?id=" + $CityID + "&APPID=" + $api_key + "&units=metric")).list[0]

    #temperature is in degrees C
    $working_temp = ($y).main.temp_min
    #wind is in metres per second.
    $windspeed = ($y).wind.speed
    #$winddirection=($y).wind.deg
    #rain volume is in mm per last 3 hours
    $rain_3hrs = ($y).rain."3h"
    if (!$rain_3hrs) { $rain_3hrs = "0" } 
    if ($error_reason) { clear-variable -Name "error_reason" }

    if ($working_temp -gt "$temp_low_good" -AND $working_temp -lt "$temp_high_good") {
        "TEMP: $Location is good ($working_temp °C)"
     #   $goodness_temp
        $good++
    }
    elseif ($working_temp -gt "$temp_low_sketchy" -AND $working_temp -lt "$temp_high_sketchy") {
        "TEMP: $Location Is sketchy ($working_temp °C)"
        $sketchy++
    }
    else {
        "TEMP: $Location Is bad ($working_temp °C)"
        $error_reason = "TEMP: Failed because of Low Temperature $working_temp at $Location ($CityName)"
        $bad++
    }




    if ($windspeed -lt "$windspeed_sketchy") {
        "WIND: $Location is good ($windspeed M/s)"
        $good++
    }
    elseif ($windspeed -gt "$temp_low_sketchy" -AND $windspeed -lt "$windspeed_bad") {
        "WIND: $Location Is sketchy ($windspeed M/s)"
        $sketchy++
    }
    else {
        "WIND: $Location Is bad ($windspeed M/s)"
        $error_reason = "WIND: Failed because Windspeed over $windspeed M/s at $Location ($CityName)"
        $bad++
    }


    if ($rain_3hrs -lt "$rain_sketchy") {
        "RAIN: $Location is good ($rain_3hrs mm/3Hrs)"
        $good++
    }
    elseif ($rain_3hrs -lt "$rain_bad") {
        "RAIN: $Location Is sketchy ($rain_3hrs mm/3Hrs)"
        $sketchy++
    }
    else {
        "RAIN: $Location Is bad ($rain_3hrs M/s)"
        $error_reason = "RAIN: Failed because of rain $rain_3hrs mm/3Hrs $Location ($CityName)"
        $bad++
    }
    write-host ""

} #Foreach

# This section gives a final Y/N
$number_of_locations = (($locations | Measure-Object).Count) * 3
$bad = [math]::Round(($bad / $number_of_locations) * 100, 0)
$sketchy = [math]::Round(( $sketchy / $number_of_locations * 100), 0)
$good = [math]::Round(($good / $number_of_locations * 100), 0)
if ($verbose = 'yes') { write-host "$good% were good. $sketchy% were sketchy. $bad% were bad." }   
#if ($error_reason) { write-host "$error_reason is why we're failing this" }
if ($bad) {
    write-host "Failing because of Bad Weather"
    write-host "$error_reason"
    exit 1
} 

#Wind Logic
# <x eveywhere
# what direction am I headed?

#Rain Logic
# <x mm everywhere
# >x, <y, sketchy++;

#Overall Y/N
# - Sketchyness <2
