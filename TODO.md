* Add arguments for:
  * Data file
  * Company name
  * Domain Controller
  * Number of users to add
* Rework initial password setting.

Fix the following errors:


VERBOSE: Performing the operation "Set" on target "CN=Domain Users,CN=Users,DC=corp,DC=ckamps-acme,DC=com".
Add-ADGroupMember : Insufficient access rights to perform the operation
At C:\Users\Admin\workspace\samples-ad-users-groups\CreateDemoUsers.ps1:213 char:56
+ ... chnology") {Add-ADGroupMember -Identity "Domain Users" -Members $Depa ...
+                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (Domain Users:ADGroup) [Add-ADGroupMember], ADException
    + FullyQualifiedErrorId : ActiveDirectoryServer:8344,Microsoft.ActiveDirectory.Management.Commands.AddADGroupMembe
   r


VERBOSE: Performing the operation "Set" on target "CN=Goldsberry\,
James,OU=Users,OU=corp,DC=corp,DC=ckamps-acme,DC=com".
Set-ADUser : Directory object not found
At C:\Users\Admin\workspace\samples-ad-users-groups\CreateDemoUsers.ps1:233 char:85
+ ... t -eq $Department)} | Set-ADUser -Manager $DepartmentManager -Verbose
+                           ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ObjectNotFound: (CN=Goldsberry\,...mps-acme,DC=com:ADUser) [Set-ADUser], ADIdentityNotFo
   undException
    + FullyQualifiedErrorId : ActiveDirectoryCmdlet:Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException,M
   icrosoft.ActiveDirectory.Management.Commands.SetADUser