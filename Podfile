# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

def include_build_tools!
  pod 'SwiftFormat/CLI'
  pod 'SwiftLint'
end

target 'AppSyncRealTimeClient' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for AppSyncRealTimeClient
  pod "Starscream", "~> 3.1.0"
  
  include_build_tools!

  target 'AppSyncRealTimeClientTests' do
    # Pods for testing
  end

end

target "AppSyncRTCSample" do 
  use_frameworks!

  pod 'AppSyncRealTimeClient', :path => '.'
  include_build_tools!

end

target "HostApp" do 
  use_frameworks!

  # Intentionally not including build tools here--HostApp has no content or
  # purpose beyond giving the integration tests a device-like execution
  # context.

  target "AppSyncRealTimeClientIntegrationTests" do 
    inherit! :complete
    include_build_tools!
  end
end

