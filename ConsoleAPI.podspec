Pod::Spec.new do |s|
  s.name = 'ConsoleAPI'
  s.version = '1.0.0'
  s.license = 'MIT'
  s.summary = 'ConsoleAPI is a framework that allows you to write information to the Xcode console.'
  s.homepage = 'https://github.com/watanabetoshinori/ConsoleAPI'
  s.author = "Watanabe Toshinori"
  s.source = { :git => 'https://github.com/watanabetoshinori/ConsoleAPI.git', :tag => s.version }

  s.ios.deployment_target = '12.0'

  s.source_files = 'Source/**/*.{h,m,swift}'

end
