$password = "{password}" 
$securepassword = $password | Convertto-SecureString -AsPlainText -Force
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "{cred username}", $securepassword

$ErrorState = 0
$ErrorMessage = ""
$Trace = ""
$Error.Clear()

$session = New-PSSession -ComputerName "{COMPUTER NAME}"  -authentication credssp -credential $creds

if ($Session -eq $null)
{
    $ErrorMessage = $Error[0]
    $Trace += "Could not create PSSession to {COMPUTER NAME}"
    $ErrorState = 2
}

else
{
    
    $ReturnArray = Invoke-Command -Session $session -ScriptBlock {
    
    try 
    {

        $Action = "Assign Group Membership"
        $User = "{firstname.lastname}"
        $Team = "{team}"

        switch  ($team)
        {
            "{Team 1}" 
            { 
                $grouplist = "{Group List}"
                $Groups = $Grouplist.Split(";")
                Foreach ($Group in $Groups)
                {
                    Add-ADGroupMember -identity $Group -Members $user
                } 
            }
            "{Team 2}" 
            { 
                $GroupList = "{Group List 2}"
            
                $Groups = $GroupList.Split(";")
                Foreach ($Group in $Groups)
                {
                    Add-ADGroupMember -identity $Group -Members $user
                }
            }
            
        }
        
        $ErrorState = 0
        $Trace += "User created and enabled. `r`n"
        $Trace += "Group memberships assigned. `r`n"
        $Trace += "Completed remote action '$Action'. . .  `r`n"
    }   
    Catch
    {
        $Trace += " Group membership assignment failed. `r`n"
        $Trace += "Completed remote action '$Action'. . .  `r`n"
        $ErrorState = 2
        $ErrorMessage =$Error[0].Exception.ToString()
    }
    Finally
    {
        $Trace += "Exiting remote action '$Action'. `r`n"
        $Trace += "ErrorState:      $ErrorState.`r`n"
        $Trace += "ErrorMessage:    $ErrorMessage. `r`n"
    }
    
    $results = @($ErrorState,$ErrorMessage,$Trace)
    Return $results
    }
    
    $ErrorState = $ReturnArray[0]
    $ErrorMessage = $ReturnArray[1]
    $Trace = $ReturnArray[2]
}
#Create Log Entry
Add-Content {Log Path} "$date`r`nAssign Group Membership Command`r`nLog: $trace"