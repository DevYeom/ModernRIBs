Pod::Spec.new do |s|
  s.name             = 'ModernRIBs'
  s.version          = '1.0.1'
  s.swift_version    = '5.4'
  s.summary          = 'Uber\'s RIBs with Combine.'
  s.description      = <<-DESC
  ModernRIBs is recreated by removing additional dependencies such as RxSwift from Uber's RIBs. Only Combine was used. All features provided by RIBs can be used identically, and it will be continuously updated according to the RIBs updated version. Therefore, the version will be matched with the RIBs. It is expected to be useful in projects that do not use RxSwift and with a minimum supported iOS 13 or later.
                       DESC
  s.homepage         = 'https://github.com/DevYeom/ModernRIBs'
  s.license          = { :type => 'Apache License, Version 2.0', :file => 'LICENSE.txt' }
  s.author           = { 'DevYeom' => 'dev.yeom@gmail.com' }
  s.source           = { :git => 'https://github.com/DevYeom/ModernRIBs.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.source_files = 'ModernRIBs/Classes/**/*'
end
