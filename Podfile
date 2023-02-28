platform :ios, '12.0'

inhibit_all_warnings!
use_frameworks!

workspace 'W2STApp'

target 'W2STApp' do
  # Internal
  pod 'BlueSTSDK', :path => 'STLibs/BlueSTSDK'
  pod 'BlueSTSDK_Gui', :path => 'STLibs/BlueSTSDK_Gui'
  pod 'STTheme', :path => 'STLibs/STTheme'
  
  pod 'BlueMSFwUpgradeChecker', :path => 'STLibs/BlueMSFwUpgradeChecker'
  pod 'STTrilobyte', :path => 'STLibs/STTrilobyte'

  pod 'AssetTrackingCloudDashboard', :path => 'STLibs/AssetTrackingCloudDashboard'
  pod 'AssetTrackingDataModel', :path => 'STLibs/AssetTrackingDataModel'
  pod 'TrackerThresholdUtil', :path => 'STLibs/TrackerThresholdUtil'
  pod 'SmarTagLib', :path => 'STLibs/SmarTagLib'

  # Public
  pod 'MQTTClient', '~> 0.14.0'
  pod 'CorePlot', '~> 2.2'
  pod 'AWSIoT', '~> 2.11'
  pod 'AWSPinpoint', '~> 2.11'
  pod 'SwiftyJSON', '~> 5.0'
  pod 'OpenSSL-for-iOS', '1.0.2.d.1'
  pod 'AzureIoTHubClient', '1.5.0'
  pod 'IBMWatsonSpeechToTextV1', '~> 3.0'
  pod 'Charts', '~> 3.6.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ARCHS'] = 'arm64'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
