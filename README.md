# Active Directory Help Desk Lab

A hands-on AD lab I built from scratch to practice real IT Support / Help Desk workflows — domain setup, automated user onboarding, access control, and GPO hardening.

---

## Why I built this

I wanted something more solid than "I followed a YouTube tutorial" for my portfolio. So I set up a small company scenario (2 departments, 6 users) and documented every step.

**What this covers:**
- AD DS deployment and configuration
- PowerShell automation for creating users (CSV-driven)
- Security groups, OU structure, GPOs
- NTFS vs Share permissions (defense in depth)
- Static IP / DNS for Domain Controllers
- GPO for USB storage restriction
- Mapped to CIS Controls v8

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

---

## Security notes (CIS Controls)

This project maps to CIS Controls v8:

**CIS 4 — Secure Configuration:** GPO that disables USB storage on the RRHH OU. It targets the `UsbStor` driver (Start = 4), so Windows detects the device but never mounts it. Keyboards and mice still work — this is specifically about storage.

**CIS 6 — Access Control:** The RRHH-Docs share has two permission layers:
- NTFS: RRHH-Team gets Modify (read/write/edit, but no permission changes)
- Share (SMB): RRHH-Team gets Full Control

The effective permission is whichever is more restrictive (NTFS). The real ceiling is set at the NTFS level.

---

## Roadmap

- [x] Domain + DNS
- [x] OUs for IT and RRHH
- [x] Automated user creation (PowerShell + CSV)
- [x] Security groups
- [x] NTFS + Share permissions
- [x] GPO USB block
- [ ] Join a Windows client to the domain
- [ ] Simulate help desk tickets (account lockout, transfer, offboarding)
- [ ] Track those in Jira for the full workflow

The core is done.

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
└── scripts/             <- PowerShell + CSV for user provisioning
```

---

## Contact

**Tiago Colo Ceppone**  
colotiago8@gmail.com  
[linkedin.com/in/tiago-colo-640057402](https://www.linkedin.com/in/tiago-colo-640057402/)
