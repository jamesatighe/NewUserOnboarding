$password = "{Password}" 
$securepassword = $password | Convertto-SecureString -AsPlainText -Force
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "{cred username}", $securepassword

$Date = Get-Date
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
        Try 
        {
            $Action = "Check AD User";
            
            Import-Module ActiveDirectory    
            $Trace += "Importing the ActiveDirectory Module. . . `r`n"
            
            $User = Get-ADUser -identity "{firstname.lastname}"
            if ($user)
            {
                $Trace += "User: {firstname.lastname} already exists. `r`n"
                $status = "Exists"
                $statusno = 0
            }
            else
            {
                $Trace += "User: {firstname.lastname} does not exist. Move to user creation. `r`n"
                $status = "Does not Exist"
                $statusno = 1
            }
        $ErrorState = 0
        $Trace += "Completed remote action '$Action'. . . `r`n"
        }
        Catch
        {
            $Trace += "Exception caught in remote action '$Action' . . . `r`n"
            $Errorstate = 2
            $ErrorMessage = $Error[0].Exception.ToString()
        }
        Finally
        {
            $Trace += "Exiting remote action '$Action'. . . `r`n"
            $Trace += "ErrorState:     $ErrorState `r`n"
            $Trace += "ErrorMessage:   $ErrorMessage `r`n"
        }
        
        
        $results = @($ErrorState,$ErrorMessage,$Trace,$Status,$StatusNo)
        Return $Results
    }
$Errorstate = $ReturnArray[0]
$ErrorMessage = $ReturnArray[1]
$Trace = $ReturnArray[2]
$TaskStatus = $ReturnArray[3]
$TaskStatusNo = $ReturnArray[4]

#$taskstatus = $results.status
#$taskstatusno = $results.statusno
Remove-PSSession -Session $session
}
#Create Log Entry
Add-Content {log path} "$date`r`nCheck User Command`r`nLog: $Trace"