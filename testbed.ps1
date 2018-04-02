$temp_low_no = 4
$temp_low_meh = 8

$temp_sweetspot = 18
$temp_sweetspot_range = 2

$temp_high_meh = 25
$temp_high_no = 30

$verbose = "yes"
$working_temp = 12
$weightfactor = 5


if ($verbose = "yes") {write-host "x"}


if ($working_temp -gt $temp_high_no -or $working_temp -lt $temp_low_no) {
    if ($verbose = "yes") {write-host "Failed because temp $working°C temp is outside of $temp_low_no°C to $temp_high_no°C"}
    write-host "CODE FOR 0 Points"
}



if ($working_temp -gt ($temp_sweetspot - $temp_sweetspot_range) -and $working_temp -lt ($temp_sweetspot + $temp_sweetspot_range) ) {
    if ($verbose -eq "yes") {write-host "GREAT SUCCESS (temp was $working_temp°C) within $temp_sweetspot_range ° of Sweetspot($temp_sweetspot°C)"}
    write-host "CODE FOR 100 POINTS"
}

$lowrange = ($temp_sweetspot - $temp_sweetspot_range) - $temp_low_meh
$highrange = $temp_high_meh - ($temp_sweetspot + $temp_sweetspot_range)

$x20 = $lowrange * 0.05
$x20 = 20
$x = 0
$y = 0

$weightfactor = 6.666

#while ($x20 -lt $lowrange) {
    #$x20
    foreach ($x in $x..20) {
    $y = ($x + (($x / $weightfactor)) * $x)
    #$y = $y / 15
    write-host "$x and $y"
    $x++
    $x20 = $x20 + ($lowrange * 0.05)
}




while ($x20 -lt $lowrange) {
    foreach ($x in $x..20) {
        $y = ($x + (($x / $weightfactor)) * $x)

        #$y = $y / 15
        write-host "$x and $y"
        $x++
    }
    $x20 = $x20 + $x20
}


