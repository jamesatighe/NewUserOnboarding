$password = "{password}" 
$securepassword = $password | Convertto-SecureString -AsPlainText -Force
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "{user}", $securepassword

$date = Get-Date
$ErrorState = 0
$ErrorMessage = ""
$ErrorTrace = ""
$Error.Clear()

$session = New-PSSession -ComputerName "CAMSDC11.cobwebsolutions.com"  -authentication credssp -credential $creds

if ($Session -eq $null)
{
    $ErrorMessage = $Error[0]
    $ErrorTrace += "Could not create PSSession to CAMSDC11.cobwebsolutions.com"
    $ErrorState = 2
}

else
{
    
    $ReturnArray = Invoke-Command -Session $session -ScriptBlock {
    
    try 
    {

        $ErrorTrace += "Adding Group memberships to user: {first name}.{last name}.`r`n"
        $User = "{first name}.{last name}"
        $Team = "{team}"

        switch  ($Team)
        {
            "Team 1" 
            { 
                $grouplist = "{Group DNs}"
           
                $Groups = $Grouplist.Split(";")
                Foreach ($Group in $Groups)
                {
                    $cmd = Add-ADGroupMember -identity $Group -Members $user
                } 
            }
            "Team 2" 
            { 
                $GroupList = "{Group DNs}"
            
                $Groups = $GroupList.Split(";")
                Foreach ($Group in $Groups)
                {
                    $cmd = Add-ADGroupMember -identity $Group -Members $user
                }
            }
        }
        
        $ErrorState = 0
        $ErrorTrace += "User created and enabled. `r`n"
        $ErrorTrace += "Group memberships assigned. `r`n"
        $ErrorTrace += "Completed remote action '$Action'. . .  `r`n"
    }   
    Catch
    {
        $ErrorTrace += " Group membership assignment failed. `r`n"
        $ErrorTrace += "Please check user.`r`n"
        $ErrorTrace += "Completed remote action '$Action'. . .  `r`n"
        $ErrorState = 2
        $ErrorMessage =$Error[0].Exception.ToString()
    }
    Finally
    {
        $ErrorTrace += "Exiting remote action '$Action'. `r`n"
        $ErrorTrace += "ErrorState:      $ErrorState.`r`n"
        $ErrorTrace += "ErrorMessage:    $ErrorMessage. `r`n"
    }
    
    $results = @($ErrorState,$ErrorMessage,$ErrorTrace)
    Return $results
    }
    
    $ErrorState = $ReturnArray[0]
    $ErrorMessage = $ReturnArray[1]
    $ErrorTrace = $ReturnArray[2]
}

$logdate = Get-Date -format ddMMyy
$logpath = "C:\OrchestratorLogs\$logdate"
if (!(Test-Path ("$logpath\$logdate-aduser.log")))
{
New-Item "$logpath\$logdate-aduser.log" -Type file -Force
}
else 
{
$log = "$logpath\$logdate-aduser.log"
Add-Content $log "$date`r`nAssign Group Membership Command`r`nLog: $ErrorTrace"
}