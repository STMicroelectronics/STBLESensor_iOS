#to install cacoapods: https://guides.cocoapods.org/using/getting-started.html
pod update
pod install

#to install carhage:
# /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"​
# brew update
# brew install carthage
#to update cartage
# brew update cartage
echo "Carthage: remove chache and previous build"
rm -rf ~/Library/Caches/org.carthage.CarthageKit
rm -rf ./Carthage/Build/
echo "Carthage: build dependecy"
carthage update --no-use-binaries --platform iOS
echo "CHANGE BUNDLE ID!!!!"
echo "in W2STAPP->BuildSettings-> change APP_VERSION and APP_BUILD"
echo "check the cloud id!"
