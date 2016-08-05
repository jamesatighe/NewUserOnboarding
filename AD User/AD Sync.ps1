$password = "{password}" 
$securepassword = $password | Convertto-SecureString -AsPlainText -Force
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "{user}", $securepassword

$date = Get-Date
$ErrorState = 0
$ErrorMessage = ""
$Trace = ""
$Error.Clear()

$session = New-PSSession -ComputerName "{remote server}"  -authentication credssp -credential $creds

if ($Session -eq $null)
{
    $ErrorMessage = $Error[0]
    $Trace += "Could not create PSSession to {remote server}"
    $ErrorState = 2
}
else
{
    $returnarray = Invoke-command -Session $Session -Scriptblock {

        try 
        {
            $cmd = repadmin /syncall /e /P /A
            $ErrorState = 0
            $ErrorTrace += "AD Sync from CAMS to Segensworth complete.`r`n"
        }
        catch 
        {
            $ErrorState = 2
            $ErrorTrace += "Failed to run AD Sync.`r`n"
            $ErrorMessage = $Error[0].Exception.ToString()
        }

        $results = @($ErrorMessage,$ErrorState,$ErrorTrace) 
       Return $results
   }   
}

$ErrorMessage = $ReturnArray[0]
$ErrorState = $ReturnArray[1]
$ErrorTrace = $ReturnArray[2]

$logdate = Get-Date -format ddMMyy
$logpath = "C:\OrchestratorLogs\$logdate"
if (!(Test-Path ("$logpath\$logdate-aduser.log")))
{
New-Item "$logpath\$logdate-aduser.log" -Type file -Force
}
Else
{
$log = "$logpath\$logdate-aduser.log"
Add-Content $log "$date`r`nForce AD Sync`r`nLog: $ErrorTrace"
}