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
## Create inventory file and verify the connection with win_ping (Replace the IP with your Host IP Address)
```sh
ansible windows -i inventory -m win_ping
```
## Ansible playbook to Install Chocolatey, OpenSSH, Git and copy SSH public key to authorized_keys
Run the ansible playbook by:
```sh
ansible-playbook choco_ssh_windows.yml -i inventory
```
_Note : I have used ubuntu to run ansible playbook. So the win_copy src path may be different if using any other terminal._

## Create inventory_ssh for SSH connection and verify the connection with win_ping
```sh
ansible windows -i inventory_ssh -m win_ping
```
## create ansible.cfg file and add the inventory path
```sh
[defaults]
inventory = ./inventory_ssh
```
## Run ansible playbook with the automated SSH
```sh
ansible-playbook choco_ssh_windows.yml
```


## Reference links
https://docs.ansible.com/ansible/latest/user_guide/windows_setup.html
https://docs.ansible.com/ansible/latest/user_guide/windows_setup.html#configuring-ansible-for-ssh-on-windows