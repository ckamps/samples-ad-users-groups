# %ForceElevation% = Yes
#Requires -RunAsAdministrator

[CmdletBinding()]
    Param
    (        	
        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Test-Connection -ComputerName "$_" -Count 4 -Quiet) -and (Test-WSMAN -ComputerName "$_")})]	
        #[String]$Server = "$($Env:Computername).$($Env:UserDnsDomain.ToLower())"
        # Need to make Server an optional argument.
        [String]$Server = "10.0.3.70"
    )

    Clear-Host
  
    $UserCount = 20 #Up to 2500 can be created
    $Company = "ACME Incorporated" 

    $ScriptDir = ($MyInvocation.MyCommand.Definition | Split-Path -Parent | Out-String).TrimEnd("\").Trim()
    $Content = Import-CSV -Path "$($ScriptDir)\sample-users.csv" -ErrorAction Stop | Get-Random -Count $UserCount | Sort-Object -Property State
   
    Import-Module -Name 'ActiveDirectory' -Force -NoClobber -ErrorAction Stop
    Add-Type -AssemblyName System.web

    $Domain = Get-ADDomain -Server $Server
    $DomainDN = $Domain.DistinguishedName
    $Forest = $Domain.Forest
    $ParentOUName = $Domain.NetBiosName

    Write-Host ""
    Write-Host "Domain = $($Domain)" -BackgroundColor Black -ForegroundColor Cyan
    Write-Host "DomainDN = $($DomainDN)" -BackgroundColor Black -ForegroundColor Cyan
    Write-Host "Forest = $($Forest)" -BackgroundColor Black -ForegroundColor Cyan
    Write-Host "ParentOUName = $($ParentOUName)" -BackgroundColor Black -ForegroundColor Cyan

    $ParentOU = Get-ADOrganizationalUnit -Filter "Name -eq `"$ParentOUName`"" -Server $Server

    $UserOU = Get-ADOrganizationalUnit -Filter "Name -eq `"Users`"" -SearchBase $ParentOU.DistinguishedName -Server $Server

    If ((Get-ADOrganizationalUnit -Filter "Name -eq `"Groups`"" -SearchBase $ParentOU.DistinguishedName -Server $Server -ErrorAction SilentlyContinue))
    {
        Get-ADOrganizationalUnit -Filter "Name -eq `"Groups`"" -SearchBase $ParentOU.DistinguishedName -Server $Server | Set-ADObject -ProtectedFromAccidentalDeletion:$False -Server $Server -PassThru | Remove-ADOrganizationalUnit -Confirm:$False -Server $Server -Recursive -Verbose
        Write-Host ""
    }
    $GroupOU = New-ADOrganizationalUnit -Name "Groups" -Path $ParentOU.DistinguishedName -Verbose -PassThru -Server $Server -ErrorAction Stop

    If ((Get-ADOrganizationalUnit -Filter "Name -eq `"Users`"" -SearchBase $ParentOU.DistinguishedName -Server $Server -ErrorAction SilentlyContinue))
    {
        Write-Host "Users OU already exists"
        $deletes= Get-ADUser -Filter {Name -notlike 'Admin'} -SearchBase $UserOU.DistinguishedName -properties SamAccountName
        foreach ($delete in $deletes) 
        {
            echo "Deleting user account $delete . . . " 
            Remove-ADUser -identity $delete.SamAccountName -confirm:$false 
        }
        Write-Host ""
    }

    #If ((Get-GPO -Name "RemoteDesktop" -Server $Server -ErrorAction SilentlyContinue))
    #{
    #    Remove-GPO -Name "RemoteDesktop" -Server $Server
    #    Write-Host ""
    #}
    #$RemoteDesktopGPO = New-GPO -Name "RemoteDesktop" -Verbose -Domain $Forest -Server $Server -ErrorAction Stop | New-GPLink -Target $ParentOU.DistinguishedName -Verbose -Server $Server -ErrorAction Stop 
     
    $Departments =  (
        @{"Name" = "Accounting"; Positions = ("Manager", "Accountant", "Data Entry")},
        @{"Name" = "Human Resources"; Positions = ("Manager", "Administrator", "Officer", "Coordinator")},
        @{"Name" = "Sales"; Positions = ("Manager", "Representative", "Consultant", "Senior Vice President")},
        @{"Name" = "Marketing"; Positions = ("Manager", "Coordinator", "Assistant", "Specialist")},
        @{"Name" = "Engineering"; Positions = ("Manager", "Engineer", "Scientist")},
        @{"Name" = "Consulting"; Positions = ("Manager", "Consultant")},
        @{"Name" = "Information Technology"; Positions = ("Manager", "Engineer", "Technician")},
        @{"Name" = "Planning"; Positions = ("Manager", "Engineer")},
        @{"Name" = "Contracts"; Positions = ("Manager", "Coordinator", "Clerk")},
        @{"Name" = "Purchasing"; Positions = ("Manager", "Coordinator", "Clerk", "Purchaser", "Senior Vice President")}
    )
    
    $Users = $Content | Select-Object `
        @{Name="Name"; Expression={"$($_.Surname), $($_.GivenName)"}},`
        @{Name="Description"; Expression={"User account for $($_.GivenName) $($_.MiddleInitial). $($_.Surname)"}},`
        @{Name="SamAccountName"; Expression={"e$($_.EmployeeID.PadLeft(6,'0'))"}},`
        @{Name="UserPrincipalName"; Expression={"$($_.GivenName.ToLower()).$($_.Surname.ToLower())@$($Forest.substring($ParentOUName.Length+1))"}},`
        @{Name="GivenName"; Expression={$_.GivenName}},`
        @{Name="Initials"; Expression={$_.MiddleInitial}},`
        @{Name="Surname"; Expression={$_.Surname}},`
        @{Name="DisplayName"; Expression={"$($_.GivenName) $($_.MiddleInitial). $($_.Surname)"}},`
        @{Name="City"; Expression={$_.City}},`
        @{Name="StreetAddress"; Expression={$_.StreetAddress}},`
        @{Name="State"; Expression={$_.State}},`
        @{Name="Country"; Expression={$_.Country}},`
        @{Name="PostalCode"; Expression={$_.ZipCode}},`
        @{Name="EmailAddress"; Expression={"$($_.GivenName.ToLower()).$($_.Surname.ToLower())@$($Forest.substring($ParentOUName.Length+1))"}},`
        @{Name="AccountPassword"; Expression={$PlainTextPassword = [System.Web.Security.Membership]::GeneratePassword(18,3); ConvertTo-SecureString $PlainTextPassword -AsPlainText -Force; Write-Host "Initial password: $($PlainTextPassword) - $($_.Surname), $($_.GivenName) "}},`
        @{Name="OfficePhone"; Expression={$_.TelephoneNumber}},`
        @{Name="Company"; Expression={$Company}},`
        @{Name="Department"; Expression={$Departments[(Get-Random -Maximum $Departments.Count)].Item("Name") | Get-Random -Count 1}},`
        @{Name="Title"; Expression={$Departments[(Get-Random -Maximum $Departments.Count)].Item("Positions") | Get-Random -Count 1}},`
        @{Name="EmployeeID"; Expression={$_.EmployeeID}},`
        @{Name="BirthDate"; Expression={$_.Birthday}},`
        @{Name="Gender"; Expression={"$($_.Gender.SubString(0,1).ToUpper())$($_.Gender.Substring(1).ToLower())"}},`
        @{Name="Enabled"; Expression={$True}},`
        @{Name="PasswordNeverExpires"; Expression={$True}}

    New-ADGroup -Name "Remote Desktop" -SamAccountName "Remote Desktop" -GroupCategory Security -GroupScope Global -Path $GroupOU.DistinguishedName -Description "Remote desktop users" -Verbose -Server $Server -PassThru

    ForEach ($Department In $Departments.Name)
    {
        $CreateADGroup = New-ADGroup -Name "$Department" -SamAccountName "$Department" -GroupCategory Security -GroupScope Global -Path $GroupOU.DistinguishedName -Description "Security Group for all $Department users" -Verbose -OtherAttributes @{"Mail"="$($Department.Replace(' ',''))@$($Forest)"} -Server $Server -PassThru
        # If ($Department -eq "Information Technology") {Add-ADGroupMember -Identity "Domain Admins" -Members $Department -Verbose -Server $Server}
    }

    Write-Host ""
    
    ForEach ($User In $Users)
    {
        $DestinationOU =  Get-ADOrganizationalUnit -Filter "Name -eq `"Users`"" -SearchBase $DomainDN -Server $Server
    
        $CreateADUser = $User | Select-Object -Property @{Name="Path"; Expression={$DestinationOU.DistinguishedName}}, * | New-ADUser -Verbose -Server $Server -PassThru
            
        $AddADUserToGroup = Add-ADGroupMember -Identity $User.Department -Members $User.SamAccountName -Server $Server -Verbose
    
        Add-ADGroupMember -Identity "Remote Desktop" -Members $User.SamAccountName -Server $Server -Verbose

        Write-Host ""
    }
            
    ForEach ($Department In $Departments.Name)
    {
        $DepartmentManager = Get-ADUser -Filter {(Title -eq "Manager") -and (Department -eq $Department)} -Server $Server | Sort-Object | Select-Object -First 1
        $SetDepartmentManager = Get-ADUser -Filter {(Department -eq $Department)} | Set-ADUser -Manager $DepartmentManager -Verbose
    }

    Write-Host ""