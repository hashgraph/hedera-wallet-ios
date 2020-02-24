platform :ios, '10.0'

target 'HGCApp' do
 use_frameworks!

 # Pods for HGCApp
pod 'MBProgressHUD', '1.1.0'
pod 'ABPadLockScreen', '3.4.2'
pod 'MTBBarcodeScanner', '5.0.11'
pod 'LGSideMenuController', '2.1.1'
pod 'ActiveLabel', '1.0.1'
pod 'IQKeyboardManagerSwift'

pod 'JKBigInteger', '~> 0.0.1'
pod 'SwiftyJSON', '5.0.0'
pod 'SwiftGRPC', '0.8.1'
pod 'CryptoSwift', '1.0.0'

  target 'HGCAppTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'HGCAppUITests' do
    inherit! :complete
    # Pods for testing
  end

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      if ['SwiftyJSON'].include? target.name
        target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = '4.2'
        end
      end
    end
  end
end
