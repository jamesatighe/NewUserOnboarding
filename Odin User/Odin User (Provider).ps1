$password = "{password}"
$securepassword = $password | ConvertTo-SecureString -AsPlainText -Force
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "{cred username}", $securepassword

$session = New-PSSession -Computername localhost -Auth CredSSP -Credential $creds

$ErrorMessage = ""
$ErrorState = ""
$Error.clear()
$ErrorTrace = ""

$ReturnArray = Invoke-Command -Session $session -Scriptblock {


Try 
{
    $Action = "Create Odin BA/OA User (Provider)"
    $password = "{Odin password}"
    $securepassword = $password | ConvertTo-SecureString -AsPlainText -Force
    $odincreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "{Odin username}", $securepassword



    $BAXML = Get-Content C:\OdinXML\OdinBAAdmintemp.xml

    #Replace fields with relevant info

    $BAXML = $BAXML -replace "{username}", "{user name}"
    $BAXML = $BAXML -replace "{password}", "{user password}"
    $BAXML = $BAXML -replace "{Firstname}", "{firstname}"
    $BAXML = $BAXML -replace "{Lastname}", "{lastname}"
    $BAXML = $BAXML -replace "{email}", "{email}"



    $cmdresults = Invoke-WebRequest -Uri http://{BA IP}:5224 -Credential $odincreds -Method POST -Body $BAXML
    $content = $cmdresults.content
    $ErrorTrace += "$content`r`n"
    if ($content -match "fault")
    {
        $ErrorTrace += "Error with the Odin task. . . `r`n"
        $ErrorTrace += "$content`r`n"
        $ErrorState = 2
    }
    else 
    {
        $ErrorTrace += "Odin BA/OA Account created.`r`n"
        
        $userID = $content.Substring($content.IndexOf("<i4")+4,($content.IndexOf("</i4>")) - $content.IndexOf("<i4")-4)

        $OAXML = Get-Content C:\OdinXML\OdinOARoletemp.xml

        $OAXML = $OAXML -replace "{memberid}", "$userID"

        Start-Sleep -Seconds 60

        $cmdresults = Invoke-WebRequest -Uri http://{OAIP}:8440/RPC2 -Credential $odincreds -Method POST -Body $OAXML

        $content = $cmdresults.content
        if ($content -match "<i4>0</i4>")
        {
            $ErrorTrace += "Account Administrator Role added to OA User.`r`n"
            $ErrorTrace += "Completed remote action '$Action'. . .`r`n"
            $ErrorState = 0
        }
        else 
        {
            $ErrorTrace += "Account Administrator Role not added due to error. . . `r`n"
            $ErrorTrace += "$content`r`n"
            $ErrorState = 2
        }
    }
}
catch 
{
    $ErrorMessage = $Error[0].Exception.ToString()
    $ErrorState = 2
    $ErrorTrace += "Exception caught in remote action '$Action'. . . `r`n"
}

$results = @($ErrorMessage, $ErrorState, $ErrorTrace)
Return $results

}

$ErrorMessage = $ReturnArray[0]
$ErrorState = $ReturnArray[1]
$ErrorTrace = $ReturnArray[2]
Remove-PSSession -Session $session

#Create Log Entry
Add-Content {log path} "$date`r`nOdin User Addition (Provider)`r`nLog: $ErrorTrace"