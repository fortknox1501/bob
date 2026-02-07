Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Main GUI ---
$f = New-Object System.Windows.Forms.Form
$f.Width = 320
$f.Height = 180
$f.StartPosition = 'CenterScreen'
$f.BackColor = [System.Drawing.Color]::Black
$f.FormBorderStyle = 'FixedDialog'
$f.ControlBox = $false

$label = New-Object System.Windows.Forms.Label
$label.Text = 'youve been hecked'
$label.AutoSize = $true
$label.ForeColor = [System.Drawing.Color]::Red
$label.Left = 80
$label.Top = 30
$f.Controls.Add($label)

$b = New-Object System.Windows.Forms.Button
$b.Text = 'sure ill give you my pc'
$b.Width = 180
$b.Height = 30
$b.Left = 60
$b.Top = 80
$b.BackColor = [System.Drawing.Color]::DarkRed
$b.ForeColor = [System.Drawing.Color]::White
$f.Controls.Add($b)

# --- Timer GUI ---
$b.Add_Click({
    $f.Hide()

    $t = New-Object System.Windows.Forms.Form
    $t.Width = 400
    $t.Height = 220
    $t.BackColor = [System.Drawing.Color]::Red
    $t.TopMost = $true
    $t.FormBorderStyle = 'FixedSingle'
    $t.ControlBox = $false
    $t.StartPosition = 'Manual'

    $screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
    $t.Left = $screen.Right - $t.Width
    $t.Top = 0

    $t.add_FormClosing({ $e.Cancel = $true })

    # Title
    $title = New-Object System.Windows.Forms.Label
    $title.Text = "time until your computer`ngets hecked by hecker"
    $title.Font = New-Object System.Drawing.Font('Arial',14,[System.Drawing.FontStyle]::Bold)
    $title.ForeColor = [System.Drawing.Color]::White
    $title.AutoSize = $true
    $title.MaximumSize = New-Object System.Drawing.Size($t.Width - 20, 0)
    $title.Top = 10
    $title.Left = 20
    $t.Controls.Add($title)

    # Timer labels
    $minLabel = New-Object System.Windows.Forms.Label
    $minLabel.Font = New-Object System.Drawing.Font('Consolas',50,[System.Drawing.FontStyle]::Bold)
    $minLabel.ForeColor = [System.Drawing.Color]::White
    $minLabel.AutoSize = $true
    $t.Controls.Add($minLabel)

    $colonLabel = New-Object System.Windows.Forms.Label
    $colonLabel.Font = New-Object System.Drawing.Font('Consolas',50,[System.Drawing.FontStyle]::Bold)
    $colonLabel.ForeColor = [System.Drawing.Color]::White
    $colonLabel.AutoSize = $true
    $t.Controls.Add($colonLabel)

    $secLabel = New-Object System.Windows.Forms.Label
    $secLabel.Font = New-Object System.Drawing.Font('Consolas',50,[System.Drawing.FontStyle]::Bold)
    $secLabel.ForeColor = [System.Drawing.Color]::White
    $secLabel.AutoSize = $true
    $t.Controls.Add($secLabel)

    # Fake deletion bar
    $pbLabel = New-Object System.Windows.Forms.Label
    $pbLabel.Text = "Deleting system files..."
    $pbLabel.ForeColor = [System.Drawing.Color]::White
    $pbLabel.Top = 130
    $pbLabel.Left = 20
    $t.Controls.Add($pbLabel)

    $pb = New-Object System.Windows.Forms.ProgressBar
    $pb.Width = 350
    $pb.Height = 20
    $pb.Top = 155
    $pb.Left = 20
    $pb.Maximum = 100
    $t.Controls.Add($pb)

    # Notification spam
    $notify = New-Object System.Windows.Forms.NotifyIcon
    $notify.Icon = [System.Drawing.SystemIcons]::Error
    $notify.Visible = $true

    $messages = @(
        "im in your pc",
        "deleting system32",
        "this is your last chance",
        "why is there a siren",
        "lol"
    )

    $spamTimer = New-Object System.Windows.Forms.Timer
    $spamTimer.Interval = 1000
    $spamTimer.Add_Tick({
        $notify.BalloonTipTitle = "from hecker"
        $notify.BalloonTipText = $messages | Get-Random
        $notify.ShowBalloonTip(1000)
    })
    $spamTimer.Start()

    # --- Mouse jitter ---
    $mouseTimer = New-Object System.Windows.Forms.Timer
    $mouseTimer.Interval = 50
    $mouseTimer.Add_Tick({
        $pos = [System.Windows.Forms.Cursor]::Position
        $dx = Get-Random -Minimum -10 -Maximum 10
        $dy = Get-Random -Minimum -10 -Maximum 10
        [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point(
            $pos.X + $dx,
            $pos.Y + $dy
        )
    })
    $mouseTimer.Start()

    # --- WEE WOO SIREN ---
Start-Job -ScriptBlock {
    while ($true) {
        [console]::beep(1000,200)  # WEE
        [console]::beep(600,200)   # WOO
    }
}


    # Countdown
    $script:totalSec = 300
    $script:sec = 300

    function Update-Time {
        $m = [math]::Floor($script:sec / 60)
        $s = $script:sec % 60
        $minLabel.Text = $m
        $colonLabel.Text = ':'
        $secLabel.Text = ('{0:00}' -f $s)

        $totalWidth = $minLabel.PreferredWidth + $colonLabel.PreferredWidth + $secLabel.PreferredWidth
        $minLabel.Left = ($t.Width - $totalWidth) / 2
        $colonLabel.Left = $minLabel.Left + $minLabel.PreferredWidth
        $secLabel.Left = $colonLabel.Left + $colonLabel.PreferredWidth

        $minLabel.Top = 60
        $colonLabel.Top = 60
        $secLabel.Top = 60

        # Progress synced to timer
        $progress = (($script:totalSec - $script:sec) / $script:totalSec) * 100
        $pb.Value = [int]$progress
    }

    Update-Time

    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 1000
    $timer.Add_Tick({
        $script:sec--
        Update-Time
        if ($script:sec -le 0) {
            $script:sec = $script:totalSec  # loop forever
        }
    })
    $timer.Start()

    $t.ShowDialog()
})

$f.ShowDialog()
