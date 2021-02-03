
Pod::Spec.new do |s|
  s.name             = 'W3WSwiftComponents'
  s.version          = '2.0.0'
  s.summary          = 'A collection of UI components for what3words addresses'
  s.homepage         = 'https://github.com/what3words/w3w-swift-components.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.authors          = { "what3words" => "support@what3words.com" }
  # s.source           = { :git => 'https://github.com/what3words/w3w-swift-components.git', :tag => s.version }
  s.source           = { :git => 'https://github.com/what3words/w3w-swift-components.git', :branch => 'v2.0.0' }
  s.ios.deployment_target = '10.0'
  s.requires_arc = true
  s.source_files = 'Sources/**/*.swift'
  s.frameworks = 'UIKit'
  s.pod_target_xcconfig =  {
        'SWIFT_VERSION' => '5.3',
  }
  s.resource = 'Resources/'
  s.dependency 'https://github.com/what3words/w3w-swift-wrapper.git', '~> 3.3.1'
end
