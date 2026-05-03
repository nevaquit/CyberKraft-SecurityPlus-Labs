# Lab 01 — Active Directory: User, GPO & Security Policy Management

**SY0-701 Domains:** 2.4 Identity & Access Management · 3.1 Security Architecture · 4.6 Hardening

---

## Why This Lab Matters

Nearly every enterprise runs Active Directory. The ability to stand up a domain, create users with PowerShell, and apply Group Policy Objects (GPOs) demonstrates immediate on-the-job value for sysadmin, help desk Level II, and SOC analyst roles. This lab directly maps to the Security+ exam's emphasis on identity management, least privilege, and defense-in-depth.

### Cloud Architecture Integration
In a modern cloud environment (as built in **Lab 06**), this on-premises Active Directory domain (`cyberkraft.local`) serves as the foundation for a hybrid identity model. By integrating this local AD with Azure AD (Entra ID) via Azure AD Connect, we extend our on-premises identities to the cloud, enabling Single Sign-On (SSO) and consistent RBAC across both environments.

---

## Environment

| Component | Details |
|-----------|---------|
| **Platform** | Microsoft Azure — HenryVM (South Africa North) |
| **OS** | Windows Server 2022 (Domain Controller) |
| **Client** | Windows 10 Enterprise (domain-joined) |
| **Domain Name** | `cyberkraft.local` |
| **Domain Controller IP** | `10.0.0.4` (Azure private IP) |
| **Tools** | PowerShell, ADUC, Group Policy Management Console, Event Viewer |

---

## Objectives

1. Promote Windows Server 2022 to a Domain Controller
2. Create an Active Directory domain (`cyberkraft.local`)
3. Build an Organizational Unit (OU) structure reflecting a real enterprise
4. Bulk-create 50+ user accounts using PowerShell
5. Create RBAC security groups (Help Desk, Accounting, IT Admins)
6. Configure and apply Group Policy Objects for security hardening
7. Enable audit logging and verify events in Event Viewer
8. Join a Windows 10 client to the domain

---

## Step-by-Step Execution

### Phase 1: Domain Controller Setup

**Step 1 — Install Active Directory Domain Services**

Open PowerShell as Administrator and run:

```powershell
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
```

**Step 2 — Promote Server to Domain Controller**

```powershell
Import-Module ADDSDeployment

Install-ADDSForest `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainMode "WinThreshold" `
    -DomainName "cyberkraft.local" `
    -DomainNetbiosName "CYBERKRAFT" `
    -ForestMode "WinThreshold" `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$false `
    -SysvolPath "C:\Windows\SYSVOL" `
    -Force:$true
```

The server will reboot automatically after promotion.

---

### Phase 2: Organizational Unit Structure

After reboot, open **Active Directory Users and Computers (ADUC)** and create the following OU hierarchy:

```
cyberkraft.local
├── _CYBERKRAFT_USERS
│   ├── Help Desk
│   ├── Accounting
│   ├── IT Admins
│   └── Standard Users
├── _CYBERKRAFT_GROUPS
│   ├── GRP_HelpDesk
│   ├── GRP_Accounting
│   └── GRP_ITAdmins
├── _CYBERKRAFT_COMPUTERS
│   ├── Workstations
│   └── Servers
└── _CYBERKRAFT_DISABLED
```

**PowerShell to create the OU structure:**

```powershell
# Create top-level OUs
$OUs = @(
    "OU=_CYBERKRAFT_USERS,DC=cyberkraft,DC=local",
    "OU=_CYBERKRAFT_GROUPS,DC=cyberkraft,DC=local",
    "OU=_CYBERKRAFT_COMPUTERS,DC=cyberkraft,DC=local",
    "OU=_CYBERKRAFT_DISABLED,DC=cyberkraft,DC=local"
)

foreach ($OU in $OUs) {
    $Name = ($OU -split ",")[0] -replace "OU=",""
    $Path = ($OU -split ",",2)[1]
    New-ADOrganizationalUnit -Name $Name -Path $Path -ProtectedFromAccidentalDeletion $true
}

