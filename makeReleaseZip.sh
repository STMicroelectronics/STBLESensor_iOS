#/bin/bash
read -p "Did you increase the Version and boundle id for BlueMS? (pfile)"
read -p "Did you increase the Version and boundle id for BlueSTSDK_Gui? (pfile)"
read -p "Did you increase the Version and boundle id for BlueSTSDK?(pfile)"
versionName=$1
projectDir=$(pwd)

cd BlueSTSDK
git tag $versionName
git push --tags origin
cd ..

cd BlueSTSDK_Gui
git tag $versionName
git push --tags origin
cd ..

cd BlueSTSDK_Analytics
git tag $versionName
git push --tags origin
cd ..

cd trilobyte
git tag $versionName
git push --tags origin
cd ..

git tag $versionName
git push --tags origin 


zip -r ../iosSrc_$versionName.zip . -x '*.git*'
