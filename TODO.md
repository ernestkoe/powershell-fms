# TODO
## fms
* Interactive shell to set up config

## fmdm scripts ##
fmdatamigration scripts, takes a package and upgrades it. 

     fmmigrate packagename 3.0

* it needs to store lookup table of packages,
* fetches the latest build or the build with the tagged version
* needs a path to the install location
* downloads the package files from a REST call (package repository)
* reads the package manifest for the clone file info
* migrates it
* matic package support


## Route53 (aws) Scripts
     * Updates Route53 DNS
     * RefreshR53.ps1
     * UpsertR53.ps1
     #### Requires:
     * AWS IAM user
     * Windows AWS CLI Tools