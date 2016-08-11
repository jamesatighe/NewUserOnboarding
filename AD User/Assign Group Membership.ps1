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
        $Office = "{office}"

        switch  ($Team)
        {
            #Example of multiple group addition
            "Team 1" 
            { 
                $grouplist = "{Group DNs}"
           
                $Groups = $Grouplist.Split(";")
                Foreach ($Group in $Groups)
                {
                    $cmd = Add-ADGroupMember -identity $Group -Members $user
                } 
            }
            #Example of single department group
            "Team 2" 
            { 
                $Group = "CN=Sales,OU=Organizational Unit,DC=cobwebsolutons,DC=com"
                $cmd = Add-ADGroupMember -identity $Group -Members $user
            }
        }
        
        $ErrorState = 0
        $ErrorTrace += "User created and enabled. `r`n"
        $ErrorTrace += "Group memberships assigned. `r`n"
        $ErrorTrace += "Completed remote action '$Action'. . .  `r`n"
    }  

    #Check if Office is Fareham or London
    if ($office -eq "Fareham")
    {
        
        $cmd = Add-ADGroupMember -identity "CN=Fareham Office,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com" -Members $user
        $cmd = Add-ADGroupMember -identity "CN=DIS_U_South Wing,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com" -Members $user
    } 
    if ($office -eq "London")
    {
        $cmd = Add-ADGroupMember -identity "CN=London Office,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com" -Members $user
        $cmd = Add-ADGroupMember -identity "CN=SG_G_London Users,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com" -Members $user
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


        switch  ($Team)
        {
            "CIA" 
            { 
                $grouplist = "CN=SG_G_VPN_users,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN='Support Mailbox' and 'Hosted Services Support' Send As Security,OU=Support,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=DIS_U_CIA,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_CIA,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SCOM Administrators,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=Global Relay Static,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com"
                $Groups = $Grouplist.Split(";")
                Foreach ($Group in $Groups)
                {
                    $cmd = Add-ADGroupMember -identity $Group -Members $user
                } 
            }
            "MAC" 
            { 
                $GroupList = "CN=SG_G_VPN_users,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN='Support Mailbox' and 'Hosted Services Support' Send As Security,OU=Support,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,C=com;CN=MigrationsGroup,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=Proxy Restrictions Laptop,OU=Group Policy Access Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_Exchange Admin Team,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_MigrationsAdmins,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=DIS_U_Exchange Admin Team,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=DIS_U_Exchange Reports,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_MigrationsRoot,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=BES Service Upgrades,CN=Users,DC=cobwebsolutions,DC=com;CN=DIS_U_E14TAP,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=Global Relay Static,OU=Distribution Lists,OU=CobwebSolutions Ltd,DC=cobwebsolutions,DC=com"
            
                $Groups = $GroupList.Split(";")
                Foreach ($Group in $Groups)
                {
                    $cmd = Add-ADGroupMember -identity $Group -Members $user
                }
            }
            "NOC" 
            { 
                $GroupList ="CN=SG_G_VPN_users,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN='Support Mailbox' and 'Hosted Services Support' Send As Security,OU=Support,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_NOC Machine RDP Access,OU=Group Policy Access Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_NOC,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=DIS_U_NOC Team,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_NOCService Agents,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_NOCMon,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_MigrationsRoot,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=Global Relay Static,U=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com"
            
                $Groups = $GroupList.Split(";")
                Foreach ($Group in $Groups)
                {
                    $cmd = Add-ADGroupMember -identity $Group -Members $user
                }    
            }
            "Networking" 
            { 
                $GroupList ="CN=Isa_VPN_Users,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_VPN_users,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=DIS_U_Network Admin Team,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=DIS_U_Peering,U=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=DIS_U_ISA_Alerts,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_Network Admin Team,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com CN=Change Managers,OU=Distribution Lists,U=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=DIS_U_tfl,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_NOCMon,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_Bomgartechnical,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=Global Relay Static,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com"
            
                $Groups = $GroupList.Split(";")
                Foreach ($Group in $Groups)
                {
                    $cmd = Add-ADGroupMember -identity $Group -Members $user
                } 
            }
            "Incident Support" 
            { 
                $GroupList = "CN='Support Mailbox' and 'Hosted Services Support' Send As Security,OU=Support,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_Incident Support,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_NOC Machine RDP Access,OU=Group Policy Access Groups,OU=CobwebSolutions Ltd,DC=cobwebsolutions,DC=com;CN=Incident Support Team,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_BomgarTST_L1,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=Global Relay Static,OU=Distribution Lists,OU=CobwebSolutions Ltd,DC=cobwebsolutions,DC=com"
            
                $Groups = $GroupList.Split(";")
                Foreach ($Group in $Groups)
                {
                    $cmd = Add-ADGroupMember -identity $Group -Members $user
                } 
            }
            "Service Support" 
            { 
                $GroupList = "CN='Support Mailbox' and 'Hosted Services Support' Send As Security,OU=Support,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_Incident Support,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_NOC Machine RDP Access,OU=Group Policy Access Groups,OU=CobwebSolutions Ltd,DC=cobwebsolutions,DC=com;CN=Incident Support Team,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_BomgarTST_L1,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=Global Relay Static,OU=Distribution Lists,OU=CobwebSolutionsLtd,DC=cobwebsolutions,DC=com"
            
                $Groups = $GroupList.Split(";")
                Foreach ($Group in $Groups)
                {
                    $cmd = Add-ADGroupMember -identity $Group -Members $user
                }
            }
            "Office 365 Support" 
            { 
                $GroupList ="CN=SG_G_VPN_users,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN='Support Mailbox' and 'Hosted Services Support' Send As Security,OU=Support,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_Incident Support,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_Techintranet Access,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_RFC Access,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=Incident Support Team,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_MigrationsAdmins,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_Billing Members,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_Service Support,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=DIS_U_Service Desk Team,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_MigrationsRoot,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=BES Service Upgrades,CN=Users,DC=cobwebsolutions,DC=com;CN=SG_G_BomgarTST_L1,U=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=Rescheduling Required,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=Office 365 Support Team,OU=Office 365 Support,OU=Customer Services Team,OU=Users,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=Global Relay Static,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=Cloud_365 Team,OU=Cloud Groups,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_365 Team,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com"
            
                $Groups = $GroupList.Split(";")
                Foreach ($Group in $Groups)
                {
                    $cmd = Add-ADGroupMember -identity $Group -Members $user
                } 
            }
            "Sales"
            {
                $GroupList = "CN=SG_G_Sales Team,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=Domain Users,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=DIS_U_Sales Team,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN='Support Mailbox'and 'Hosted Services Support' Send As Security,OU=Support,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_Billing Members,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_VCenter Read Only,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_Cobweb All Staff,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=Global Relay Static,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=Vuzion Exclaimer & Disclaimer Policy (Office 365),OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=Vuzion Exclaimer Policy (Office 365),OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=Internal_Only_Vuzion_General_Staff,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=External_Only_Vuzion_General_Staff,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=Vuzion Internal,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_Vuzion,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com"
          
                $Groups = $GroupList.Split(";")
                Foreach ($Group in $Groups)
                {
                    $cmd = Add-ADGroupMember -identity $Group -Members $user
                } 
            }

          "Marketing"
          {
              $GroupList = "CN=Domain Users,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_USB_Write_Access,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=DIS_U_South Wing,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=SG_G_Marketing Team,OU=Security Groups,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=DIS_U_Marketing Team,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=Global Relay Static,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com;CN=Fareham Office,OU=Distribution Lists,OU=Cobweb Solutions Ltd,DC=cobwebsolutions,DC=com"

             $Groups = $GroupList.Split(";")
            Foreach ($Group in $Groups)
            {
                $cmd = Add-ADGroupMember -identity $Group -Members $user
            }

        }
    }