#!/bin/bash

IGNORE_NUSPEC='xxx'

# git
git pull

# nuget restore
nuget restore

# build
xbuild /p:Configuration=Release MinusEngine.sln
xbuild /p:Configuration=Debug MinusEngine.sln

# nuget version
for x in *.nuspec
do
	echo $IGNORE_NUSPEC | grep "$x" >/dev/null || (
		perl -pi.bak -e 's/<version>([0-9]+)\.([0-9]+)\.([0-9]+)<\/version>/"<version>$1.$2.".($3+1)."<\/version>"/ge; ' "$x"
	)
done
MAIN_VERSION=$(grep "<version>" MinusEngine.nuspec | perl -n -e 's/[^0-9.]+//g; print')

# pack
rm -rf nuget-out
mkdir nuget-out
for x in *.nuspec
do
	echo $IGNORE_NUSPEC | grep "$x" >/dev/null || (
		# Windows Store allows only Release configuration!!!!
		nuget pack "$x" -Prop Configuration=Release -OutputDirectory nuget-out
	)
done

# git
git add --all
#git commit -a -m "nuget release $MAIN_VERSION"
git push

# push
for x in nuget-out/*.nupkg
do
	nuget push "$x"
done

