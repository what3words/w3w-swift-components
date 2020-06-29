
Pod::Spec.new do |s|
  s.name             = 'W3wSuggestionField'
  s.version          = '1.1.0'
  s.summary          = 'w3w-suggestion-swift allows you integrate w3w autosuggest  uitextfield component with storyboard'
  s.homepage         = 'https://github.com/what3words/w3w-autosuggest-textfield-swift.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.authors          = { "what3words" => "support@what3words.com" }
  s.source           = { :git => 'https://github.com/what3words/w3w-autosuggest-textfield-swift.git', :tag => s.version }
  s.ios.deployment_target = '10.0'
  s.requires_arc = true
  s.source_files = 'Sources/*.swift'
  s.frameworks = 'UIKit'
  s.swift_version = ['4.0', '4.2', '5.0']
  s.pod_target_xcconfig =  {
        'SWIFT_VERSION' => '4.2',
  }
  s.resource = 'Sources/images.xcassets'

end
