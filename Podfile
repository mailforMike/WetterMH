platform :ios, '9.0'

target 'WetterMH' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for WetterMH

  pod 'Alamofire'
  #pod 'SwiftyJSON'
  #pod 'Charts'
  pod 'SwiftChart'

end

# Workaround for Cocoapods issue #7606
post_install do |installer|
installer.pods_project.build_configurations.each do |config|
config.build_settings.delete('CODE_SIGNING_ALLOWED')
config.build_settings.delete('CODE_SIGNING_REQUIRED')
end
end
