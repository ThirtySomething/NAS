#!/bin/bash
echo "------------------------------------------------------------"
echo "`date +'%Y%m%d-%H:%M:%S'`: Check for SynoFinder"
# 1st: Check if 'Universal Search' is installed
if synoservice --list-config | grep -Fq 'pkgctl-SynoFinder'; then    
	echo "`date +'%Y%m%d-%H:%M:%S'`: Disable SynoFinder"
	# 2nd disable service
	synoservice --disable pkgctl-SynoFinder
	echo "`date +'%Y%m%d-%H:%M:%S'`: Uninstall SynoFinder"
	# 3rd uninstall package
	synopkg uninstall SynoFinder
fi
