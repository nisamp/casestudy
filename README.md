# Case Study 

## Solution Overview
- Create Windows Image & VM using Packer & Vagrant/Terraform
- Configuration management using Ansible
- Provision to Azure using Terraform (Bonus 2)

## Configure Windows for Ansible Access (Manual Steps - Will automate in next step)
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
<ins>Create Windows Image using Packer</ins>

## Automate Windows Host creation using Packer & Vagrant/Terraform
- Navigate to automate_windows_host folder & run the below commands in powershell
```sh
.\packer.exe build .\windows_10_winrm.json
```
- If using vagrant
```sh
vagrant box add --name windows_10_winrm packer_virtualbox-iso_virtualbox.box
vagrant init windows_10_winrm
vagrant up
```
- If using Terraform
```sh
terraform init 
terraform validate  
terraform plan
terraform apply
```
<ins>Configuration management using Ansible</ins>

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

<ins>Provision to Azure using Packer & Terraform (Bonus 2)</ins>

- Configure Azure CLI - https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli
- Create Resource Group

```sh
az group create -n bonus2RG -l uaenorth 
```
- Get client_id, client_secret & tenant_id

```sh
az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }" 
```
- Get subscription id

```sh
az account show --query "{ subscription_id: id }"
```
- Create azure image using packer

Fill  subscription_id, client_id, client_secret & tenant_id details in windows_azurevm.json
run the below command,
```sh
.\packer.exe build .\windows_azurevm.json
```
- in main.tf fill subscription_id, client_id, client_secret & tenant_id
- run below terraform commands to provision the vm
```sh
terraform init 
terraform validate  
terraform plan
terraform apply
```
- if you want to remove the entire provisioned infrastructure then,
```sh
terraform destroy
```
## Reference links
https://docs.ansible.com/ansible/latest/user_guide/windows_setup.html
https://docs.ansible.com/ansible/latest/user_guide/windows_setup.html#configuring-ansible-for-ssh-on-windows
https://github.com/devopsjourney1/packer-windows
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
