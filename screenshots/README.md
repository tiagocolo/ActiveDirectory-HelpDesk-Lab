# Screenshot walkthrough

Each screenshot below documents one step of the lab, in order. Short descriptions explain what's happening and why.

---

## 01 — Static IP Configuration

**File:** `01-static-ip-configuration.png`

Setting the DC's static IP via PowerShell: `192.168.50.10/24`, no gateway, DNS `127.0.0.1`.

`sconfig` wouldn't accept a blank gateway field (it treats empty input as cancel). PowerShell's `New-NetIPAddress` handles it fine — you just omit `-DefaultGateway`.

---

## 02 — Installing Active Directory Domain Services

**File:** `02-installing-active-directory.png`

Installing the AD DS role from Server Manager. Nothing special here — standard Windows Feature install.

---

## 03 — Promoted as Domain Controller

**File:** `03-promoted-as-domain-controller.png`

Promoting the server to a Domain Controller for `lab.local`. DNS gets installed alongside AD DS because Active Directory won't work without it.

---

## 04 — IT Organizational Unit

**File:** `04-it-organizational-unit.png`

Created an OU for IT. OUs organize objects and define GPO scope — they don't control access by themselves.

---

## 05 — RRHH Organizational Unit

**File:** `05-rrhh-organizational-unit.png`

Same for HR. Two OUs lets me apply different policies (like the USB block GPO) per department.

---

## 06 — Users CSV File

**File:** `06-users-csv-file.png`

The CSV file with employee data: username, name, surname, title, department, OU. This feeds the PowerShell script. Adding a new user means adding a row to this file.

---

## 07 — PowerShell User Creation Script

**File:** `07-powershell-user-creation-script.png`

The script reading from the CSV and creating users. It asks for a temporary password once (never written to command history), creates each account, and forces a password change on first login. If one user fails, the script logs the error and keeps going.

---

## 08 — Script Execution Policy

**File:** `08-local-script-execution-permissions.png`

PowerShell blocks local scripts by default. Had to change the execution policy to allow my automation script to run.

---

## 09 — Creating Security Groups

**File:** `09-creating-security-groups.png`

Created `IT-Support` and `RRHH-Team` groups. Groups control access to resources; OUs organize objects — they solve different problems.

---

## 10 — Users Added to Groups

**File:** `10-users-added-to-groups.png`

Users assigned to their respective groups. Being in RRHH-Team grants access to the RRHH-Docs folder.

---

## 11 — DNS Configuration

**File:** `11-dns-configuration.png`

DNS on the DC. AD DS creates forward lookup zones automatically. The DC points to itself at `127.0.0.1` since there's no upstream DNS on this network.

---

## 12 — NTFS Permissions — RRHH-Docs

**File:** `12-ntfs-permissions-rrhh-docs.png`

Setting NTFS permissions on the RRHH-Docs folder. RRHH-Team gets Modify — they can read, write, edit, and delete, but can't change permissions or take ownership.

---

## 13 — Configuring SMB Share

**File:** `13-configuring-smb-share.png`

Creating the network share. Share permissions = Full Control, NTFS = Modify. NTFS is the real enforcement layer — the effective permission is always the more restrictive of the two.

---

## 14 — GPO — USB Storage Block

**File:** `14-gpo-usb-storage-block.png`

GPO that disables USB storage on the RRHH OU. It works by disabling the `UsbStor` driver (registry Start value = 4). The system still detects the device at the hardware level but never assigns a drive letter. Other USB devices (keyboard, mouse) are unaffected. This maps to CIS Control 4.

---

Back to the [main README](../README.md).
