# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'AppSyncRealTimeClient' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for AppSyncRealTimeClient
  pod "Starscream", "~> 3.0.2"
  pod "AWSCore", "~> 2.12.7"
  
  target 'AppSyncRealTimeClientTests' do
    # Pods for testing
    pod "AWSCore", "~> 2.12.7"
  end

end

target "HostApp" do 
  use_frameworks!
  target "AppSyncRealTimeClientIntegrationTests" do 
    inherit! :complete
  end
end
