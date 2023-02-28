#
# Be sure to run `pod lib lint AssetTrackingCloudDashboard.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AssetTrackingCloudDashboard'
  s.version          = '0.1.0'
  s.summary          = 'A short description of AssetTrackingCloudDashboard.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Stefano Zanetti/AssetTrackingCloudDashboard'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Stefano Zanetti' => 's.zanetti@codermine.com' }
  s.source           = { :git => 'https://github.com/Stefano Zanetti/AssetTrackingCloudDashboard.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'

  s.source_files = 'AssetTrackingCloudDashboard/Classes/**/*'
  
  s.resource_bundles = {
    'AssetTrackingCloudDashboard' => ['AssetTrackingCloudDashboard/Assets/**/*']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  
  s.static_framework = true
  
  s.dependency 'AssetTrackingDataModel'
  s.dependency 'BlueSTSDK_Gui'
  s.dependency 'SmarTagLib'
  s.dependency 'Toast-Swift'
  s.dependency 'SwiftyJSON'
  s.dependency 'AWSCore'
  s.dependency 'AWSCognitoIdentityProvider'
  s.dependency 'AWSCognitoIdentityProviderASF'
  s.dependency 'AppAuth'
  s.dependency 'CryptoSwift'
  s.dependency 'PKHUD'
  s.dependency 'TrackerThresholdUtil'
  s.dependency 'KeychainAccess'

end
