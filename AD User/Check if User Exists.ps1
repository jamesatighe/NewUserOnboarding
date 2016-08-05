$password = "{password}" 
    $securepassword = $password | Convertto-SecureString -AsPlainText -Force
    $creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "{user}", $securepassword

$Date = Get-Date
$ErrorState = 0
$ErrorMessage = ""
$Trace = ""
$Error.Clear()

$session = New-PSSession -ComputerName "{remote-server}"  -authentication credssp -credential $creds

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
            $Trace += "Checking user: {first name}.{last name}`r`n"          

            $User = $(Try { Get-ADUser -identity "{first name}.{last name}" } catch { $null })
            if ($user)
            {
                $Trace += "User: {first name}.{last name} already exists. `r`n"
                $status = "Exists"
                $statusno = 0
            }
            else
            {
                $Trace += "User: {first name}.{last name} does not exist. Move to user creation. `r`n"
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

#Create new log file

$logdate = Get-Date -format ddMMyy
$logpath = "C:\OrchestratorLogs\$logdate"
if (!(Test-Path ("$logpath\$logdate-aduser.log")))
{
New-Item "$logpath\$logdate-aduser.log" -Type file -Force
}
else
{
$log = "$logpath\$logdate-aduser.log"
Add-Content $log "$date`r`nAD Account required.`r`nLog: $Trace"
}