# Create sub-OUs
New-ADOrganizationalUnit -Name "Help Desk" -Path "OU=_CYBERKRAFT_USERS,DC=cyberkraft,DC=local"
New-ADOrganizationalUnit -Name "Accounting" -Path "OU=_CYBERKRAFT_USERS,DC=cyberkraft,DC=local"
New-ADOrganizationalUnit -Name "IT Admins" -Path "OU=_CYBERKRAFT_USERS,DC=cyberkraft,DC=local"
New-ADOrganizationalUnit -Name "Standard Users" -Path "OU=_CYBERKRAFT_USERS,DC=cyberkraft,DC=local"
New-ADOrganizationalUnit -Name "Workstations" -Path "OU=_CYBERKRAFT_COMPUTERS,DC=cyberkraft,DC=local"
New-ADOrganizationalUnit -Name "Servers" -Path "OU=_CYBERKRAFT_COMPUTERS,DC=cyberkraft,DC=local"
```

---

### Phase 3: Bulk User Creation

See the full script at [`scripts/Create-BulkUsers.ps1`](./scripts/Create-BulkUsers.ps1).

**Summary of what the script does:**
- Reads from a CSV file (`users.csv`) containing FirstName, LastName, Department, and Title
- Creates user accounts with a standardized naming convention (`firstname.lastname`)
- Sets a default password (`CyberKraft2024!`) with `ChangePasswordAtLogon` set to `$true`
- Places each user in the correct OU based on their Department
- Adds users to the appropriate security group

**Sample execution:**

```powershell
# Import users from CSV
Import-Csv -Path "C:\Scripts\users.csv" | ForEach-Object {
    $Username = "$($_.FirstName.ToLower()).$($_.LastName.ToLower())"
    $OU = switch ($_.Department) {
        "Help Desk"  { "OU=Help Desk,OU=_CYBERKRAFT_USERS,DC=cyberkraft,DC=local" }
        "Accounting" { "OU=Accounting,OU=_CYBERKRAFT_USERS,DC=cyberkraft,DC=local" }
        "IT Admins"  { "OU=IT Admins,OU=_CYBERKRAFT_USERS,DC=cyberkraft,DC=local" }
        default      { "OU=Standard Users,OU=_CYBERKRAFT_USERS,DC=cyberkraft,DC=local" }
    }
    
    New-ADUser `
        -Name "$($_.FirstName) $($_.LastName)" `
        -GivenName $_.FirstName `
        -Surname $_.LastName `
        -SamAccountName $Username `
        -UserPrincipalName "$Username@cyberkraft.local" `
        -Path $OU `
        -Department $_.Department `
        -Title $_.Title `
        -AccountPassword (ConvertTo-SecureString "CyberKraft2024!" -AsPlainText -Force) `
        -ChangePasswordAtLogon $true `
        -Enabled $true
    
    Write-Host "Created user: $Username in $OU"
}
```

**Result:** 50 user accounts created across all departments.

---

### Phase 4: RBAC Security Groups

```powershell
# Create security groups
New-ADGroup -Name "GRP_HelpDesk" `
    -GroupScope Global `
    -GroupCategory Security `
    -Path "OU=_CYBERKRAFT_GROUPS,DC=cyberkraft,DC=local" `
    -Description "Help Desk staff — password reset and basic support"

New-ADGroup -Name "GRP_Accounting" `
    -GroupScope Global `
    -GroupCategory Security `
    -Path "OU=_CYBERKRAFT_GROUPS,DC=cyberkraft,DC=local" `
    -Description "Accounting department — financial system access"

New-ADGroup -Name "GRP_ITAdmins" `
    -GroupScope Global `
    -GroupCategory Security `
    -Path "OU=_CYBERKRAFT_GROUPS,DC=cyberkraft,DC=local" `
    -Description "IT Administrators — full domain admin rights"

# Add users to groups based on OU membership
Get-ADUser -Filter * -SearchBase "OU=Help Desk,OU=_CYBERKRAFT_USERS,DC=cyberkraft,DC=local" |
    Add-ADGroupMember -Identity "GRP_HelpDesk" -Members $_

Get-ADUser -Filter * -SearchBase "OU=Accounting,OU=_CYBERKRAFT_USERS,DC=cyberkraft,DC=local" |
    Add-ADGroupMember -Identity "GRP_Accounting" -Members $_

Get-ADUser -Filter * -SearchBase "OU=IT Admins,OU=_CYBERKRAFT_USERS,DC=cyberkraft,DC=local" |
    Add-ADGroupMember -Identity "GRP_ITAdmins" -Members $_
```

---

### Phase 5: Group Policy Objects

Four GPOs were created and linked to the domain:

#### GPO 1 — Password Policy

| Setting | Value | Rationale |
|---------|-------|-----------|
| Minimum password length | 12 characters | NIST SP 800-63B recommendation |
| Password complexity | Enabled | Requires uppercase, lowercase, number, symbol |
| Maximum password age | 90 days | Limits exposure window |
| Minimum password age | 1 day | Prevents immediate cycling |
| Password history | 24 passwords | Prevents reuse |
| Account lockout threshold | 5 attempts | Mitigates brute-force |
| Account lockout duration | 30 minutes | Auto-unlock after delay |
| Observation window | 30 minutes | Reset counter window |

**GPO Path:** `Computer Configuration > Windows Settings > Security Settings > Account Policies`

#### GPO 2 — Audit Logging Policy

| Setting | Value |
|---------|-------|
| Audit account logon events | Success, Failure |
| Audit logon events | Success, Failure |
| Audit account management | Success, Failure |
| Audit policy change | Success, Failure |
| Audit privilege use | Failure |
| Audit object access | Success, Failure |

**GPO Path:** `Computer Configuration > Windows Settings > Security Settings > Local Policies > Audit Policy`

#### GPO 3 — Screensaver Lock Policy

| Setting | Value |
|---------|-------|
| Enable screensaver | Enabled |
| Screensaver timeout | 600 seconds (10 minutes) |
| Password protect screensaver | Enabled |

**GPO Path:** `User Configuration > Administrative Templates > Control Panel > Personalization`

#### GPO 4 — Software Restriction / AppLocker

| Setting | Value |
|---------|-------|
| Block execution from %TEMP% | Enabled |
| Block execution from Downloads | Enabled |
| Allow only signed executables | Enabled (Audit mode) |

---

### Phase 6: Domain Join — Windows 10 Client

On the Windows 10 client machine:

1. Set DNS to point to the Domain Controller IP (`10.0.0.4`)
2. Navigate to **System Properties > Computer Name > Change**
3. Select **Domain** and enter `cyberkraft.local`
4. Authenticate with Domain Admin credentials
5. Restart the machine

**Verification via PowerShell on client:**

```powershell
# Verify domain membership
(Get-WmiObject Win32_ComputerSystem).Domain
# Expected output: cyberkraft.local

# Test domain connectivity
nltest /sc_verify:cyberkraft.local
```

---

### Phase 7: Verification & Evidence

**Verify GPO application:**

```powershell
# Run on domain-joined machine
gpresult /R /SCOPE COMPUTER
gpresult /H C:\Reports\GPO-Report.html
```

**Verify audit logging in Event Viewer:**
- Open **Event Viewer > Windows Logs > Security**
- Filter for Event ID `4625` (Failed logon) and `4624` (Successful logon)
- Simulate a failed login attempt and confirm the event appears

**Verify user creation:**

```powershell
# Count total users in domain
(Get-ADUser -Filter *).Count

# List all users with their OU
Get-ADUser -Filter * -Properties Department | 
    Select-Object Name, SamAccountName, Department |
    Sort-Object Department |
    Format-Table -AutoSize
```

---

## Evidence & Findings

### Screenshot Inventory

| File | Description |
|------|-------------|
| `screenshots/01-aduc-ou-structure.png` | ADUC showing full OU hierarchy |
| `screenshots/02-aduc-users-helpdesk.png` | Help Desk OU with user accounts |
| `screenshots/03-aduc-users-accounting.png` | Accounting OU with user accounts |
| `screenshots/04-aduc-groups.png` | Security groups in _CYBERKRAFT_GROUPS OU |
| `screenshots/05-gpo-password-policy.png` | Password policy GPO settings |
| `screenshots/06-gpo-audit-policy.png` | Audit logging GPO settings |
| `screenshots/07-gpo-screensaver.png` | Screensaver lock GPO settings |
| `screenshots/08-event-viewer-4625.png` | Event ID 4625 failed logon audit |
| `screenshots/09-event-viewer-4624.png` | Event ID 4624 successful logon audit |
| `screenshots/10-gpresult-report.png` | GPResult showing applied GPOs |
| `screenshots/11-domain-join-client.png` | Windows 10 client joined to domain |
| `screenshots/12-powershell-user-count.png` | PowerShell confirming 50+ users created |

---

## Security+ Domain Connections

| Action Performed | SY0-701 Domain | Concept |
|-----------------|----------------|---------|
| OU structure and RBAC groups | 2.4 Identity & Access Mgmt | Least Privilege, Role-Based Access Control |
| Password policy GPO | 4.6 Hardening | Password complexity, account lockout |
| Audit logging GPO | 4.1 Monitoring & Detection | Log management, audit trails |
| Domain architecture design | 3.1 Security Architecture | Defense-in-depth, segmentation |
| Screensaver lock policy | 4.6 Hardening | Physical security, session management |
| AppLocker/Software Restriction | 4.6 Hardening | Application whitelisting |

---

## Lessons Learned

**Least Privilege in Practice:** Creating separate OUs for each department and assigning users only to their relevant security groups demonstrated how RBAC enforces least privilege. The Help Desk group cannot access Accounting resources, and vice versa.

**GPO as a Hardening Tool:** Group Policy is one of the most powerful tools for enforcing security baselines across an entire domain. A single GPO change propagates to all domain-joined machines, making it a scalable defense-in-depth mechanism.

**Audit Logging as a Detection Layer:** Without audit logging enabled, failed login attempts would be invisible. Enabling Event ID 4625 logging is a foundational step for any SOC analyst — it feeds directly into SIEM tools like Splunk (Lab 03).

**PowerShell for Scale:** Manually creating 50 users through the GUI would take hours and introduce human error. The PowerShell script created all users in under 60 seconds with consistent naming conventions and OU placement.

---

## References

- [Microsoft: Install AD DS](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/deploy/install-active-directory-domain-services)
- [NIST SP 800-63B: Digital Identity Guidelines](https://pages.nist.gov/800-63-3/sp800-63b.html)
- [CIS Benchmark: Windows Server 2022](https://www.cisecurity.org/benchmark/microsoft_windows_server)
- [MITRE ATT&CK: T1078 Valid Accounts](https://attack.mitre.org/techniques/T1078/)
- [Reference Lab: marlopenaga/Active-Directory-Home-Lab-2024](https://github.com/marlopenaga/Active-Directory-Home-Lab-2024)
- [Reference Lab: JonCyberGuy/ActiveDirectoryLab](https://github.com/JonCyberGuy/ActiveDirectoryLab)
