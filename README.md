#  Create Sample Active Directory Users and Groups

This script and sample data set can be used to quickly provision a set of sample users and AD security groups in an Active Directory of your choosing.  The script has been primarily tested against instances of the [AWS Managed Microsoft AD](https://docs.aws.amazon.com/directoryservice/latest/admin-guide/directory_microsoft_ad.html) service, but should also work with self-managed AD instances albeit potentially with minor tweaks.

## Pre-Requisites

...

## Usage

...

## Contributing Changes

See the TODO.md list for a set of known outstanding gaps.

## References

The code that provided inspiration and a basis for this script and sample data came from:

https://gallery.technet.microsoft.com/scriptcenter/Create-UsersGroup-for-9ee1de26

If a GitHub repository for this code had been available and the repository was being actively maintained, an effort to contribute to the source would have been made.

Key enhancements and changes from the original code and sample data include:

Sample Data
* Removed unused password column.
* Added employee ID column with unique sample fields so that more realistict user IDs could be created.

Code
* Removed all unused code.
* Removed superflouous output of Windows environment data.
* Reworked initial password setting so that now a dynamically generated random initial password is used for each sample user and the password for each user is displayed to stdout so that you can capture the initial values.
* Removed transcript logging and instead simply depend on stdout/stderr output so that initial passwords are not persisted.
* Reworked OU processing so that the parent OU is taken from the domain's NetBIOS name. (This aspect likely warrants further enhancements and flexibility in cases where multiple top-level OUs may exist in a domain).
* Reworked auto deletion of previously configured resources at the start of the script so that the script can be run again and again without failure.
** All users within the top level OU of interest are deleted at the start of the script except for "admin" users. The "admin" user is provisioned by the AWS Managed Microsoft AD service and should not be removed.
** All AD security groups within the top level OU of interest are automatically deleted at the start of the script prior to the groups being repopulated.
* SAMAccountName is now of the format:
```
e<left padded with 0s employeed ID>
```
* UserPrincipalName is now of the format:
```
<first name>.<last name>@<domain name>
```
* A new "Remote Desktop" AD security group is added and includes all sample users.
* Code to auto populate "Domain Admins" and "Domain Users" with sample users was removed given that this access is not provided when using the AWS Managed Microsoft AD service.
* Code to automatically configure the basis of a Group Policy Object (GPO) to automatically enable remote desktop access for all sample users was added, but commented out until it is determined if this automation is feasible when using a domain managed by the AWS Managed Microsoft AD service.