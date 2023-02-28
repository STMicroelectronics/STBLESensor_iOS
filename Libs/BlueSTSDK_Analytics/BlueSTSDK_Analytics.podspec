#
# Be sure to run `pod lib lint BlueSTSDK_Analytics.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BlueSTSDK_Analytics'
  s.version          = '0.1.0'
  s.summary          = 'A short description of BlueSTSDK_Analytics.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/klauslanza/BlueSTSDK_Analytics'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'klauslanza' => 'klauslanza@gmail.com' }
  s.source           = { :git => 'https://github.com/klauslanza/BlueSTSDK_Analytics.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'

  s.source_files = 'BlueSTSDK_Analytics/Classes/**/*'

  s.dependency 'BlueSTSDK'
  s.dependency 'BlueSTSDK_Gui'
  s.dependency 'AWSPinpoint'

end
