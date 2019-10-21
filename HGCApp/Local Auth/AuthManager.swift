//
//  AuthManager.swift
//  HGCApp
//
//  Created by Surendra  on 31/10/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit
import LocalAuthentication
import ABPadLockScreen

public enum AuthType: String {
    case biometric = "biometric"
    case PIN = "pin"
    case none = "none"
}

extension AuthManager {
    public static let onAuthSuccess = Notification.Name("hgc.onAuthSuccess")
}

class AuthManager: NSObject {
    
    private var appDidEnterBackgroundTime: Date?
    private let window:UIWindow
    var mainWindow:UIWindow
    
    private let backgroundTimeLimit:TimeInterval = 2*60 // in seconds
    
    var onComplete : ((_ success: Bool) -> Void)?
    
    init(mainWindow:UIWindow) {
        self.mainWindow = mainWindow
        let authWindow = UIWindow.init(frame: UIScreen.main.bounds)
        authWindow.windowLevel = UIWindow.Level.init(rawValue: 2)
        authWindow.backgroundColor = UIColor.white
        authWindow.alpha = 0.0
        window = authWindow
        
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(AuthManager.appDidEnterBanckground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    func setupBiometricAuth (animated:Bool) {
        self.doBiometricAuth(forSetup: true, animated: animated)
    }
    
    func setupPIN() {
        let vc = ABPadLockScreenSetupViewController.init(delegate: self, complexPin: true)
        window.rootViewController = vc
        setShow(true, animated: true, completion: nil)
    }
    
    func authenticate(_ authType: AuthType, animated:Bool) {
        if isAuthInProgress() { return }
        
        switch authType {
        case .biometric:
            self.doBiometricAuth(forSetup: false, animated: animated)
        case .PIN:
            self.doAuthUsingPIN(animated: animated);
        case .none:
            self.finish(forSetup: false, success: false, animated: false)
            WalletHelper.quit()
            break;
        }
    }
    
    func currentAuthType() -> AuthType {
        let isBioetricAuthEnabled = AppSettings.isBiometricLoginEnabled()
        if isBioetricAuthEnabled {
            return AuthType.biometric
        } else {
            let pin = SecureAppSettings.default.getPIN()
            if pin != nil && !(pin?.isEmpty)! {
                return AuthType.PIN
            } else {
                return .none
            }
            
        }
    }
    
    func isBiometricAuthAvailable() -> Bool {
        return BioMetricAuthenticator.shared.faceIDAvailable() || BioMetricAuthenticator.shared.touchIDAvailable();
    }
    
    func isFaceIdAvailable() -> Bool {
        return BioMetricAuthenticator.shared.faceIDAvailable()
    }
    
    private func setCurrentAuthType(_ authType:AuthType) {
        if authType == .biometric {
            AppSettings.setBiometricLoginEnabled(true)
        } else {
            AppSettings.setBiometricLoginEnabled(false)
        }
    }
    
    private func biometricTypeName() -> String {
        return self.isFaceIdAvailable() ? NSLocalizedString("Face ID", comment: "") : NSLocalizedString("Touch ID", comment: "")
    }
    
    private func doBiometricAuth(forSetup: Bool, animated:Bool) {
        window.rootViewController = UIStoryboard.init(name: "LaunchScreen", bundle: Bundle.main).instantiateInitialViewController()
        setShow(true, animated: animated, completion: nil)
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "Logging in with \(biometricTypeName())", success: {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                self.setCurrentAuthType(.biometric)
                self.finish(forSetup: forSetup, success: true, animated: true)
            })
            
        }) { (error) in
            Globals.showGenericAlert(title: "Error", message: (error).message(), handler: { (action) in
                if !forSetup {
                    WalletHelper.quit()
                }
                self.finish(forSetup: forSetup, success: false, animated: true)
            })
        }
    }
    
    private func setShow(_ show:Bool, animated:Bool = false, completion: (() -> Void)? = nil) {
        if show {
            self.window.isHidden = false
        } else {
            self.mainWindow.isHidden = false
        }
        UIView.animate(withDuration: animated ? 0.2 : 0.0, animations: {
            self.mainWindow.alpha = show ? 0.0 : 1.0
            self.window.alpha = show ? 1.0 : 0.0
            
        }) { (finished) in
            self.mainWindow.isHidden = show
            self.window.isHidden = !show
            
            if show {
                self.window.makeKeyAndVisible()
            } else {
                self.window.rootViewController = nil
                self.mainWindow.makeKeyAndVisible()
            }
            if let c = completion {
                c()
            }
        }
    }
    
    
    /////////////////////// PIN ///////////////////////
    private func doAuthUsingPIN(animated:Bool) {
        let vc = ABPadLockScreenViewController.init(delegate: self, complexPin: true)
        window.rootViewController = vc
        setShow(true, animated: animated, completion: nil)
    }
    
    private func finish(forSetup:Bool, success:Bool, animated:Bool) {
        setShow(false, animated: animated) {
            if self.onComplete != nil {
                self.onComplete!(success)
                self.onComplete = nil
            }
            if success && !forSetup {
                NotificationCenter.default.post(name: AuthManager.onAuthSuccess, object: nil)
            }
        }
    }
    
    @objc private func appDidEnterBanckground() {
        self.appDidEnterBackgroundTime = Date()
    }
    
    public func shouldAskForAuth() -> Bool {
        if let date = appDidEnterBackgroundTime  {
            let timeElapsed = Date().timeIntervalSince(date)
            if timeElapsed > backgroundTimeLimit {
                return true
            }
        }
        return false
    }
    
    public func isAuthInProgress() -> Bool {
        return window.alpha > 0.0
    }
}

extension AuthManager: ABPadLockScreenSetupViewControllerDelegate, ABPadLockScreenViewControllerDelegate {
    func pinSet(_ pin: String!, padLockScreenSetupViewController padLockScreenViewController: ABPadLockScreenSetupViewController!) {
        self.setCurrentAuthType(.PIN)
        SecureAppSettings.default.setPIN(pin)
         self.finish(forSetup: true, success: true, animated: true)
    }
    
    func unlockWasCancelled(forSetupViewController padLockScreenViewController: ABPadLockScreenAbstractViewController!) {
        self.finish(forSetup: true, success: false, animated: true)
    }
    
    ///////// PIN verify delegate
    func padLockScreenViewController(_ padLockScreenViewController: ABPadLockScreenViewController!, validatePin pin: String!) -> Bool {
        return SecureAppSettings.default.getPIN() == pin
    }
    
    func unlockWasSuccessful(for padLockScreenViewController: ABPadLockScreenViewController!) {
      self.finish(forSetup: false, success: true, animated: true)
        
    }
    
    func unlockWasUnsuccessful(_ falsePin: String!, afterAttemptNumber attemptNumber: Int, padLockScreenViewController: ABPadLockScreenViewController!) {
        if (attemptNumber > 1) {
            Globals.showConfirmationAlert(title: NSLocalizedString("Wrong passcode", comment: ""), message: NSLocalizedString("Do you want to exit?", comment: ""), cancelButtonTitle: NSLocalizedString("No", comment: ""), actionButtonTitle:NSLocalizedString("Yes", comment: ""), onConfirm:{
                WalletHelper.quit()
            }, onDismiss: nil)
        }
    }
    
    func unlockWasCancelled(for padLockScreenViewController: ABPadLockScreenViewController!) {
        WalletHelper.confirmQuit()
    }
}
