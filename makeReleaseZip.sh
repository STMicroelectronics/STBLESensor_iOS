#/bin/bash
read -p "Did you increase the Version and boundle id for BlueMS? (pfile)"
read -p "Did you increase the Version and boundle id for BlueSTSDK_Gui? (pfile)"
read -p "Did you increase the Version and boundle id for BlueSTSDK?(pfile)"
releaseName=$1
projectDir=$(pwd)
cd ..
cp -r $projectDir $releaseName
cd $releaseName
rm -rf .git
rm -rf BlueSTSDK/.git
rm -rf BlueSTSDK_Gui/.git
rm -rf Carthage
cd ..
zip -r $releaseName.zip $releaseName
rm -rf $releaseName
