$regPath = 'HKLM:\Software\Scripts1'
New-Item $regPath -Force
cd $regPath
New-ItemProperty 'HKLM:\Software\Scripts1' -Name "Running" -Value 00000000 -PropertyType "DWord"
New-ItemProperty 'HKLM:\Software\Scripts1' -Name "Encoding" -Value 00000000 -PropertyType "DWord"

$acl = Get-Acl "HKLM:\SOFTWARE\Scripts1"
$person = [System.Security.Principal.NTAccount]"BuiltIn\Users"          
$access = [System.Security.AccessControl.RegistryRights]"FullControl"
$inheritance = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit,ObjectInherit"
$propagation = [System.Security.AccessControl.PropagationFlags]"None"
$type = [System.Security.AccessControl.AccessControlType]"Allow"
$rule = New-Object System.Security.AccessControl.RegistryAccessRule($person,$access,$inheritance,$propagation,$type)
$acl.AddAccessRule($rule)
$acl |Set-Acl