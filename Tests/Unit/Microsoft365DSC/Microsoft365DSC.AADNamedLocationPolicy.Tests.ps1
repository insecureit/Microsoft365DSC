[CmdletBinding()]
param(
)
$M365DSCTestFolder = Join-Path -Path $PSScriptRoot `
    -ChildPath "..\..\Unit" `
    -Resolve
$CmdletModule = (Join-Path -Path $M365DSCTestFolder `
        -ChildPath "\Stubs\Microsoft365.psm1" `
        -Resolve)
$GenericStubPath = (Join-Path -Path $M365DSCTestFolder `
        -ChildPath "\Stubs\Generic.psm1" `
        -Resolve)
Import-Module -Name (Join-Path -Path $M365DSCTestFolder `
        -ChildPath "\UnitTestHelper.psm1" `
        -Resolve)

$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource "AADNamedLocationPolicy" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {
            $secpasswd = ConvertTo-SecureString "test@password1" -AsPlainText -Force
            $GlobalAdminAccount = New-Object System.Management.Automation.PSCredential ("tenantadmin", $secpasswd)

            Mock -CommandName Get-M365DSCExportContentForResource -MockWith {

            }

            Mock -CommandName Get-PSSession -MockWith {

            }

            Mock -CommandName Remove-PSSession -MockWith {

            }

            Mock -CommandName Set-AzureADMSNamedLocationPolicy -MockWith {

            }

            Mock -CommandName Remove-AzureADMSNamedLocationPolicy -MockWith {

            }

            Mock -CommandName New-AzureADMSNamedLocationPolicy -MockWith {

            }

            Mock -CommandName New-M365DSCConnection -MockWith {
                return "Credential"
            }
        }

        # Test contexts
        Context -Name "The Policy should exist but it does not" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName        = "Company Network"
                    Ensure             = "Present"
                    IpRanges           = @("2.1.1.1/32", "1.2.2.2/32")
                    IsTrusted          = $True
                    OdataType          = "#microsoft.graph.ipNamedLocation"
                    GlobalAdminAccount = $credsGlobalAdmin
                }

                Mock -CommandName Get-AzureADMSNamedLocationPolicy -MockWith {
                    return $null
                }
            }

            It "Should return values from the get method" {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName "Get-AzureADMSNamedLocationPolicy" -Exactly 2
            }
            It 'Should return false from the test method' {
                Test-TargetResource @testParams | Should -Be $false
            }
            It 'Should create the Policy from the set method' {
                Set-TargetResource @testParams
                Should -Invoke -CommandName "New-AzureADMSNamedLocationPolicy" -Exactly 1
            }
        }
        Context -Name "The Policy exists but it should not" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName        = "Company Network"
                    Ensure             = "Absent"
                    IpRanges           = @("2.1.1.1/32", "1.2.2.2/32")
                    IsTrusted          = $True
                    OdataType          = "#microsoft.graph.ipNamedLocation"
                    GlobalAdminAccount = $credsGlobalAdmin
                }

                Mock -CommandName Get-AzureADMSNamedLocationPolicy -MockWith {
                    return @{
                        DisplayName                       = "Company Network"
                        Id                                = "046956df-2367-4dd4-b7fd-c6175ec11cd5"
                        IpRanges                          = @(@{CidrAddress = "2.1.1.1/32" }, @{CidrAddress = "1.2.2.2/32" })
                        IsTrusted                         = $True
                        OdataType                         = "#microsoft.graph.ipNamedLocation"
                        CountriesAndRegions               = $null
                        IncludeUnknownCountriesAndRegions = $null
                    }
                }
            }

            It "Should return values from the get method" {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName "Get-AzureADMSNamedLocationPolicy" -Exactly 1
            }

            It 'Should return false from the test method' {
                Test-TargetResource @testParams | Should -Be $false
            }

            It 'Should remove the app from the set method' {
                Set-TargetResource @testParams
                Should -Invoke -CommandName "Remove-AzureADMSNamedLocationPolicy" -Exactly 1
            }
        }

        Context -Name "The Policy exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName        = "Company Network"
                    Ensure             = "Present"
                    IpRanges           = @("2.1.1.1/32", "1.2.2.2/32")
                    IsTrusted          = $True
                    OdataType          = "#microsoft.graph.ipNamedLocation"
                    GlobalAdminAccount = $credsGlobalAdmin
                }

                Mock -CommandName Get-AzureADMSNamedLocationPolicy -MockWith {
                    return @{
                        DisplayName                       = "Company Network"
                        Id                                = "046956df-2367-4dd4-b7fd-c6175ec11cd5"
                        IpRanges                          = @(@{CidrAddress = "2.1.1.1/32" }, @{CidrAddress = "1.2.2.2/32" })
                        IsTrusted                         = $True
                        OdataType                         = "#microsoft.graph.ipNamedLocation"
                        CountriesAndRegions               = $null
                        IncludeUnknownCountriesAndRegions = $null
                    }
                }
            }

            It "Should return Values from the get method" {
                Get-TargetResource @testParams
                Should -Invoke -CommandName "Get-AzureADMSNamedLocationPolicy" -Exactly 1
            }

            It 'Should return true from the test method' {
                Test-TargetResource @testParams | Should -Be $true
            }
        }

        Context -Name "Values are not in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName        = "Company Network"
                    Ensure             = "Present"
                    IpRanges           = @("2.1.1.1/32", "1.2.2.2/32")
                    IsTrusted          = $True
                    OdataType          = "#microsoft.graph.ipNamedLocation"
                    GlobalAdminAccount = $credsGlobalAdmin
                }

                Mock -CommandName Get-AzureADMSNamedLocationPolicy -MockWith {
                    return @{
                        DisplayName                       = "Company Network"
                        Id                                = "046956df-2367-4dd4-b7fd-c6175ec11cd5"
                        IpRanges                          = @(@{CidrAddress = "1.1.1.1/32" }, @{CidrAddress = "2.2.2.2/32" })
                        IsTrusted                         = $True
                        OdataType                         = "#microsoft.graph.ipNamedLocation"
                        CountriesAndRegions               = $null
                        IncludeUnknownCountriesAndRegions = $null
                    }
                }
            }

            It "Should return values from the get method" {
                Get-TargetResource @testParams
                Should -Invoke -CommandName "Get-AzureADMSNamedLocationPolicy" -Exactly 1
            }

            It 'Should return false from the test method' {
                Test-TargetResource @testParams | Should -Be $false
            }

            It "Should call the set method" {
                Set-TargetResource @testParams
                Should -Invoke -CommandName "Set-AzureADMSNamedLocationPolicy" -Exactly 1
            }
        }

        Context -Name "ReverseDSC tests" -Fixture {
            BeforeAll {
                $testParams = @{
                    GlobalAdminAccount = $GlobalAdminAccount
                }

                Mock -CommandName Get-AzureADMSNamedLocationPolicy -MockWith {
                    return @{
                        DisplayName                       = "Company Network"
                        Id                                = "046956df-2367-4dd4-b7fd-c6175ec11cd5"
                        IpRanges                          = @(@{CidrAddress = "2.1.1.1/32" }, @{CidrAddress = "1.2.2.2/32" })
                        IsTrusted                         = $True
                        OdataType                         = "#microsoft.graph.ipNamedLocation"
                        CountriesAndRegions               = $null
                        IncludeUnknownCountriesAndRegions = $null
                    }
                }
            }

            It "Should reverse engineer resource from the export method" {
                Export-TargetResource @testParams
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
