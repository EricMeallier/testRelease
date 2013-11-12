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

#     sed -i "1,+10s/<version>.*<\/version>/<version>$version<\/version>/" DataProdXML/pom.xml
#     sed -i "1,+10s/<version>.*<\/version>/<version>$version<\/version>/" EverestRPM/pom.xml

     echo "Building and deploying (to Nexus) the release $version..." 
     mvn clean deploy -DskipTests=true

     mvn scm:checkin -Dmessage="[release.sh] Change POM versions to $version" -DpushChanges=false
     mvn scm:tag

     echo "Preparing the development version $newVersion..." 

     mvn versions:set -DnewVersion=$newVersion  versions:commit

#     sed -i "1,+10s/<version>.*<\/version>/<version>$newVersion<\/version>/" DataProdXML/pom.xml
#     sed -i "1,+10s/<version>.*<\/version>/<version>$newVersion<\/version>/" EverestRPM/pom.xml

     mvn scm:checkin -Dmessage="[release.sh] Change POM versions to $newVersion"

fi


