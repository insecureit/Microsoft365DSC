function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter()]
        [System.String]
        $AdminDisplayName,

        [Parameter()]
        [System.String[]]
        $BccSuspiciousOutboundAdditionalRecipients = @(),

        [Parameter()]
        [Boolean]
        $BccSuspiciousOutboundMail = $true,

        [Parameter()]
        [System.String[]]
        $NotifyOutboundSpamRecipients = @(),

        [Parameter()]
        [Boolean]
        $NotifyOutboundSpam = $true,

        [Parameter()]
        [System.String]
        $RecipientLimitInternalPerHour,

        [Parameter()]
        [System.String]
        $RecipientLimitPerDay,

        [Parameter()]
        [System.String]
        $RecipientLimitExternalPerHour,

        [Parameter()]
        [System.String]
        $ActionWhenThresholdReached,

        [Parameter()]
        [System.String]
        $AutoForwardingMode,

        [Parameter()]
        [ValidateSet('Present')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $GlobalAdminAccount,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [System.String]
        $CertificatePath,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CertificatePassword
    )

    Write-Verbose -Message "Testing configuration of HostedOutboundSpamFilterPolicy for $Identity"

    if ($Global:CurrentModeIsExport)
    {
        $ConnectionMode = New-M365DSCConnection -Workload 'ExchangeOnline' `
            -InboundParameters $PSBoundParameters `
            -SkipModuleReload $true
    }
    else
    {
        $ConnectionMode = New-M365DSCConnection -Workload 'ExchangeOnline' `
            -InboundParameters $PSBoundParameters
    }

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName.Replace("MSFT_", "")
    $data = [System.Collections.Generic.Dictionary[[String], [String]]]::new()
    $data.Add("Resource", $ResourceName)
    $data.Add("Method", $MyInvocation.MyCommand)
    $data.Add("Principal", $GlobalAdminAccount.UserName)
    $data.Add("TenantId", $TenantId)
    $data.Add("ConnectionMode", $ConnectionMode)
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    $nullReturn = $PSBoundParameters
    $nullReturn.Ensure = 'Absent'
    try
    {
        $HostedOutboundSpamFilterPolicies = Get-HostedOutboundSpamFilterPolicy -ErrorAction Stop

        $HostedOutboundSpamFilterPolicy = $HostedOutboundSpamFilterPolicies | Where-Object -FilterScript { $_.Identity -eq $Identity }
        if (-not $HostedOutboundSpamFilterPolicy)
        {
            Write-Verbose -Message "HostedOutboundSpamFilterPolicy $($Identity) does not exist."
            return $nullReturn
        }
        else
        {
            $result = @{
                Ensure                                    = 'Present'
                Identity                                  = $Identity
                AdminDisplayName                          = $HostedOutboundSpamFilterPolicy.AdminDisplayName
                BccSuspiciousOutboundAdditionalRecipients = $HostedOutboundSpamFilterPolicy.BccSuspiciousOutboundAdditionalRecipients
                BccSuspiciousOutboundMail                 = $HostedOutboundSpamFilterPolicy.BccSuspiciousOutboundMail
                NotifyOutboundSpamRecipients              = $HostedOutboundSpamFilterPolicy.NotifyOutboundSpamRecipients
                NotifyOutboundSpam                        = $HostedOutboundSpamFilterPolicy.NotifyOutboundSpam
                RecipientLimitInternalPerHour             = $HostedOutboundSpamFilterPolicy.RecipientLimitInternalPerHour
                RecipientLimitPerDay                      = $HostedOutboundSpamFilterPolicy.RecipientLimitPerDay
                RecipientLimitExternalPerHour             = $HostedOutboundSpamFilterPolicy.RecipientLimitExternalPerHour
                ActionWhenThresholdReached                = $HostedOutboundSpamFilterPolicy.ActionWhenThresholdReached
                AutoForwardingMode                        = $HostedOutboundSpamFilterPolicy.AutoForwardingMode
                GlobalAdminAccount                        = $GlobalAdminAccount
                ApplicationId                             = $ApplicationId
                CertificateThumbprint                     = $CertificateThumbprint
                CertificatePath                           = $CertificatePath
                CertificatePassword                       = $CertificatePassword
                TenantId                                  = $TenantId
            }

            Write-Verbose -Message "Found HostedOutboundSpamFilterPolicy $($Identity)"
            Write-Verbose -Message "Get-TargetResource Result: `n $(Convert-M365DscHashtableToString -Hashtable $result)"
            return $result
        }
    }
    catch
    {
        try
        {
            Write-Verbose -Message $_
            $tenantIdValue = ""
            if (-not [System.String]::IsNullOrEmpty($TenantId))
            {
                $tenantIdValue = $TenantId
            }
            elseif ($null -ne $GlobalAdminAccount)
            {
                $tenantIdValue = $GlobalAdminAccount.UserName.Split('@')[1]
            }
            Add-M365DSCEvent -Message $_ -EntryType 'Error' `
                -EventID 1 -Source $($MyInvocation.MyCommand.Source) `
                -TenantId $tenantIdValue
        }
        catch
        {
            Write-Verbose -Message $_
        }
        return $nullReturn
    }
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter()]
        [System.String]
        $AdminDisplayName,

        [Parameter()]
        [System.String[]]
        $BccSuspiciousOutboundAdditionalRecipients = @(),

        [Parameter()]
        [Boolean]
        $BccSuspiciousOutboundMail = $true,

        [Parameter()]
        [System.String[]]
        $NotifyOutboundSpamRecipients = @(),

        [Parameter()]
        [Boolean]
        $NotifyOutboundSpam = $true,

        [Parameter()]
        [System.String]
        $RecipientLimitInternalPerHour,

        [Parameter()]
        [System.String]
        $RecipientLimitPerDay,

        [Parameter()]
        [System.String]
        $RecipientLimitExternalPerHour,

        [Parameter()]
        [System.String]
        $ActionWhenThresholdReached,

        [Parameter()]
        [System.String]
        $AutoForwardingMode,

        [Parameter()]
        [ValidateSet('Present')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $GlobalAdminAccount,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [System.String]
        $CertificatePath,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CertificatePassword
    )

    Write-Verbose -Message "Testing configuration of HostedOutboundSpamFilterPolicy for $Identity"
    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName.Replace("MSFT_", "")
    $data = [System.Collections.Generic.Dictionary[[String], [String]]]::new()
    $data.Add("Resource", $ResourceName)
    $data.Add("Method", $MyInvocation.MyCommand)
    $data.Add("Principal", $GlobalAdminAccount.UserName)
    $data.Add("TenantId", $TenantId)
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    $ConnectionMode = New-M365DSCConnection -Workload 'ExchangeOnline' `
        -InboundParameters $PSBoundParameters

    $HostedOutboundSpamFilterPolicyParams = [System.Collections.Hashtable]($PSBoundParameters)
    $HostedOutboundSpamFilterPolicyParams.Remove('Ensure') | Out-Null
    $HostedOutboundSpamFilterPolicyParams.Remove('GlobalAdminAccount') | Out-Null
    $HostedOutboundSpamFilterPolicyParams.Remove('ApplicationId') | Out-Null
    $HostedOutboundSpamFilterPolicyParams.Remove('TenantId') | Out-Null
    $HostedOutboundSpamFilterPolicyParams.Remove('CertificateThumbprint') | Out-Null
    $HostedOutboundSpamFilterPolicyParams.Remove('CertificatePath') | Out-Null
    $HostedOutboundSpamFilterPolicyParams.Remove('CertificatePassword') | Out-Null

    Write-Verbose -Message "Setting HostedOutboundSpamFilterPolicy $Identity with values: $(Convert-M365DscHashtableToString -Hashtable $HostedOutboundSpamFilterPolicyParams)"
    Set-HostedOutboundSpamFilterPolicy @HostedOutboundSpamFilterPolicyParams
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter()]
        [System.String]
        $AdminDisplayName,

        [Parameter()]
        [System.String[]]
        $BccSuspiciousOutboundAdditionalRecipients = @(),

        [Parameter()]
        [Boolean]
        $BccSuspiciousOutboundMail = $true,

        [Parameter()]
        [System.String[]]
        $NotifyOutboundSpamRecipients = @(),

        [Parameter()]
        [Boolean]
        $NotifyOutboundSpam = $true,

        [Parameter()]
        [System.String]
        $RecipientLimitInternalPerHour,

        [Parameter()]
        [System.String]
        $RecipientLimitPerDay,

        [Parameter()]
        [System.String]
        $RecipientLimitExternalPerHour,

        [Parameter()]
        [System.String]
        $ActionWhenThresholdReached,

        [Parameter()]
        [System.String]
        $AutoForwardingMode,

        [Parameter()]
        [ValidateSet('Present')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $GlobalAdminAccount,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [System.String]
        $CertificatePath,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CertificatePassword
    )
    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName.Replace("MSFT_", "")
    $data = [System.Collections.Generic.Dictionary[[String], [String]]]::new()
    $data.Add("Resource", $ResourceName)
    $data.Add("Method", $MyInvocation.MyCommand)
    $data.Add("Principal", $GlobalAdminAccount.UserName)
    $data.Add("TenantId", $TenantId)
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    Write-Verbose -Message "Testing configuration of HostedOutboundSpamFilterPolicy for $Identity"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $PSBoundParameters)"

    $ValuesToCheck = $PSBoundParameters
    $ValuesToCheck.Remove('GlobalAdminAccount') | Out-Null
    $ValuesToCheck.Remove('Verbose') | Out-Null
    $ValuesToCheck.Remove('ApplicationId') | Out-Null
    $ValuesToCheck.Remove('TenantId') | Out-Null
    $ValuesToCheck.Remove('CertificateThumbprint') | Out-Null
    $ValuesToCheck.Remove('CertificatePath') | Out-Null
    $ValuesToCheck.Remove('CertificatePassword') | Out-Null

    $TestResult = Test-M365DSCParameterState -CurrentValues $CurrentValues `
        -Source $($MyInvocation.MyCommand.Source) `
        -DesiredValues $PSBoundParameters `
        -ValuesToCheck $ValuesToCheck.Keys

    Write-Verbose -Message "Test-TargetResource returned $TestResult"

    return $TestResult
}

