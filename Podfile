platform :ios, '10.0'
use_frameworks!

target 'W2STApp' do
  pod 'CorePlot', '~> 2.2'
  pod 'AWSIoT', '~> 2.11'
  pod 'SwiftyJSON', '~> 5.0'
  pod 'OpenSSL-for-iOS', '1.0.2.d.1'
  pod 'AzureIoTHubClient', '~> 1.2'
  pod 'IBMWatsonSpeechToTextV1', '~> 3.0'
  pod 'Charts', '~> 3.4'
end
workspace 'W2STApp'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ARCHS'] = 'arm64'
    end
  end
end
