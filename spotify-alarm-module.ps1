


# This is the code to run once we have the oauth token (bearer)
$URI = "https://api.spotify.com/v1/me/player/play"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", 'Bearer BQBPkq-1QpcsH-wf1awm_MYmeWaHeNu2bg6VnczVD3twbXl74vCytEEuvCX_WVb98jf9_bIFHySJFDQr56m6xlkenHRyzO_qpmXFd_NbJiqdMTdTLWfylv79eKaRBUcWp7spT_sikKJJAw1hPclEKGZFKWY')
$headers.Add("Accept", 'application/json')
$headers.Add("Content-Type", 'application/json')
$body = '{"context_uri":"spotify:user:stefegadepanda:playlist:58l5YNL4YETQDvqmYfHasz","offset":{"position":0}}'

try {
    $response = Invoke-RestMethod $URI -Headers $headers -body $body -method PUT
}
catch {
    $ErrorMessage = $_.Exception.Message
    $HTTP_Status = [regex]::matches($_.exception.message, "(?<=\()[\d]{3}").Value
    Write-Host ("ERROR $HTTP_Status ($ErrorMessage)")
    #Send-MailMessage -From powershell-bot@virginmedia.com -To stefan.harrington-palmer@virginmedia.com -Subject "Test Powershell mail" -SmtpServer smtp.virginmedia.com -Body "We failed to read file $FailedItem. The error message was $ErrorMessage" -UseSsl -Credential
    break
}