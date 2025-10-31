//
//  AlertController.swift
//  CulinarySubs
//
//  Created by Lesya Verbina on 6/26/19.
//  Copyright © 2019 Lesya Verbina. All rights reserved.
//

import UIKit

public class AlertController: UIAlertController, AlertDisplayer {
    
    var alertWindow: UIWindow? = nil
    var tintColor: UIColor? = nil
    var statusBarHidden: Bool = false
    var statusBarStyle: UIStatusBarStyle = .default
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Adding fade-out
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.alertWindow?.alpha = 0
        }
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Precaution to ensure window gets destroyed
        alertWindow?.isHidden = true
        alertWindow = nil
    }
    
    public func show(animated: Bool, blur: Bool) {
        show(animated: animated, blur: blur, originRect: CGRectZero)
    }
    
    public func show(animated: Bool, blur: Bool, originRect: CGRect) {
        // Save topmost controller's status bar style
        let filteredArray = UIApplication.shared.windows.filter { window in
            window.isKeyWindow
        }
        var mainWindow: UIWindow? = filteredArray.first
        var scene: UIWindowScene? = nil
        
        // If the app is using UIWindowScene lifecycle
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
           let topWindow = windowScene.windows.last {
            mainWindow = topWindow
            scene = windowScene
        }
        
        guard let mainWindow = mainWindow else { return }
        
        var responsibleController: UIViewController? = mainWindow.rootViewController?.presentedViewController ?? mainWindow.rootViewController
        
        if let responsibleTabController = responsibleController as? UITabBarController {
            responsibleController = responsibleTabController.selectedViewController
        }
        
        if let responsibleNavController = responsibleController as? UINavigationController,
           (!responsibleNavController.isNavigationBarHidden &&
            !responsibleNavController.navigationBar.isTranslucent) {
            responsibleController = responsibleNavController.topViewController
        }
        
        statusBarStyle = responsibleController?.preferredStatusBarStyle ?? .default
        statusBarHidden = responsibleController?.prefersStatusBarHidden ?? false
        
        alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow?.accessibilityViewIsModal = true
        
        // Force status bar to have particular style via UINavigationController
        let rootNavController = UINavigationController()
        rootNavController.navigationBar.barStyle = statusBarStyle == .default ? UIBarStyle.default : UIBarStyle.black
        rootNavController.navigationBar.isTranslucent = false
        rootNavController.isNavigationBarHidden = true
        rootNavController.overrideUserInterfaceStyle = self.statusBarStyle == .default ? .light : .dark
        alertWindow?.rootViewController = rootNavController
        
        // We inherit the main window's tintColor
        alertWindow?.tintColor = mainWindow.tintColor
        // Window level is above the top window (this makes the alert, if it's a sheet, show over the keyboard)
        alertWindow?.windowLevel = mainWindow.windowLevel + 1
        
        if blur {
            // Create blur effect
            let blurEffect = UIBlurEffect(style: .light)
            // Add effect to an effect view
            let visualEffectView = UIVisualEffectView(effect: blurEffect)
            visualEffectView.frame = alertWindow?.frame ?? UIScreen.main.bounds
            alertWindow?.addSubview(visualEffectView)
        }
        
        alertWindow?.windowScene = scene
        alertWindow?.makeKeyAndVisible()
        
        // Animate fade in
        alertWindow?.alpha = 0
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.alertWindow?.alpha = 1
        }
        
        // Needed for iPad presentation, will present from the bottom center of the screen
        popoverPresentationController?.sourceView = alertWindow?.rootViewController?.view
        popoverPresentationController?.sourceRect = !CGRectEqualToRect(originRect, CGRectZero) ? originRect : CGRect(
            x: UIScreen.main.bounds.size.width / 2,
            y: UIScreen.main.bounds.size.height / 2,
            width: 1,
            height: 1)
        
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .fullScreen
        
        alertWindow?.rootViewController?.present(self, animated: animated, completion: nil)
        
        // Customize buttons tint color *after* presenting, or it won't work
        if tintColor != nil {
            alertWindow?.tintColor = tintColor
        }
    }
    
    public func hide(animated: Bool) {
        // Alert controller is hidden automatically
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle { statusBarStyle }
    public override var prefersStatusBarHidden: Bool { statusBarHidden }
    
    public static func create(withTitle title: String?,
                              message: String?,
                              buttonCount: Int,
                              textFieldPlaceholders: [String],
                              tintColor: UIColor?) -> AlertDisplayer {
        
        // If more than 2 buttons (including cancel button) and no text fields - action sheet
        let sheet = (buttonCount > 1 && textFieldPlaceholders.count == 0)
        let alertController =
        AlertController.init(title: title,
                             message: message,
                             preferredStyle: sheet ? .actionSheet : .alert)
        
        // Custom tint color, if any
        if tintColor != nil {
            alertController.tintColor = tintColor
        }
        
        // Text fields, if any
        for textFieldPlaceholder in textFieldPlaceholders {
            alertController.addTextField { (textField) in
                textField.placeholder = textFieldPlaceholder
            }
        }
        
        return alertController
    }
    
    public func add(buttonActionDicts: [NSDictionary],
                    cancelActionDict: NSDictionary,
                    destructiveActionDict: NSDictionary) {
        
        // Cancel action
        let cancelTitle = cancelActionDict.allKeys.first as? String ?? "Ok"
        let cancelBlock: (()->Void)? = cancelActionDict.allValues.first as? (()->Void)
        
        let cancelAction = UIAlertAction.init(title: cancelTitle,
                                              style: .cancel) { (action) in
            cancelBlock?()
        }
        addAction(cancelAction)
        
        // Action buttons, if any
        for actionDict in buttonActionDicts {
            let actionTitle = actionDict.allKeys.first as? String
            let actionBlock: (()->Void)? = actionDict.allValues.first as? (()->Void)
            
            let action = UIAlertAction.init(title: actionTitle, style: .default) { (action) in
                actionBlock?()
            }
            addAction(action)
        }
        
        // Destructive action, if any
        if destructiveActionDict.count > 0 {
            let destructiveTitle = destructiveActionDict.allKeys.first as? String
            let destrBlock: (()->Void)? = destructiveActionDict.allValues.first as? ()->Void
            
            let destrAction = UIAlertAction.init(title: destructiveTitle,
                                                 style: .destructive) { (action) in
                destrBlock?()
            }
            addAction(destrAction)
        }
    }
}