function Export-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [System.Management.Automation.PSCredential]
        $GlobalAdminAccount,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $CertificateThumbprint,

        [Parameter()]
        [System.String]
        $CertificatePath,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CertificatePassword
    )
    $ConnectionMode = New-M365DSCConnection -Workload 'ExchangeOnline' `
        -InboundParameters $PSBoundParameters `
        -SkipModuleReload $true

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName.Replace("MSFT_", "")
    $data = [System.Collections.Generic.Dictionary[[String], [String]]]::new()
    $data.Add("Resource", $ResourceName)
    $data.Add("Method", $MyInvocation.MyCommand)
    $data.Add("Principal", $GlobalAdminAccount.UserName)
    $data.Add("TenantId", $TenantId)
    $data.Add("ConnectionMode", $ConnectionMode)
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    try
    {
        [array]$HostedOutboundSpamFilterPolicies = Get-HostedOutboundSpamFilterPolicy -ErrorAction stop
        $dscContent = ''

        if ($HostedOutboundSpamFilterPolicies.Length -eq 0)
        {
            Write-Host $Global:M365DSCEmojiGreenCheckMark
        }
        else
        {
            Write-Host "`r`n" -NoNewline
        }
        $i = 1
        foreach ($HostedOutboundSpamFilterPolicy in $HostedOutboundSpamFilterPolicies)
        {
            $Params = @{
                GlobalAdminAccount    = $GlobalAdminAccount
                Identity              = $HostedOutboundSpamFilterPolicy.Identity
                ApplicationId         = $ApplicationId
                TenantId              = $TenantId
                CertificateThumbprint = $CertificateThumbprint
                CertificatePassword   = $CertificatePassword
                CertificatePath       = $CertificatePath
            }
            Write-Host "    |---[$i/$($HostedOutboundSpamFilterPolicies.Length)] $($HostedOutboundSpamFilterPolicy.Identity)" -NoNewline
            $Results = Get-TargetResource @Params
            $Results = Update-M365DSCExportAuthenticationResults -ConnectionMode $ConnectionMode `
                -Results $Results
            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
                -ConnectionMode $ConnectionMode `
                -ModulePath $PSScriptRoot `
                -Results $Results `
                -GlobalAdminAccount $GlobalAdminAccount
            $dscContent += $currentDSCBlock
            Save-M365DSCPartialExport -Content $currentDSCBlock `
                -FileName $Global:PartialExportFileName
            Write-Host $Global:M365DSCEmojiGreenCheckMark
            $i++
        }
        return $dscContent
    }
    catch
    {
        try
        {
            Write-Verbose -Message $_
            $tenantIdValue = ""
            if (-not [System.String]::IsNullOrEmpty($TenantId))
            {
                $tenantIdValue = $TenantId
            }
            elseif ($null -ne $GlobalAdminAccount)
            {
                $tenantIdValue = $GlobalAdminAccount.UserName.Split('@')[1]
            }
            Add-M365DSCEvent -Message $_ -EntryType 'Error' `
                -EventID 1 -Source $($MyInvocation.MyCommand.Source) `
                -TenantId $tenantIdValue
        }
        catch
        {
            Write-Verbose -Message $_
        }
        return ""
    }
}

Export-ModuleMember -Function *-TargetResource
