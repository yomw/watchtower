#
# Be sure to run `pod lib lint watchtower.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WatchTower'
  s.version          = '0.1.0'
  s.summary          = 'An iBeacon listener to simplify your life.'

  s.homepage         = 'https://github.com/yomw/watchtower'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Guillaume Bellue' => 'guillaume.bellue@wopata.com' }
  s.source           = { :git => 'https://github.com/yomw/watchtower.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'watchtower/Classes/**/*'
  s.frameworks = 'CoreLocation', 'CoreBluetooth'
end
