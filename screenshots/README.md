# 📸 Screenshot Walkthrough

> Each screenshot documents a specific step in building this Active Directory lab. They're numbered to follow the logical order of setup.

---

## 01 — Static IP Configuration

**File:** `01-static-ip-configuration.png`

Setting the Domain Controller's static IP address via PowerShell. A DC needs a fixed, predictable address — DHCP would risk clients losing connectivity after a lease change.

Configuration:
- **IP:** `192.168.50.10/24`
- **Gateway:** (none — the internal network has no external route)
- **DNS:** `127.0.0.1` (DC serves its own DNS)

> 💡 **Why PowerShell instead of sconfig?** The `sconfig` interactive wizard wouldn't accept a blank gateway (it interprets empty input as cancel). PowerShell handles this correctly — omitting `-DefaultGateway` simply leaves it unset.

---

## 02 — Installing Active Directory Domain Services

**File:** `02-installing-active-directory.png`

Installing the AD DS role via Server Manager. This is the foundation — without AD DS, there's no domain to join, no users, no Group Policy.

---

## 03 — Promoted as Domain Controller

**File:** `03-promoted-as-domain-controller.png`

Promoting the server to a Domain Controller for a new forest root. Creating `lab.local` as the domain name with NetBIOS name `LAB`. DNS is installed alongside AD DS — Active Directory depends entirely on DNS to locate domain resources.

---

## 04 — IT Organizational Unit

**File:** `04-it-organizational-unit.png`

Created the **IT** OU to organize IT department objects. OUs serve as containers for organization and as GPO application boundaries — they don't grant access on their own.

---

## 05 — RRHH Organizational Unit

**File:** `05-rrhh-organizational-unit.png`

Created the **RRHH** (Human Resources) OU. The two-OU structure lets us apply different policies (like the USB block GPO) to different departments.

---

## 06 — PowerShell User Creation Script

**File:** `06-powershell-user-creation-script.png`

The automated user provisioning script in action. Instead of creating users one-by-one in ADUC, this PowerShell script reads from a CSV file and creates all users in batch.

Key features:
- Reads employee data from CSV — scales to any number of hires
- Prompts for a temporary password once (never written to command history)
- Error handling — one failure doesn't stop the batch
- Forces password change on first login for security

---

## 07 — Users CSV File

**File:** `07-users-csv-file.png`

The CSV file driving user creation. Structured with columns: `Username`, `Name`, `Surname`, `Title`, `Department`, `OU`. Each row maps to one AD user.

---

## 08 — Creating Security Groups

**File:** `08-creating-security-groups.png`

Created two security groups: **IT-Support** and **RRHH-Team**. Groups are separate from OUs — an OU defines where an object lives (organization + GPO scope), a group defines what it has access to.

---

## 09 — Users Added to Groups

**File:** `09-users-added-to-groups.png`

Users assigned to their respective security groups. Membership grants access to shared resources like the `RRHH-Docs` folder.

---

## 10 — Network Configuration Verification

**File:** `10-network-configuration-verification.png`

Verifying the DC's network configuration — confirming static IP, DNS settings, and connectivity. Essential troubleshooting step before promoting the server or adding clients.

---

## 11 — DNS Configuration

**File:** `11-dns-configuration.png`

DNS configuration on the Domain Controller. AD DS creates forward lookup zones automatically during promotion. DNS points to itself at `127.0.0.1` since there's no upstream DNS on this isolated network segment.

---

## 12 — Project Folder Structure

**File:** `12-project-folder-structure.png`

The organized project directory on the DC server. Keeps scripts, CSVs, and documentation in one place — mirrors real IT operations organization.

---

## 13 — Local Script Execution Permissions

**File:** `13-local-script-execution-permissions.png`

Modifying PowerShell execution policy to allow local scripts to run. By default, PowerShell blocks script execution — this must be changed to use the automation scripts.

---

## 14 — NTFS Permissions — RRHH-Docs

**File:** `14-ntfs-permissions-rrhh-docs.png`

Setting NTFS permissions on the `RRHH-Docs` folder. The RRHH-Team group gets **Modify** permissions — they can read, write, edit, and delete files, but can't change permissions or take ownership.

---

## 15 — Configuring SMB Share

**File:** `15-configuring-smb-share.png`

Creating the network share for `RRHH-Docs`. The share permissions are set to **Full Control** for RRHH-Team — this is intentionally more permissive because NTFS permissions (set to Modify) are the real enforcement layer.

> 💡 **Defense in depth:** NTFS and Share permissions are independent. The effective permission is always the *more restrictive* of the two.

---

## 16 — GPO — USB Storage Block

**File:** `16-gpo-usb-storage-block.png`

Group Policy Object that disables USB storage devices on the RRHH OU. The policy disables the `UsbStor` driver — Windows still detects the device at hardware level, but never assigns a drive letter or exposes its contents.

- **Linked to:** RRHH OU
- **Scope:** USB storage devices only (keyboards, mice unaffected)
- **CIS Control:** CIS Control 4 (Secure Configuration)
- **Business reason:** Prevent data exfiltration via removable media

---

*Built as part of the Active Directory Help Desk Lab — see the [main README](../README.md) for full context.*
