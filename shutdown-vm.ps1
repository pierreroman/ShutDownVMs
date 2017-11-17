workflow Shutdown-DR
{   
    $starttime = get-date
    $connectionName = "AzureRunAsConnection"
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName      
    "Logging in to Azure..."
    $account = Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 

    #Select Azure Subscription
    $subscriptionId = "<INSERT YOUR SUBSCRIPTION>"
    Select-AzureRmSubscription -SubscriptionID $subscriptionId

    #Identify Resource Group Target that include 'POC-DR' in the Resource Group name
    $ResourceGroups = Get-AzureRmResourceGroup | Where-Object {$_.ResourceGroupName -match "<INSERT TARGET RESOURCE GROUP>"}
        foreach ($RGs in $ResourceGroups)
        {
            $RGName=$RGs.ResourceGroupName.ToString()
            $vms= Get-AzureRmVM -ResourceGroupName $RGName
            foreach -parallel ($vm in ($vms | where{$_.ProvisioningState -match 'Succeeded'}))
            {
                $Name=$vm.Name.ToString()
                $StopOutPut = Stop-AzureRmVM -Name $Name -ResourceGroupName $RGName -Force
                Write-Output $StopOutPut
            }
        }
    $endtime = get-date
    $procestime = $endtime - $starttime
    $time = "{00:00:00}" -f $procestime.Minutes
    Write-Output " Deployment completed in '$time' "
}