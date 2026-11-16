#Requires -RunAsAdministrator
#Requires -PSEdition Desktop
<#
  Windows 11 debloat: kurangi RAM idle tanpa mematikan keamanan.
  Cara pakai: klik dua kali run.cmd, atau dari Terminal (Admin):
    powershell -ExecutionPolicy Bypass -File .\debloat.ps1

  Tidak disentuh: Defender, Firewall, Windows Update, SmartScreen, Memory Integrity, UAC,
  Xbox app, Game Bar, Gaming Services, Microsoft Store, App Installer, driver, Windows Search.
  File ini sengaja ASCII saja: Windows PowerShell 5.1 salah membaca UTF-8 tanpa BOM.
#>

function Set-Dword($Path, $Name, $Value) {
    if (-not (Test-Path $Path)) { New-Item $Path -Force | Out-Null }
    New-ItemProperty $Path -Name $Name -Value $Value -PropertyType DWord -Force | Out-Null
}

function Invoke-Debloat {
    # 1. Restore point dulu. Kalau gagal, tidak ada yang diubah.
    Set-Dword 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore' SystemRestorePointCreationFrequency 0  # buka batas 1 restore point per 24 jam
    try {
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction Stop
        Checkpoint-Computer -Description 'Before debloat' -RestorePointType MODIFY_SETTINGS -ErrorAction Stop
    } catch {
        Write-Warning "Restore point gagal dibuat, tidak ada yang diubah. $_"
        return
    }

    # 2. Hapus aplikasi. [RAM] = jalan di background; sisanya hanya menghemat penyimpanan.
    $apps = @(
        'Microsoft.Copilot'                       # [RAM] Copilot
        'Microsoft.MicrosoftOfficeHub'            # [RAM] Microsoft 365 Copilot app
        'MSTeams'                                 # [RAM] Teams (personal)
        'Microsoft.YourPhone'                     # [RAM] Phone Link
        'MicrosoftWindows.CrossDevice'            # [RAM] Cross Device Experience Host
        'MicrosoftWindows.Client.WebExperience'   # [RAM] Widgets (policy key-nya diblokir untuk script)
        'Microsoft.OutlookForWindows'
        'Microsoft.BingNews'
        'Microsoft.BingWeather'
        'Microsoft.BingSearch'
        'Microsoft.GetHelp'
        'Microsoft.Getstarted'                    # Tips
        'Microsoft.WindowsFeedbackHub'
        'Microsoft.MicrosoftSolitaireCollection'
        'Microsoft.PowerAutomateDesktop'
        'Microsoft.Todos'
        'Microsoft.Windows.DevHome'
        'MicrosoftCorporationII.MicrosoftFamily'
        'MicrosoftCorporationII.QuickAssist'
        'Clipchamp.Clipchamp'
    )
    $provisioned = Get-AppxProvisionedPackage -Online
    foreach ($app in $apps) {
        Write-Host "Menghapus $app"
        Get-AppxPackage -AllUsers -Name $app | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
        $provisioned | Where-Object DisplayName -eq $app |
            Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null  # supaya tidak muncul lagi untuk user baru
    }

    # 3. Matikan proses background.
    # Policy Edge membuat Edge menampilkan "managed by your organisation". Tidak berbahaya.
    Set-Dword 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' StartupBoostEnabled 0    # Edge preload saat login
    Set-Dword 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' BackgroundModeEnabled 0  # Edge tetap jalan setelah ditutup
    Remove-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name OneDrive -ErrorAction SilentlyContinue  # autostart OneDrive
    Stop-Service DiagTrack -Force -ErrorAction SilentlyContinue                 # layanan telemetri
    Set-Service DiagTrack -StartupType Disabled

    Write-Host "`nSelesai. Restart, lalu pilih menu 2 untuk cek RAM." -ForegroundColor Green
}

function Show-Memory {
    $totalGB = (Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize / 1MB          # KB ke GB
    $availGB = (Get-CimInstance Win32_PerfFormattedData_PerfOS_Memory).AvailableMBytes / 1KB # MB ke GB
    Write-Host ('{0:N1} GB dipakai dari {1:N1} GB (kira-kira angka "In use" di Task Manager)' -f ($totalGB - $availGB), $totalGB)
    Get-Process | Group-Object Name |
        Select-Object Name, @{ n = 'MB'; e = { [int](($_.Group | Measure-Object WorkingSet64 -Sum).Sum / 1MB) } } |
        Sort-Object MB -Descending | Select-Object -First 15 | Format-Table -AutoSize | Out-Host
}

$svchostKey = 'HKLM:\SYSTEM\CurrentControlSet\Control'
while ($true) {
    Write-Host @'

  Windows 11 debloat
  [1] Debloat (aman diulang)
  [2] Cek pemakaian RAM
  [3] Opsional: gabungkan proses svchost
  [4] Batalkan langkah 3
  [0] Keluar
'@
    switch (Read-Host 'Pilih') {
        '1' { Invoke-Debloat }
        '2' { Show-Memory }
        '3' {
            # Ambang di atas RAM mana pun, jadi layanan digabung seperti di PC RAM kecil.
            # Risiko: kalau satu layanan crash, layanan lain di grupnya ikut berhenti.
            Set-ItemProperty $svchostKey SvcHostSplitThresholdInKB 0x7FFFFFFF -Type DWord
            Write-Host 'Selesai. Restart supaya berlaku.' -ForegroundColor Green
        }
        '4' {
            Set-ItemProperty $svchostKey SvcHostSplitThresholdInKB 3670016 -Type DWord  # bawaan Windows: 3,5 GB
            Write-Host 'Dikembalikan ke bawaan. Restart supaya berlaku.' -ForegroundColor Green
        }
        '0' { return }
    }
}
