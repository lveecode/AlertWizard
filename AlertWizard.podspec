#
# Be sure to run `pod lib lint Podname.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|

s.swift_version = '5'

s.name             = 'AlertWizard'
s.version          = '0.1.3'
s.summary          = 'AlertWizard provides centralized control and structure to alert messages. Use the default UIAlertController, or create your own custom ones'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

s.description      = <<-DESC
AlertWizard provides centralized control and structure to alert messages. It uses UIAlertController in a way intended by Apple, while providing compact and transparent methods that are easy to use, as well as framework for managing your own alert messages in an elegant way. You can create your own fully custom alert controllers implementing AlertDisplayer protocol, and have them displayed via AlertWizard. Store all your alert messages, headers, buttons, ect in an easily localizable .json file.
DESC

s.homepage         = 'https://github.com/lveecode/AlertWizard'
# s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'Lesya V' => '' }
s.source           = { :git => 'https://github.com/lveecode/AlertWizard.git', :tag => s.version.to_s }
# s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

s.ios.deployment_target = '11.0'

s.source_files = 'AlertWizard/Classes/**/*'

# s.resource_bundles = {
#   'AlertWizard' => ['AlertWizard/Assets/*.png']
# }

# s.public_header_files = 'Pod/Classes/**/*.h'
s.frameworks = 'UIKit'
# s.dependency 'AFNetworking', '~> 2.3'
# s.default_subspec = 'Core'

# s.subspec 'Core' do |core|
# subspec for users who only want Core features
#      core.source_files = 'Podname/Classes/Core/**/*'
# end

end
