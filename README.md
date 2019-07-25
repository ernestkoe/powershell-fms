# README #

## FileMaker Server Powershell Tools by Proof ##

This is a collection of Windows Powershell scripts to make FIleMaker Server devops a little less painful.

### SaveFMSCredentials ###

Saves filemaker credentials to an encrypted credentials store file in the FileMaker cstore folder (or whichever is specified) so that ImportFMS-SSL knows where to look for it.

### InstallSSL ###
  
Imports letsencrypt certificates into FileMaker Server

### UpdateRoute53 ###

Updates Route53 DNS

## Requirements ##

* set up an AWS IAM user
* download Windows AWS Tools
* download Windows AWS CLI Tools
  
## Configuration ##
