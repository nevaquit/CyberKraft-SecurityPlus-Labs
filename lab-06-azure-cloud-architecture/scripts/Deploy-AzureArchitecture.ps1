<#
.SYNOPSIS
    Deploys the foundational Azure Cloud Architecture for the CyberKraft Security+ Labs.

.DESCRIPTION
    This script automates the creation of the Azure Resource Group, Virtual Network (VNet),
    Subnets, and Network Security Groups (NSGs) required for the lab environment.
    It implements cloud engineering principles such as microsegmentation and least privilege.

.NOTES
    Author: Manus AI
    Date: May 3, 2026
    Lab: 06 - Azure Cloud Architecture & Engineering
#>

# Variables
$ResourceGroupName = "HENRYVM_GROUP"
$Location = "SouthAfricaNorth"
$VNetName = "CyberKraft-VNet"
$VNetAddressPrefix = "10.0.0.0/16"
$PublicSubnetName = "Subnet-Public"
$PublicSubnetPrefix = "10.0.1.0/24"
$PrivateSubnetName = "Subnet-Private"
$PrivateSubnetPrefix = "10.0.2.0/24"
$NSGName = "NSG-Private-Tier"

# 1. Create Resource Group (if it doesn't exist)
Write-Host "Checking Resource Group: $ResourceGroupName..."
if (!(Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue)) {
    Write-Host "Creating Resource Group: $ResourceGroupName in $Location..."
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location
}

# 2. Create Network Security Group (NSG)
Write-Host "Creating Network Security Group: $NSGName..."
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Location $Location -Name $NSGName

# 3. Add Security Rules to NSG
Write-Host "Adding Security Rules to NSG..."
# Allow Splunk Web (Port 8000)
$nsg | Add-AzNetworkSecurityRuleConfig -Name "Allow-Splunk-Web" -Description "Allow Splunk Web UI" -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange 8000
# Allow Nessus Web (Port 8834)
$nsg | Add-AzNetworkSecurityRuleConfig -Name "Allow-Nessus-Web" -Description "Allow Nessus Web UI" -Access Allow -Protocol Tcp -Direction Inbound -Priority 110 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange 8834
# Deny All Inbound (Implicit Deny)
$nsg | Add-AzNetworkSecurityRuleConfig -Name "Deny-All-Inbound" -Description "Implicit Deny All Inbound" -Access Deny -Protocol "*" -Direction Inbound -Priority 4096 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange "*"
$nsg | Set-AzNetworkSecurityGroup

# 4. Create Subnets
Write-Host "Defining Subnets..."
$publicSubnet = New-AzVirtualNetworkSubnetConfig -Name $PublicSubnetName -AddressPrefix $PublicSubnetPrefix
$privateSubnet = New-AzVirtualNetworkSubnetConfig -Name $PrivateSubnetName -AddressPrefix $PrivateSubnetPrefix -NetworkSecurityGroup $nsg

# 5. Create Virtual Network (VNet)
Write-Host "Creating Virtual Network: $VNetName..."
New-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Location $Location -Name $VNetName -AddressPrefix $VNetAddressPrefix -Subnet $publicSubnet, $privateSubnet

Write-Host "Azure Cloud Architecture Deployment Complete."
