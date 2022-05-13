# Case Study 
## Configure Windows for Ansible Access
- Create a user & make it a member of administrator
- PowerShell 3.0 or newer required - Run powershell as administrator & verify its version by
```sh
Get-Host | Select-Object Version
```
- .NET 4.0 required - Run powershell as administrator & verify its version by
```sh
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse |
Get-ItemProperty -name Version -EA 0 |
Where { $_.PSChildName -match '^(?!S)\p{L}'} |
Select PSChildName, Version
```
- WinRM listener

## Reference links
https://docs.ansible.com/ansible/latest/user_guide/windows_setup.html