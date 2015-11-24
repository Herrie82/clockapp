#!/bin/bash

# This is a test package to facilitate packaging the application outside of the 
# OE build environment.  Current development is being done by David Woods.  

############################################################
# Setup variables
############################################################
_BUILD_TEMP=../build-temp
_RESULTS_DIR=BuildResults
_submissionNum=0
_componentTitle=Null 
# NOVALOC:
# This requires localization to be a directory parallel to your current project.
# see https://wiki.palm.com/display/Globalization/How+to+Run+the+Nova+Localization+Tool for more info in prepping your local build.
# For the phoenix component you need to "Add Source Info"  pointing to the localization directory. i.e.
# http://subversion.palm.com/main/nova/palm/luna/localization/trunk with a manditory "Local Offset Path" localization  
NOVALOC=../localization/tool/novaloc


############################################################
# Define functions
############################################################

# Replaces the last field of the version value from appinfo.json
# PARAMETERS: 	_submissionNum
# SETS:			NONE
changeVersionTo(){
	if [ -d ${_BUILD_TEMP} ] && [ -f ${_BUILD_TEMP}/appinfo.json ]; then
		sed -e 's/\(^.*[v|V]ersion.*\)\([\.|,][0-9]\+\)/\1\.'${1}'/' ${_BUILD_TEMP}/appinfo.json > ${_BUILD_TEMP}/appinfo_new.json
		mv -f ${_BUILD_TEMP}/appinfo_new.json ${_BUILD_TEMP}/appinfo.json
	else
		echo "changeVersionTo:  Temp directory is unproperly setup"
		exit 1
	fi;
}
# Reads the title value from the appinfo.json file.  
# PARAMETERS: 	NONE
# SETS: 		_componentTitle
setComponentTitle(){
	if [ -d ${_BUILD_TEMP} ] && [ -f ${_BUILD_TEMP}/appinfo.json ]; then
		_componentTitle=`grep -e "^.*[t|T]itle" ${_BUILD_TEMP}/appinfo.json | awk '{print tolower($2)}' | sed 's/"\+\(.*\)".\+/\1/'`
	else
		echo "setComponentTitle:  Temp directory is unproperly setup"
		exit 1
	fi; 
}
# The submission encoding for the version follows the format should be "Major*100 + Minor"
# If passed in trunk or an uncontrolled build, defaults to 999.99
# PARAMETERS: _submissionNum
# 		SETS: _submissionNum
encodeSubmissionVersion(){
	if [ "${1}" = "" ]; then
		_submission_major=999
		_submission_minor=99
	else
		_submission_major=`echo ${1} | awk -F "." '{print $1}'`
		_submission_minor=`echo ${1} | awk -F "." '{print $2}'`
	fi

	if [ "${_submission_minor}" = "" ]; then
		_submission_minor=0
	fi
	_submissionNum=`expr ${_submission_major} \* 100 + ${_submission_minor}`
}

############################################################
# Prepare build areas
############################################################
echo "Preparing build area: Cleaning previous Results"
rm -rf ${_RESULTS_DIR}
rm -rf ${_BUILD_TEMP}
echo "Preparing build area: Making ${_RESULTS_DIR} Directory"
mkdir -v `pwd`/${_RESULTS_DIR}
mkdir -vp ${_BUILD_TEMP}




############################################################
# Parse Input
############################################################

while getopts ":hs:" opt; do
	case ${opt} in
	s)
		_submissionNum=${OPTARG}
		;;
	h)
		echo "-s [NUM] pull down and build submission NUM.  "
		echo "Default will just build trunk." 
		exit 1 ;;
	\?)
		echo "Invalid option: -${OPTARG}" >&2
		exit 1
	  ;;
	:)
	  echo "Option -${OPTARG} requires an argument." >&2
	  exit 1
	  ;;
	esac
done

echo "env is set to "
set
echo "Checking for ${_RESULTS_DIR} directory"
ls `pwd`

############################################################
# Grab the Code
# Isolated behavior between phoenix and local user
############################################################
if [ "$SVN_USER" = 'phoenix daemon' ]; then

	echo "Phoenix section."
	_submissionNum=`ls -d [0-9]* | sort -n | tail -1`
	if [ -d `pwd`/${_submissionNum} ]; then 
		cp -f -r `pwd`/${_submissionNum}/*.* ${_BUILD_TEMP}
		encodeSubmissionVersion ${_submissionNum}
		changeVersionTo ${_submissionNum}
	else
		echo "submission pathing is improperly formatted. Exiting..."
		exit 1
	fi
else
	echo "Local User Section"
	if [ ${_submissionNum} -gt 0 ]; then
		_exportPath=`svn info | grep -e "URL" | sed -e 's/\(^URL: \)\(.*\)\(trunk$\)/\2submissions/'`
		echo "Exporting ${_exportPath}/${_submissionNum}"
		svn export --force "${_exportPath}/${_submissionNum}" ${_BUILD_TEMP}
		encodeSubmissionVersion ${_submissionNum}
		changeVersionTo ${_submissionNum}
	else
		#svn export --force . ${_BUILD_TEMP}
		#echo "Grabbing top-of-tree and building locally. "
		cp -r -f -d `pwd`/*.* ${_BUILD_TEMP}
	fi
fi

############################################################
# Purge excluded files from ${_BUILD_TEMP}
############################################################
echo "Purging ignored files..."
if [ -f build-ignore ]; then		
	awk '{ print "../build-temp/"$1}' build-ignore | xargs rm -f
else
	echo "No files were ignored in the build."
fi

############################################################
# Localization
############################################################
# NOVALOC:
# This requires localization to be a directory parallel to your current project.
# see https://wiki.palm.com/display/Globalization/How+to+Run+the+Nova+Localization+Tool for more info in prepping your local build.
# For the phoenix component you need to "Add Source Info"  pointing to the localization directory. i.e.
# http://subversion.palm.com/main/nova/palm/luna/localization/trunk with a manditory "Local Offset Path" localization  

_novaloc=localization/tool/novaloc

# Search up the path until we find the tool we need.  Per the web page it should be up only three levels.  The tool will probably 
# fail if we allow searches outside of this level.

if [ ! -r ${_novaloc} ]; then
	if [ ! -r ../${_novaloc} ]; then
		if [ ! -r ../../${_novaloc} ]; then
			if [ ! -r ../../../${_novaloc} ]; then
				echo "ERROR: Failed to find ${_novaloc} in 3 previous directories: aborting"
				exit 1
			else
				_novaloc_path="../../../${_novaloc}"
			fi
		else
			_novaloc_path="../../${_novaloc}"
		fi
	else
		_novaloc_path="../${_novaloc}"
	fi
else
	_novaloc_path="${_novaloc}"
fi
echo "Localization: using ${_novaloc_path}"	
	
if [ -f ${_novaloc_path} ]; then
	setComponentTitle  
	${_novaloc_path} -s ${_BUILD_TEMP} -d ${_BUILD_TEMP} ${_componentTitle} 
else
	echo "localization files were not found at ${_novaloc_path}"
	echo "Have the localization files been pulled down from the repository?"
fi

############################################################
# Build the actual package
############################################################
echo "Building the package"	
palm-package ${_BUILD_TEMP} -o `pwd`/${_RESULTS_DIR}
