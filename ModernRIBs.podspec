Pod::Spec.new do |s|
  s.name             = 'ModernRIBs'
  s.version          = '0.0.1'
  s.swift_version    = '5.2'
  s.summary          = 'Without any additional dependencies, Uber\'s cross-platform mobile architecture.'
  s.description      = <<-DESC
  ModernRIBs is recreated by removing additional dependencies such as RxSwift and RxRelay from RIBs. RIBs is the cross-platform architecture behind many mobile apps at Uber. This architecture framework is designed for mobile apps with a large number of engineers and nested states.
                       DESC
  s.homepage         = 'https://github.com/DevYeom/ModernRIBs'
  s.license          = { :type => 'Apache License, Version 2.0', :file => 'LICENSE.txt' }
  s.author           = { 'DevYeom' => 'dev.yeom@gmail.com' }
  s.source           = { :git => 'https://github.com/DevYeom/ModernRIBs.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.source_files = 'ModernRIBs/Classes/**/*'
end
