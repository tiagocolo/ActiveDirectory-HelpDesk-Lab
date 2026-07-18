<#
.SYNOPSIS
    Bulk-create Active Directory users from a CSV file.
.DESCRIPTION
    Reads employee data from users.csv and creates AD user accounts.
    Prompts for a temporary password once, applies it to all new users.
    Forces password change at first logon. Handles errors gracefully.
.PARAMETER CsvPath
    Path to the CSV file. Defaults to .\users.csv
.PARAMETER TempPassword
    Temporary password for all new users. If not provided, prompts securely.
.EXAMPLE
    .\Create-Users.ps1
    .\Create-Users.ps1 -CsvPath "C:\Lab\new-hires.csv"
.NOTES
    Author: Tiago Colo
    Requires: Active Directory module, Domain Admin privileges
#>

[CmdletBinding()]
param(
    [string]$CsvPath = ".\users.csv",
    [securestring]$TempPassword
)

# --- Ensure AD module is available ---
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Error "Active Directory module not found. Run this script on a Domain Controller."
    exit 1
}
Import-Module ActiveDirectory -Force

# --- Prompt for password if not provided ---
if (-not $TempPassword) {
    $TempPassword = Read-Host "Enter temporary password for new users" -AsSecureString
}

# --- Import CSV ---
if (-not (Test-Path $CsvPath)) {
    Write-Error "CSV file not found at: $CsvPath"
    exit 1
}

$users = Import-Csv -Path $CsvPath
Write-Host "Found $($users.Count) users to create."

# --- Create users ---
$created = 0
$errors = 0

foreach ($user in $users) {
    try {
        $userPrincipalName = "$($user.Username)@lab.local"
        $samAccountName = $user.Username
        $name = "$($user.Name) $($user.Surname)"
        $ouPath = "OU=$($user.OU),DC=lab,DC=local"

        New-ADUser -Name $name `
            -SamAccountName $samAccountName `
            -UserPrincipalName $userPrincipalName `
            -GivenName $user.Name `
            -Surname $user.Surname `
            -Title $user.Title `
            -Department $user.Department `
            -Path $ouPath `
            -AccountPassword $TempPassword `
            -Enabled $true `
            -ChangePasswordAtLogon $true `
            -PassThru

        Write-Host "  [+] Created: $name ($userPrincipalName)" -ForegroundColor Green
        $created++
    }
    catch {
        Write-Warning "  [!] Failed to create $($user.Username): $_"
        $errors++
    }
}

# --- Summary ---
Write-Host "`n--- Complete ---"
Write-Host "  Created: $created"
Write-Host "  Errors:  $errors"
if ($created -gt 0) {
    Write-Host "`nAll users created. They will be prompted to change password on first login." -ForegroundColor Yellow
}
