#
# Be sure to run `pod lib lint MimikkoResources_iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MimikkoResources_iOS'
  s.version          = '0.1.0'
  s.summary          = 'resource manager'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  兽耳资源管理，暂用于管理兽耳角色模块的资源解压、数据存储、数据读取
                       DESC

  s.homepage         = 'https://github.com/BPModels/MimikkoResource_iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'sam' => 'testshatingyu@gmail.com' }
  s.source           = { :git => 'https://github.com/BPModels/MimikkoResource_iOS.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'

  s.source_files = 'MimikkoResources_iOS/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MimikkoResources_iOS' => ['MimikkoResources_iOS/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'ObjectMapper', '4.2.0'
  s.dependency 'SSZipArchive', '2.4.3'
end
