Pod::Spec.new do |s|
  s.name             = 'W3WSwiftComponents'
  s.version          = '2.3.2'
  s.summary          = 'A collection of UI components for what3words addresses'
  s.homepage         = 'https://github.com/what3words/w3w-swift-components'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.authors          = { "what3words" => "support@what3words.com" }
  s.source           = { :git => 'https://github.com/what3words/w3w-swift-components.git', :tag => 'v2.3.2' }
  s.ios.deployment_target = "11.0"
  s.requires_arc = true
  s.source_files = 'Sources/**/*.swift'
  s.frameworks = 'UIKit', 'CoreLocation', 'MapKit'
  s.swift_version = ['5.0']
  s.resource_bundles = {
    'W3WComponentResources' => [
        'Sources/W3WSwiftComponents/Resources/*'
    ]
  }
  s.dependency 'W3WSwiftApi'
end
