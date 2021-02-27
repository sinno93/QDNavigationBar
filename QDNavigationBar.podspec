#
# Be sure to run `pod lib lint QDNavigationBar.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'QDNavigationBar'
  s.version          = '0.4.0'
  s.summary          = 'Customize the navigation bar style for each of your controllers'

  s.homepage         = 'https://github.com/sinno93/QDNavigationBar'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'sinno93' => 'sinno93@qq.com' }
  s.source           = { :git => 'https://github.com/sinno93/QDNavigationBar.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.source_files = 'QDNavigationBar/Classes/**/*'
  s.swift_version = '5.0'
  s.swift_versions = ['4.0', '4.2', '5.0']
end
