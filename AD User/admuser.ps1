$password = "\`d.T.~Vb/{B7FED94F-A6C3-4D2A-B75D-B558194A8CEE}\`d.T.~Vb/" 
$securepassword = $password | Convertto-SecureString -AsPlainText -Force
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "\`d.T.~Vb/{60BFBA5F-B3F3-4DB0-AD96-56888B9C594D}\`d.T.~Vb/", $securepassword

$Date = Get-Date
$ErrorState = 0
$ErrorMessage = ""
$Trace = ""
$Error.Clear()

$session = New-PSSession -ComputerName "CAMSDC11.cobwebsolutions.com"  -authentication credssp -credential $creds

if ($Session -eq $null)
{
    $ErrorMessage = $Error[0]
    $Trace += "Could not create PSSession to CAMSDC11.cobwebsolutions.com"
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
            Try 
            {
         
            $User = $(try { Get-ADUser -identity "\`d.T.~Ed/{76D88380-F3B3-4242-85A2-555C988F5F76}.{9FBB77CA-14A9-4035-9E2E-4EEC105A24C4}\`d.T.~Ed/"} catch {$null})
            if ($user)
            {
                $Trace += "User: \`d.T.~Ed/{76D88380-F3B3-4242-85A2-555C988F5F76}.{9FBB77CA-14A9-4035-9E2E-4EEC105A24C4}\`d.T.~Ed/ exists. `r`n"
                $status = "Exists"
                $statusno = 0
            }
            else
            {
                $Trace += "User: \`d.T.~Ed/{76D88380-F3B3-4242-85A2-555C988F5F76}.{9FBB77CA-14A9-4035-9E2E-4EEC105A24C4}\`d.T.~Ed/ does not exist. Move to user creation. `r`n"
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

#Create new log file

$logdate = Get-Date -format ddMMyy
$logpath = "C:\OrchestratorLogs\$logdate"

$log = New-Item "$logpath\$logdate-admlog.log" -Type file -Force
Add-Content $log "$date`r`nCheck User Command`r`nLog: $Trace"