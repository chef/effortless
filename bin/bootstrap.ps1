if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
  iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

if (!(Get-Command hab -ErrorAction SilentlyContinue)) {
  choco install habitat -y
}

$local_files = "C:\Users\$($env:username)\AppData\Local\Temp\kitchen\data"

$pkg_origin=''
$pkg_name=''
$pkg_bootstrap= $null

Write-Output "Starting $pkg_origin/$pkg_name"

$latest_hart_file = Get-ChildItem $local_files -r -filter "$($pkg_origin)-$($pkg_name)*.hart" | Sort-Object -Descending | select-object -First 1 -ExpandProperty FullName

Write-Output dir $local_files

Write-Output "Install $latest_hart_file"

hab pkg install $latest_hart_file

Write-Output "Determining pkg_prefix for $latest_hart_file"

# Find latest semver and release ver folder
$pkg_prefix = Get-ChildItem "C:\hab\pkgs\$pkg_origin\$pkg_name"|
Select-Object fullname, @{n='version';e={[version]$_.name}}|
Sort-Object -Property version -Descending|
Select-Object -first 1|
ForEach-Object{Get-ChildItem $_.fullname}|
Select-Object fullname, @{n='Date';e={[int64]$_.name}}|
Sort-Object date -Descending|
Select-Object -first 1 -exp fullname

Write-Output "Found $pkg_prefix"

Write-Output "Running chef for $pkg_origin/$pkg_name"

$hello = "Hello World"
$hello | Out-File $local_files/bootstrap.json

cd $pkg_prefix
if($pkg_bootstrap) {
  hab pkg exec $pkg_origin/$pkg_name -z -j $local_files/bootstrap.json -c $pkg_prefix/config/bootstrap-config.rb
}
else {
  hab pkg exec $pkg_origin/$pkg_name chef-client -z -c $pkg_prefix/config/bootstrap-config.rb
}
