$password = "{password}" 
$securepassword = $password | Convertto-SecureString -AsPlainText -Force
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "{user}", $securepassword

$Date = Get-Date
$ErrorState = 0
$ErrorMessage = ""
$Trace = ""
$Error.Clear()

$session = New-PSSession -ComputerName localhost  -authentication credssp -credential $creds

if ($Session -eq $null)
{
    $ErrorMessage = $Error[0]
    $Trace += "Could not create PSSession to CAMSSCORCH01"
    $ErrorState = 2
}
else 
{
    

    $ReturnArray = Invoke-command -session $session -ScriptBlock {
    $password = "{remote password}" 
    $securepassword = $password | Convertto-SecureString -AsPlainText -Force
    $credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "{remote user}", $securepassword
    
    try
    {
        $Action = "Assign Office 365 Licences"
    
        try
        {
            Import-Module MSOnline
            $Trace += "Microsoft Online Module Imported. . .`r`n"
        }
        catch
        {
            $Trace += "Exception caught in remote action '$Action'. . . `r`n"
            $ErrorState = 2
            $ErrorMessage = $Error[0].Exception.ToString()
        }        
    
        Connect-MSOLService -Credential $credentials
   
        $User = Get-MSOLUser -UserPrincipalName "{UPN}"
        $Trace += "Adding Office 365 Licences to user: {UPN}.`r`n"
        $Customlicence = New-MSOLLicenseOptions -AccountSkuId "tennant:PROJECTONLINE_PLAN_1" -DisabledPlans "SHAREPOINTENTERPRISE"
        
        $CRM =  "{CRM}"
        $Project = "{Project}"
        $SkypeVoice = "{SkypeVoice}"

        if ($user)
        {
            Set-MSOLUser -UserPrincipalName  "{UPN}" -UsageLocation GB
            $Trace += "User: {UPN}. `r`n"
            $Trace += "Setting User Location to GB.`r`n"
            #Set-MSOLUserLicense -UserPrincipalName  "\`d.T.~Ed/{862F6482-1617-4374-BC82-E8DC0ED39FED}.{3EDA4806-D3B5-41C9-BB85-53AF51E9E55D}\`d.T.~Ed/" -AddLicenses $licence
            $user | Set-MSOLUserLicense -AddLicenses tennant:ENTERPRISEPREMIUM
            $Trace += "Adding Enterprise Premium (E5) Licence to user.`r`n"
            
            if ($Project -eq "Yes" -and $CRM -eq "Yes")
            {
                $user | Set-MSOLUserLicense -AddLicenses tennant:PROJECTONLINE_PLAN_1 -LicenseOptions $CustomLicence
                $user | Set-MSOLUserLicense -AddLicenses tennant:PROJECTCLIENT
                $user | Set-MSOLUserLicense -AddLicenses tennant:CRMIUR
                $Trace += "Adding CRM Internal Use Licence to user.`r`n"  
                $Trace += "Adding Project Online and Project Client Licence to user.`r`n"  
                 
            } elseif ($Project -eq "Yes" -and $CRM -eq "No")
            {
                $user | Set-MSOLUserLicense -AddLicenses tennant:PROJECTONLINE_PLAN_1 -LicenseOptions $CustomLicence
                $user | Set-MSOLUserLicense -AddLicenses tennant:PROJECTCLIENT
                $Trace += "Adding Project Online and Project Client Licence to user.`r`n"
            } elseif ($CRM -eq "Yes" -and $Project -eq "No")
            {
                $user | Set-MSOLUserLicense -AddLicenses tennant:CRMIUR 
                $Trace += "Adding CRM Internal User Licence to user.`r`n"
            } 
            if ($SkypeVoice -eq "Yes")
            {
                $user | Set-MSOLUserLicense -AddLicenses tennant:MCOPSTN2
                $Trace += "Adding Skype for Business Voice Licence to user.`r`n"
            }
            $Status = "Licenses Assigned"
            $Statusno = 0
        }
        else
        {
            $Trace += "User : {UPN} not found"
            $Status = "No User"
            $Statusno = 1
        }
        $ErrorState = 0
        $Trace += "Completed remote action '$Action'. . .`r`n"
    }
    catch
    {
        $Trace += "Exception caught in remote action '$Action'. . .`r`n"
        $ErrorState = 2
    }
    Finally
    {
        $Trace += "Exiting remote action '$Action'. `r`n"
        $Trace += "ErrorState:      $ErrorState.`r`n"
        $Trace += "ErrorMessage:    $ErrorMessage.`r`n"
    }
    
    $results = @($ErrorState,$ErrorMessage,$Trace,$Status,$StatusNo)
    Return $results
    }
    $ErrorState = $ReturnArray[0]
    $ErrorMessage = $ReturnArray[1]
    $Trace = $ReturnArray[2]
    $TaskStatus = $ReturnArray[3]
    $TaskStatusno = $ReturnArray[4]

    Remove-PSSession -Session $session
}

$logdate = Get-Date -format ddMMyy
$logpath = "C:\OrchestratorLogs\$logdate"
if (!(Test-Path("$logpath\$logdate-O365.log")))
{
New-Item "$logpath\$logdate-O365.log" -Type file -Force
}
Else
{
$log = "$logpath\$logdate-O365.log"
Add-Content $log "$date`r`nAssign Office 365 Licence command`r`nLog: $Trace"
}