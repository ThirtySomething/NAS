#!/bin/bash
# 1st disable service
echo "`date +'%Y%m%d-%H:%M:%S'`: Check for SynoFinder"
if synoservice --list-config | grep -Fq 'pkgctl-SynoFinder'; then    
	echo "`date +'%Y%m%d-%H:%M:%S'`: Disable SynoFinder"
	synoservice --disable pkgctl-SynoFinder
	echo "`date +'%Y%m%d-%H:%M:%S'`: Uninstall SynoFinder"
	# 2nd uninstall package
	synopkg uninstall SynoFinder
fi
