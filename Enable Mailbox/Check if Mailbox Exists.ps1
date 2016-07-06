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
            $Action = "Check Exchange User";    
            
            Add-PSSnapIn Microsoft.Exchange.Management.Powershell.SnapIn;
            $Trace += "Importing Exchange Powershell SnapIn. `r`n"
            
            $User = Get-user -identity "{user name}"
            $status = ""
            $statusno = 0
            if ($user)
            {
                if ($user.RecipientType -eq "UserMailbox")
                {
                    $Trace += "Mailbox: {user name} is already created. Moving to move request. `r`n"
                    $status = "Mailbox is already created - Skipping to move request"
                    $statusno = 1
                }
                elseif ($user.RecipientType -eq "MailUser")
                {
                    $Trace += "Mailbox: {user name} has already been created and moved. Move to Office 365 Licence assignment. `r`n"                    
                    $status = "Mailbox has been created and moved - Skipping to O365 License assignment"
                    $statusno = 2
                } 
                else
                {
                    $Trace += "Mailbox: {user name} does not exist. Move to Enable Mailbox. `r`n"
                    $status = "None"
                    $statusno = 3
                }
            }
            else 
            {
                $Trace += "Mailbox: {user name} Active Directory User does not exist. `r`n"
                $status = "No User"
                $statusno= 4 
            }
        }
        Catch
        {
            $Trace += "Completed remote action '$Action'. . . `r`n"
            $ErrorState = 2
            $ErrorMessage = $Error[0].Exception.ToString()
        }
        Finally
        {
            $Trace += "Exiting remote action '$Action'. `r`n"
            $Trace += "ErrorState:      $ErrorState. `r`n"
            $Trace += "ErrorMessage:    $ErrorMessage. `r`n"
        }
        
        $results = @($ErrorState,$ErrorMessage,$Trace,$Status,$StatusNo)
        Return $results
    }
    $ErrorState = $ReturnArray[0]
    $ErrorMessage = $ReturnArray[1]
    $Trace = $ReturnArray[2]
    $TaskStatus = $ReturnArray[3]
    $taskstatusno = $ReturnArray[4]
    Remove-PSSession -Session $session
}
#Create Log Entry
Add-Content {log path} "$date`r`nCheck Mailbox Command`r`nLog: $Trace"