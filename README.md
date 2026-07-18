# Active Directory Help Desk Lab

A hands-on AD lab I built from scratch to practice real IT Support / Help Desk workflows — domain setup, automated user onboarding, access control, GPO hardening, and one very memorable incident where I accidentally deleted my own admin account.

---

## Why I built this

I wanted something more solid than "I followed a YouTube tutorial" for my portfolio. So I set up a small company scenario (2 departments, 6 users) and documented everything — including the mistakes. The README you're reading IS the documentation I wrote as I went, not something I polished after the fact.

**What this covers:**
- AD DS deployment and configuration
- PowerShell automation for creating users (CSV-driven)
- Security groups, OU structure, GPOs
- NTFS vs Share permissions (defense in depth)
- Static IP / DNS for Domain Controllers
- GPO for USB storage restriction
- Incident response (yes, I broke things)
- All mapped to CIS Controls v8

---

## Setup

**Host:** Windows Server 2025 Standard (Evaluation) on VirtualBox  
**Network:** Dual adapter — NAT for internet, Internal Network (`adlab`, 192.168.50.0/24) for domain traffic  
**DC static IP:** `192.168.50.10/24`, no gateway (isolated segment), DNS `127.0.0.1`

> The dual network setup keeps lab traffic off my host's real network. If I misconfigure something, it stays inside the VM.

**One annoying thing:** `sconfig` wouldn't let me set a static IP without a gateway (it sees blank input as "cancel"). Fixed it via PowerShell with `New-NetIPAddress` — much cleaner.

---

## What I did (with screenshots)

Each step has a screenshot in [`screenshots/`](./screenshots/) with a short explanation.

| # | Step |
|---|------|
| 01 | **Static IP** — Set 192.168.50.10/24, DNS 127.0.0.1 via PowerShell |
| 02 | **Installing AD DS** — Role installation in Server Manager |
| 03 | **Promoted to DC** — New forest root for `lab.local` |
| 04 | **IT OU** — Created OU for IT department |
| 05 | **RRHH OU** — Created OU for HR |
| 06 | **Users CSV** — Employee data file that feeds the automation |
| 07 | **PowerShell user creation** — Script running, creating users in batch |
| 08 | **Script execution policy** — Had to allow local PS scripts |
| 09 | **Security groups** — Created IT-Support and RRHH-Team |
| 10 | **Users added to groups** — Membership assigned |
| 11 | **DNS config** — Forward/reverse lookup zones |
| 12 | **NTFS permissions** — Modify for RRHH-Team on RRHH-Docs |
| 13 | **SMB share** — Network share with access controls |
| 14 | **GPO USB block** — Policy disabling storage on RRHH OU |

Screenshots in order: [`screenshots/README.md`](./screenshots/README.md)

---

## Security notes (CIS Controls)

I mapped this to CIS Controls v8 to make it relevant for real jobs:

**CIS 4 — Secure Configuration:** GPO that disables USB storage on the RRHH OU. It targets the `UsbStor` driver (Start = 4), so Windows detects the device but never mounts it. Keyboards and mice still work — this is specifically about storage.

**CIS 6 — Access Control:** The RRHH-Docs share has two permission layers:
- NTFS: RRHH-Team gets Modify (read/write/edit, but no permission changes)
- Share (SMB): RRHH-Team gets Full Control

The effective permission is whichever is more restrictive (NTFS). This is intentional — you set the real ceiling at NTFS level and leave the share wide open.

**CIS 8 — Incident Response:** See below.

---

## The incident (I deleted my own admin account)

While cleaning up test users, I ran a filter to find users with a `Title` field set. My own domain account also had a Title. The delete command removed me — while I was logged in.

**What happened:** The active session stayed alive (Windows doesn't re-check on every command), but `Get-ADUser` could no longer find my account. The built-in Administrator was still there because it can't be removed from Domain Admins.

**How I fixed it:** Logged in as Administrator, recreated my account, re-added it to Domain Admins, and tested before closing the session.

**Lesson learned:** Never run a bulk delete with a broad filter. Use an explicit allow-list or at minimum run `-WhatIf` first. I got lucky because the built-in Administrator was available — in a real environment this could have been a very bad day.

I wrote the full timeline in the [screenshots README](./screenshots/README.md#-incident-report-accidental-loss-of-domain-admin-access) because it's worth remembering.

---

## What's missing (roadmap)

The VM broke before I could finish the last items:

- [x] Domain + DNS
- [x] OUs for IT and RRHH
- [x] Automated user creation (PowerShell + CSV)
- [x] Security groups
- [x] NTFS + Share permissions
- [x] GPO USB block
- [x] Incident documented
- [ ] Join a Windows client to the domain (was next)
- [ ] Simulate help desk tickets (account lockout, transfer, offboarding)
- [ ] Track those in Jira for the full workflow

The core is done. The rest is polish.

---

## How to run this yourself

1. Install VirtualBox, create a VM with Windows Server 2025 (Evaluation)
2. Two network adapters: NAT + Internal Network (`adlab`)
3. Set static IP:
   ```powershell
   New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.50.10 -PrefixLength 24
   Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 127.0.0.1
   ```
4. Install AD DS and promote:
   ```powershell
   Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
   Install-ADDSForest -DomainName "lab.local"
   ```
5. Run [`scripts/Create-Users.ps1`](./scripts/Create-Users.ps1) with [`users.csv`](./scripts/users.csv)
6. Set up groups, permissions, and GPO as shown in the screenshots

---

## Repo structure

```
ActiveDirectory-HelpDesk-Lab/
├── README.md
├── screenshots/         <- Step-by-step screenshots with descriptions
├── network-diagrams/    <- Network topology visuals
├── scripts/             <- PowerShell + CSV for user provisioning
└── .gitignore
```

---

## Contact

**Tiago Colo Ceppone**  
colotiago8@gmail.com  
[linkedin.com/in/tiago-colo](https://linkedin.com/in/tiago-colo)  

Built for learning, not for show. If something's wrong or could be better, I'd genuinely like to know.
