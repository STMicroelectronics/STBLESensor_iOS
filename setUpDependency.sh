#to install cocoapods: https://guides.cocoapods.org/using/getting-started.html
pod update
pod install

#to install carthage:
# /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
# brew update
# brew install carthage
# to update carthage
# brew update carthage
echo "Carthage: remove cache and previous build"
rm -rf ~/Library/Caches/org.carthage.CarthageKit
rm -rf ./Carthage/Build/
echo "Carthage: build dependency"
carthage update --no-use-binaries --platform iOS
echo "CHANGE BUNDLE ID!!!!"
echo "in W2STAPP->BuildSettings-> change APP_VERSION and APP_BUILD"
echo "check the cloud id!"
