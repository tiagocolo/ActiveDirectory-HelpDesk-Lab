# 📸 Screenshot Walkthrough

> Each screenshot documents a specific step in building this Active Directory lab, in logical order.

---

## 01 — Static IP Configuration

**File:** `01-static-ip-configuration.png`

Setting the Domain Controller's static IP via PowerShell. A DC needs a fixed address — DHCP risks clients losing connectivity after a lease change.

Configuration: `192.168.50.10/24`, no gateway (isolated network), DNS `127.0.0.1`.

> 💡 `sconfig` wouldn't accept a blank gateway (interprets empty as cancel). PowerShell handles it correctly via `New-NetIPAddress`.

---

## 02 — Installing Active Directory Domain Services

**File:** `02-installing-active-directory.png`

Installing the AD DS role via Server Manager — the foundation for domain, users, and Group Policy.

---

## 03 — Promoted as Domain Controller

**File:** `03-promoted-as-domain-controller.png`

Promoting to DC for forest root `lab.local`. DNS installed alongside AD DS.

---

## 04 — IT Organizational Unit

**File:** `04-it-organizational-unit.png`

Created **IT** OU to organize department objects. OUs = organization + GPO scope (not access control).

---

## 05 — RRHH Organizational Unit

**File:** `05-rrhh-organizational-unit.png`

Created **RRHH** OU. Two-OU structure enables per-department policies (like the USB block GPO).

---

## 06 — Users CSV File

**File:** `06-users-csv-file.png`

The CSV driving automated user creation. Columns: `Username`, `Name`, `Surname`, `Title`, `Department`, `OU`. Each row = one AD user. This file feeds the PowerShell script.

---

## 07 — PowerShell User Creation Script

**File:** `07-powershell-user-creation-script.png`

Bulk user provisioning in action. Reads from the CSV, prompts for a temp password once, forces password change on first login. Error handling prevents one failure from stopping the batch.

---

## 08 — Script Execution Policy

**File:** `08-local-script-execution-permissions.png`

Modified PowerShell execution policy to allow local scripts. By default PowerShell blocks script execution — must be changed to run automation scripts.

---

## 09 — Creating Security Groups

**File:** `09-creating-security-groups.png`

Created `IT-Support` and `RRHH-Team` security groups. Groups grant access; OUs organize. Different concepts, kept independent.

---

## 10 — Users Added to Groups

**File:** `10-users-added-to-groups.png`

Users assigned to their respective security groups. Membership grants access to resources like `RRHH-Docs`.

---

## 11 — DNS Configuration

**File:** `11-dns-configuration.png`

DNS config on the DC. AD DS creates forward lookup zones automatically during promotion. DC points to itself (`127.0.0.1`).

---

## 12 — NTFS Permissions — RRHH-Docs

**File:** `12-ntfs-permissions-rrhh-docs.png`

Setting NTFS Modify permissions for RRHH-Team on the `RRHH-Docs` folder. Read, write, edit, delete — but not permission changes or ownership.

---

## 13 — Configuring SMB Share

**File:** `13-configuring-smb-share.png`

Network share for `RRHH-Docs`. Share = Full Control, NTFS = Modify. The effective permission is the *more restrictive* of the two (NTFS wins).

> 💡 **Defense in depth:** Two independent permission layers. NTFS is the real ceiling.

---

## 14 — GPO — USB Storage Block

**File:** `14-gpo-usb-storage-block.png`

GPO disabling USB storage on the RRHH OU. Disables the `UsbStor` driver — device detected at hardware level but never assigned a drive letter. Aligned to CIS Control 4.

---

*Built as part of the [Active Directory Help Desk Lab](../README.md).*
