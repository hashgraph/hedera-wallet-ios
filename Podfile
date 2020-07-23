platform :ios, '11.0'

target 'HGCApp' do
  use_frameworks!

  pod 'ABPadLockScreen', '3.4.2'
  pod 'JKBigInteger', '~> 0.0.1'
  pod 'LGSideMenuController', '2.1.1'
  pod 'MTBBarcodeScanner', '5.0.11'

  target 'UnitTests' do
    inherit! :complete
  end

  target 'IntegrationTests' do
    inherit! :complete
  end

  target 'HGCAppUITests' do
    inherit! :complete
  end
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
        end
    end
end
