# Case Study 
## Configure Windows for Ansible Access
- Create a user & make it a member of administrator (ansible user)
- PowerShell 3.0 or newer required - Run powershell as administrator & verify its version by:
```sh
Get-Host | Select-Object Version
```
- .NET 4.0 required - Run powershell as administrator & verify its version by:
```sh
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse |
Get-ItemProperty -name Version -EA 0 |
Where { $_.PSChildName -match '^(?!S)\p{L}'} |
Select PSChildName, Version
```
- WinRM Setup -  Run powershell as administrator execute the below command:
```sh
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
$file = "$env:temp\ConfigureRemotingForAnsible.ps1"

(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)

powershell.exe -ExecutionPolicy ByPass -File $file
```
- WinRM Listener - To check current listeners running on WinRM service, execute the below command:
```sh
winrm enumerate winrm/config/Listener
```

## Install Chocolatey Windows Package Manager using Ansible
Run the ansible playbook by:
```sh
ansible-playbook chocolatey.yml
```

## Install Git using Chocolatey
Run the ansible playbook by:
```sh
ansible-playbook chocolatey_git.yml
```
## Reference links
https://docs.ansible.com/ansible/latest/user_guide/windows_setup.html