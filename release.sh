#!/bin/sh

versionTag=`mvn help:evaluate -Dexpression=project.version |grep -Ev '(^\[|Download\w+:)'`

if [ `echo $versionTag | awk '{ print match($0,".*-SNAPSHOT$")}'` -eq 1 ]; then
     version=`echo $versionTag | cut -f1 -d-`
     major=`echo $version | cut -f1 -d.`
     minor=`echo $version | cut -f2 -d.`
     release=`echo $version | cut -f3 -d.`
     
     newRelease=`expr $release + 1`
     newVersion=`echo $major.$minor.$newRelease-SNAPSHOT`
     
     echo "Clean-up the git repo"
     git fetch
     git clean -f -d
     git reset --hard origin
     git pull

     echo "Preparing the release $version..."
     mvn versions:set -DnewVersion=$version versions:commit
     ret=$?
     if [ $ret -ne 0 ]; then
	echo "Problem while changing the version number for release"
	exit $ret
     fi

#     sed -i "1,+10s/<version>.*<\/version>/<version>$version<\/version>/" DataProdXML/pom.xml
#     sed -i "1,+10s/<version>.*<\/version>/<version>$version<\/version>/" EverestRPM/pom.xml

     mvn enforcer:enforce
     ret=$?
     if [ $ret -ne 0 ]; then
	echo "Problem while checking dependencies"
	exit $ret
     fi

     echo "Building and deploying (to Nexus) the release $version..." 
     mvn clean deploy -DskipTests=true
     ret=$?
     if [ $ret -ne 0 ]; then
	echo "Problem while building project"
	exit $ret
     fi

     mvn scm:checkin -Dmessage="[release.sh] Change POM versions to $version" -DpushChanges=false
     ret=$?
     if [ $ret -ne 0 ]; then
	echo "Problem while first checkin"
	exit $ret
     fi
     mvn scm:tag
     ret=$?
     if [ $ret -ne 0 ]; then
	echo "Problem while tagging version"
	exit $ret
     fi

     echo "Preparing the development version $newVersion..." 

     mvn versions:set -DnewVersion=$newVersion  versions:commit
     ret=$?
     if [ $ret -ne 0 ]; then
	echo "Problem while changing the version number for developpement"
	exit $ret
     fi

#     sed -i "1,+10s/<version>.*<\/version>/<version>$newVersion<\/version>/" DataProdXML/pom.xml
#     sed -i "1,+10s/<version>.*<\/version>/<version>$newVersion<\/version>/" EverestRPM/pom.xml

     mvn scm:checkin -Dmessage="[release.sh] Change POM versions to $newVersion"
     ret=$?
     if [ $ret -ne 0 ]; then
	echo "Problem while second checkin"
	exit $ret
     fi

     git pull
fi


