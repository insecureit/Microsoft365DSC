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
        [ValidateLength(0, 256)]
        [System.String]
        $DomainName,

        [Parameter()]
        [ValidateSet('External', 'ExternalLegacy', 'InternalLegacy', 'None')]
        [System.String]
        $AllowedOOFType,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Boolean]
        $AutoForwardEnabled,

        [Parameter()]
        [System.Boolean]
        $AutoReplyEnabled,

        [Parameter()]
        [ValidateSet('Use7Bit', 'UseQP', 'UseBase64', 'UseQPHtmlDetectTextPlain', 'UseBase64HtmlDetectTextPlain', 'UseQPHtml7BitTextPlain', 'UseBase64Html7BitTextPlain', 'Undefined')]
        [System.String]
        $ByteEncoderTypeFor7BitCharsets,

        [Parameter()]
        [System.String]
        $CharacterSet,

        [Parameter()]
        [ValidateSet('MimeHtmlText', 'MimeText', 'MimeHtml')]
        [System.String]
        $ContentType,

        [Parameter()]
        [System.Boolean]
        $DeliveryReportEnabled,

        [Parameter()]
        [System.Boolean]
        $DisplaySenderName,

        [Parameter()]
        [System.Boolean]
        $IsInternal,

        [Parameter()]
        [System.String]
        $LineWrapSize,

        [Parameter()]
        [System.Boolean]
        $MeetingForwardNotificationEnabled,

        [Parameter()]
        [ValidateLength(1, 64)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $NonMimeCharacterSet,

        [Parameter()]
        [ValidateSet('50220', '50221', '50222', 'Undefined')]
        [System.String]
        $PreferredInternetCodePageForShiftJis,

        [Parameter()]
        [System.Int32]
        $RequiredCharsetCoverage,

        [Parameter()]
        [System.Boolean]
        $TargetDeliveryDomain,

        [Parameter()]
        [System.Boolean]
        $TNEFEnabled,

        [Parameter()]
        [System.Boolean]
        $TrustedMailInboundEnabled,

        [Parameter()]
        [System.Boolean]
        $TrustedMailOutboundEnabled,

        [Parameter()]
        [System.Boolean]
        $UseSimpleDisplayName,

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
    Write-Verbose -Message "Getting configuration of Remote Domain for $Identity"

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
    $nullReturn.Ensure = "Absent"
    try
    {
        $RemoteDomain = Get-RemoteDomain -Identity $Identity -ErrorAction SilentlyContinue

        if ($null -eq $RemoteDomain)
        {
            Write-Verbose -Message "RemoteDomain configuration for $($Identity) does not exist."
            return $nullReturn
        }
        else
        {
            $result = @{
                Identity                             = $RemoteDomain.Identity
                DomainName                           = $RemoteDomain.DomainName
                AllowedOOFType                       = $RemoteDomain.AllowedOOFType
                Ensure                               = 'Present'
                AutoForwardEnabled                   = $RemoteDomain.AutoForwardEnabled
                AutoReplyEnabled                     = $RemoteDomain.AutoReplyEnabled
                ByteEncoderTypeFor7BitCharsets       = $RemoteDomain.ByteEncoderTypeFor7BitCharsets
                CharacterSet                         = $RemoteDomain.CharacterSet
                ContentType                          = $RemoteDomain.ContentType
                DeliveryReportEnabled                = $RemoteDomain.DeliveryReportEnabled
                DisplaySenderName                    = $RemoteDomain.DisplaySenderName
                IsInternal                           = $RemoteDomain.IsInternal
                LineWrapSize                         = $RemoteDomain.LineWrapSize
                MeetingForwardNotificationEnabled    = $RemoteDomain.MeetingForwardNotificationEnabled
                Name                                 = $RemoteDomain.Name
                NonMimeCharacterSet                  = $RemoteDomain.NonMimeCharacterSet
                PreferredInternetCodePageForShiftJis = $RemoteDomain.PreferredInternetCodePageForShiftJis
                RequiredCharsetCoverage              = $RemoteDomain.RequiredCharsetCoverage
                TargetDeliveryDomain                 = $RemoteDomain.TargetDeliveryDomain
                TNEFEnabled                          = $RemoteDomain.TNEFEnabled
                TrustedMailInboundEnabled            = $RemoteDomain.TrustedMailInboundEnabled
                TrustedMailOutboundEnabled           = $RemoteDomain.TrustedMailOutboundEnabled
                UseSimpleDisplayName                 = $RemoteDomain.UseSimpleDisplayName
                GlobalAdminAccount                   = $GlobalAdminAccount
                ApplicationId                        = $ApplicationId
                CertificateThumbprint                = $CertificateThumbprint
                CertificatePath                      = $CertificatePath
                CertificatePassword                  = $CertificatePassword
                TenantId                             = $TenantId
            }

            Write-Verbose -Message "Found RemoteDomain configuration for $Identity"
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
        [ValidateLength(0, 256)]
        [System.String]
        $DomainName,

        [Parameter()]
        [ValidateSet('External', 'ExternalLegacy', 'InternalLegacy', 'None')]
        [System.String]
        $AllowedOOFType,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Boolean]
        $AutoForwardEnabled,

        [Parameter()]
        [System.Boolean]
        $AutoReplyEnabled,

        [Parameter()]
        [ValidateSet('Use7Bit', 'UseQP', 'UseBase64', 'UseQPHtmlDetectTextPlain', 'UseBase64HtmlDetectTextPlain', 'UseQPHtml7BitTextPlain', 'UseBase64Html7BitTextPlain', 'Undefined')]
        [System.String]
        $ByteEncoderTypeFor7BitCharsets,

        [Parameter()]
        [System.String]
        $CharacterSet,

        [Parameter()]
        [ValidateSet('MimeHtmlText', 'MimeText', 'MimeHtml')]
        [System.String]
        $ContentType,

        [Parameter()]
        [System.Boolean]
        $DeliveryReportEnabled,

        [Parameter()]
        [System.Boolean]
        $DisplaySenderName,

        [Parameter()]
        [System.Boolean]
        $IsInternal,

        [Parameter()]
        [System.String]
        $LineWrapSize,

        [Parameter()]
        [System.Boolean]
        $MeetingForwardNotificationEnabled,

        [Parameter()]
        [ValidateLength(1, 64)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $NonMimeCharacterSet,

        [Parameter()]
        [ValidateSet('50220', '50221', '50222', 'Undefined')]
        [System.String]
        $PreferredInternetCodePageForShiftJis,

        [Parameter()]
        [System.Int32]
        $RequiredCharsetCoverage,

        [Parameter()]
        [System.Boolean]
        $TargetDeliveryDomain,

        [Parameter()]
        [System.Boolean]
        $TNEFEnabled,

        [Parameter()]
        [System.Boolean]
        $TrustedMailInboundEnabled,

        [Parameter()]
        [System.Boolean]
        $TrustedMailOutboundEnabled,

        [Parameter()]
        [System.Boolean]
        $UseSimpleDisplayName,

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
    Write-Verbose -Message "Setting configuration of Remote Domain for $Identity"

    $currentRemoteDomainConfig = Get-TargetResource @PSBoundParameters

    $ConnectionMode = New-M365DSCConnection -Workload 'ExchangeOnline' `
        -InboundParameters $PSBoundParameters

    $RemoteDomainParams = [System.Collections.Hashtable]($PSBoundParameters)
    $RemoteDomainParams.Remove("GlobalAdminAccount") | Out-Null
    $RemoteDomainParams.Remove("Ensure") | Out-Null
    $RemoteDomainParams.Remove("ApplicationId") | Out-Null
    $RemoteDomainParams.Remove("TenantId") | Out-Null
    $RemoteDomainParams.Remove("CertificateThumbprint") | Out-Null
    $RemoteDomainParams.Remove('CertificatePath') | Out-Null
    $RemoteDomainParams.Remove('CertificatePassword') | Out-Null

    # CASE: Remote Domain doesn't exist but should;
    if ($Ensure -eq "Present" -and $currentRemoteDomainConfig.Ensure -eq "Absent")
    {
        Write-Verbose -Message "Remote Domain '$($Name)' does not exist but it should. Create and configure it."
        # Create remote domain
        if ([System.String]::IsNullOrEmpty($Name))
        {
            $Name = $Identity
        }
        New-RemoteDomain -Name $Name -DomainName $DomainName

        # Configure new remote domain
        $RemoteDomainParams.Remove("DomainName") | Out-Null
        Set-RemoteDomain @RemoteDomainParams
    }
    # CASE: Remote Domain exists but it shouldn't;
    elseif ($Ensure -eq "Absent" -and $currentRemoteDomainConfig.Ensure -eq "Present")
    {
        Write-Verbose -Message "Remote Domain '$($Name)' exists but it shouldn't. Remove it."
        Remove-RemoteDomain -Identity $Name -Confirm:$false
    }
    # CASE: Remote Domain exists and it should, but has different values than the desired ones
    elseif ($Ensure -eq "Present" -and $currentRemoteDomainConfig.Ensure -eq "Present")
    {
        Write-Verbose -Message "Remote Domain '$($Name)' already exists, but needs updating."
        Write-Verbose -Message "Setting RemoteDomain for $($Identity) with values: $(Convert-M365DscHashtableToString -Hashtable $RemoteDomainParams)"
        $RemoteDomainParams.Remove("DomainName") | Out-Null
        Set-RemoteDomain @RemoteDomainParams
    }
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
        [ValidateLength(0, 256)]
        [System.String]
        $DomainName,

        [Parameter()]
        [ValidateSet('External', 'ExternalLegacy', 'InternalLegacy', 'None')]
        [System.String]
        $AllowedOOFType,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Boolean]
        $AutoForwardEnabled,

        [Parameter()]
        [System.Boolean]
        $AutoReplyEnabled,

        [Parameter()]
        [ValidateSet('Use7Bit', 'UseQP', 'UseBase64', 'UseQPHtmlDetectTextPlain', 'UseBase64HtmlDetectTextPlain', 'UseQPHtml7BitTextPlain', 'UseBase64Html7BitTextPlain', 'Undefined')]
        [System.String]
        $ByteEncoderTypeFor7BitCharsets,

        [Parameter()]
        [System.String]
        $CharacterSet,

        [Parameter()]
        [ValidateSet('MimeHtmlText', 'MimeText', 'MimeHtml')]
        [System.String]
        $ContentType,

        [Parameter()]
        [System.Boolean]
        $DeliveryReportEnabled,

        [Parameter()]
        [System.Boolean]
        $DisplaySenderName,

        [Parameter()]
        [System.Boolean]
        $IsInternal,

        [Parameter()]
        [System.String]
        $LineWrapSize,

        [Parameter()]
        [System.Boolean]
        $MeetingForwardNotificationEnabled,

        [Parameter()]
        [ValidateLength(1, 64)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $NonMimeCharacterSet,

        [Parameter()]
        [ValidateSet('50220', '50221', '50222', 'Undefined')]
        [System.String]
        $PreferredInternetCodePageForShiftJis,

        [Parameter()]
        [System.Int32]
        $RequiredCharsetCoverage,

        [Parameter()]
        [System.Boolean]
        $TargetDeliveryDomain,

        [Parameter()]
        [System.Boolean]
        $TNEFEnabled,

        [Parameter()]
        [System.Boolean]
        $TrustedMailInboundEnabled,

        [Parameter()]
        [System.Boolean]
        $TrustedMailOutboundEnabled,

        [Parameter()]
        [System.Boolean]
        $UseSimpleDisplayName,

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

    Write-Verbose -Message "Testing configuration of Remote Domain for $Identity"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $PSBoundParameters)"

    $ValuesToCheck = $PSBoundParameters
    $ValuesToCheck.Remove('GlobalAdminAccount') | Out-Null
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
        [array]$AllRemoteDomains = Get-RemoteDomain -ErrorAction Stop

        $dscContent = ""

        if ($AllRemoteDomains.Length -eq 0)
        {
            Write-Host $Global:M365DSCEmojiGreenCheckMark
        }
        else
        {
            Write-Host "`r`n" -NoNewline
        }
        $i = 1
        foreach ($domain in $AllRemoteDomains)
        {
            Write-Host "    |---[$i/$($AllRemoteDomains.Length)] $($domain.Identity)" -NoNewline

            $Params = @{
                Identity              = $domain.Identity
                GlobalAdminAccount    = $GlobalAdminAccount
                ApplicationId         = $ApplicationId
                TenantId              = $TenantId
                CertificateThumbprint = $CertificateThumbprint
                CertificatePassword   = $CertificatePassword
                CertificatePath       = $CertificatePath
            }
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

