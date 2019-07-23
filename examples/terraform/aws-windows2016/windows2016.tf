resource "aws_instance" "default" {
  ami                         = "${data.aws_ami.windows2016.id}"
  instance_type               = "m5.large"
  key_name                    = "${var.aws_key_pair_name}"
  subnet_id                   = "${aws_subnet.default.id}"
  vpc_security_group_ids      = ["${aws_security_group.default.id}"]
  associate_public_ip_address = true
  ebs_optimized               = true
  user_data                   = <<-EOF
<powershell>

write-output "Running User Data Script"
write-host "(host) Running User Data Script"

# set administrator password
cmd.exe /c net user Administrator ${random_string.random.result}
cmd.exe /c net user chef ${random_string.random.result} /add /LOGONPASSWORDCHG:NO
cmd.exe /c net localgroup Administrators /add chef

# RDP
cmd.exe /c netsh advfirewall firewall add rule name="Open Port 3389" dir=in action=allow protocol=TCP localport=3389
cmd.exe /c reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f

# WinRM
write-output "Setting up WinRM"
write-host "(host) setting up WinRM"

cmd.exe /c winrm quickconfig -q
cmd.exe /c winrm quickconfig '-transport:http'
cmd.exe /c winrm set "winrm/config" '@{MaxTimeoutms="1800000"}'
cmd.exe /c winrm set "winrm/config/winrs" '@{MaxMemoryPerShellMB="3072"}'
cmd.exe /c winrm set "winrm/config/service" '@{AllowUnencrypted="true"}'
cmd.exe /c winrm set "winrm/config/client" '@{AllowUnencrypted="true"}'
cmd.exe /c winrm set "winrm/config/service/auth" '@{Basic="true"}'
cmd.exe /c winrm set "winrm/config/client/auth" '@{Basic="true"}'
cmd.exe /c winrm set "winrm/config/service/auth" '@{CredSSP="true"}'
cmd.exe /c winrm set "winrm/config/listener?Address=*+Transport=HTTP" '@{Port="5985"}'
cmd.exe /c netsh advfirewall firewall set rule group="remote administration" new enable=yes
cmd.exe /c netsh firewall add portopening TCP 5985 "Port 5985"
cmd.exe /c netsh advfirewall firewall add rule name="WinRM 5985" protocol=TCP dir=in localport=5985 action=allow
cmd.exe /c netsh advfirewall firewall add rule name="WinRM 5986" protocol=TCP dir=in localport=5986 action=allow
cmd.exe /c net stop winrm
cmd.exe /c sc config winrm start= auto
cmd.exe /c net start winrm
cmd.exe /c wmic useraccount where "name='Administrator'" set PasswordExpires=FALSE
cmd.exe /c wmic useraccount where "name='chef'" set PasswordExpires=FALSE

set-executionpolicy -executionpolicy unrestricted -force -scope LocalMachine

</powershell>

  EOF

  root_block_device {
    delete_on_termination = true
    volume_size           = 100
    volume_type           = "gp2"
  }

  tags {
    Name          = "${format("${var.aws_key_pair_name}_${random_id.random.hex}_windows2016", count.index + 1)}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }


  provisioner "local-exec" {
    command = "sleep 30"
  }

  provisioner "remote-exec" {
    connection = {
      type     = "winrm"
      password = "${random_string.random.result}"
      agent    = "false"
      insecure = true
      https    = false
    }

    inline = [
      "powershell.exe Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))",
      "powershell.exe C:/ProgramData/chocolatey/choco install habitat -y",
      "powershell.exe New-NetFirewallRule -DisplayName 'Habitat TCP' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 9631,9638",
      "powershell.exe New-NetFirewallRule -DisplayName 'Habitat UDP' -Direction Inbound -Action Allow -Protocol UDP -LocalPort 9638",
    ]
  }

  provisioner "remote-exec" {
    connection = {
      type     = "winrm"
      password = "${random_string.random.result}"
      agent    = "false"
      insecure = true
      https    = false
    }
    inline = [
      "hab pkg install core/windows-service",
      "hab pkg exec core/window-service install",
      "hab license accept",
      # "hab svc load echohack/rain --channel unstable --strategy at-once"
    ]
  }
}
