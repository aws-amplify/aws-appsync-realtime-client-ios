# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

def include_build_tools!
  pod 'SwiftFormat/CLI', "~> 0.49.0"
  pod 'SwiftLint'
end

target 'AppSyncRealTimeClient' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for AppSyncRealTimeClient
  
  # If you update this dependency version, be sure to update the Cartfile also
  pod "Starscream", "4.0.4"
  
  include_build_tools!

  target 'AppSyncRealTimeClientTests' do
    # Pods for testing
  end

end

target "AppSyncRTCSample" do 
  use_frameworks!

  # Note: This only contains build tool Pods for the AppSyncRTCSample. If we
  # specify the 'AppSyncRealTimeClient' pod here as well, it can cause
  # confusion as xcodebuild attempts to build this target's
  # 'AppSyncRealTimeClient' dependency instead of the main target.
  # Specify AppSyncRealTimeClient as a dependency by direclty including it in
  # AppSyncRTCSample's Xcode build phase.
  # pod 'AppSyncRealTimeClient', :path => '.'
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

