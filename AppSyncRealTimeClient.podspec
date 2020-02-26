Pod::Spec.new do |s|

    s.name         = 'AppSyncRealTimeClient'
    s.version      = '0.0.1'
    s.summary      = 'Amazon Web Services AppSync RealTime Client for iOS.'
  
    s.description  = 'AppSync RealTime Client provides subscription connections to AppSync websocket endpoints'
  
    s.homepage     = 'https://aws.amazon.com/amplify/'
    s.license      = 'Apache License, Version 2.0'
    s.author       = { 'Amazon Web Services' => 'amazonwebservices' }
    s.platform     = :ios, '9.0'
    s.source       = { :git => 'https://github.com/aws-amplify/amplify-ios.git', :tag => s.version}
    
    s.requires_arc = true
    
    s.source_files = 'AppSyncRealTimeClient/**/*.swift'
    s.dependency 'Starscream', '~> 3.0.2'
  end