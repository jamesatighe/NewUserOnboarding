$password = "{password}"
$securepassword = $password | Convertto-SecureString -AsPlainText -Force

$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "{cred username}", $securepassword

$Date = Get-Date
$ErrorState = 0
$ErrorMessage = ""
$Trace = ""
$Error.Clear()

$session = New-PSSession -ComputerName "{COMPUTER NAME}" -Credential $credentials -Auth CredSSP

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
        $Action = "Enable Mailbox";
        
        Add-PSSnapIn Microsoft.Exchange.Management.Powershell.SnapIn;
        $Trace += "Importing Exchange Powershell SnapIn. `r`n"

        $user = Get-user -identity "{user name}"
        Enable-Mailbox -identity $user
        
        $ErrorState = 0
        $Trace += "Mailbox: {user name} enabled. Moving to move request. `r`n"
        $Trace += "Completed remote action '$Action'. . . `r`n"
     }
     Catch
     {
         $Trace += "Mailbox: {user name} failed to enable. `r`n"
         $Trace += "Completed remote action '$Action'. . . `r`n"
         $ErrorState = 2
         $ErrorMessage = $Error[0].Exception.ToString()
     }
     Finally
     {
         $Trace += "Exiting remote action '$Action'. `r`n"
         $Trace += "ErrorState:     $ErrorState. `r`n"
         $Trace += "ErrorMessage:   $ErrorMessage. `r`n"
     }
     
     $results = @($ErrorState,$ErrorMessage,$Trace,$Status,$StatusNo)
     Return $results
    }
    
    $ErrorState = $ReturnArray[0]
    $ErrorMessage = $ReturnArray[1]
    $Trace = $ReturnArray[2]
}
#Create Log Entry
Add-Content {log path} "$date`r`nEnable Mailbox Command`r`nLog: $trace"