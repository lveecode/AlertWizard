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
        
        // Save topmost controller's status bar style
        
        let mainWindow: UIWindow = UIApplication.shared.keyWindow!
        
        var responsibleController: UIViewController? = mainWindow.rootViewController?.presentedViewController != nil ? mainWindow.rootViewController?.presentedViewController : mainWindow.rootViewController
        
        if responsibleController?.isKind(of: UITabBarController.self) ?? false {
            
            responsibleController = (responsibleController as! UITabBarController).selectedViewController
        }
        
        if responsibleController?.isKind(of: UINavigationController.self) ?? false {
            
            let responsibleNavController = responsibleController as! UINavigationController
            
            if responsibleNavController.isNavigationBarHidden ||
                responsibleNavController.navigationBar.isTranslucent {
                
                responsibleController = responsibleNavController.topViewController
            }
        }
        
        if responsibleController == nil { responsibleController = UIViewController() }
        
        statusBarStyle = responsibleController!.preferredStatusBarStyle
        statusBarHidden = responsibleController!.prefersStatusBarHidden
        
        alertWindow = UIWindow(frame: UIScreen.main.bounds)
        
        // Force status bar to have particular style via UINavigationController
        let rootNavController = UINavigationController()
        rootNavController.navigationBar.barStyle = statusBarStyle == .default ? UIBarStyle.default : UIBarStyle.black
        rootNavController.isNavigationBarHidden = true
        
        alertWindow?.rootViewController = rootNavController
        
        // We inherit the main window's tintColor
        alertWindow?.tintColor = UIApplication.shared.delegate?.window??.tintColor
        // Window level is above the top window (this makes the alert, if it's a sheet, show over the keyboard)
        let topWindow = UIApplication.shared.windows.last
        alertWindow?.windowLevel = topWindow?.windowLevel ?? UIWindow.Level.alert + 1
        
        if blur {
            // Create blur effect
            let blurEffect = UIBlurEffect(style: .light)
            // Add effect to an effect view
            let visualEffectView = UIVisualEffectView(effect: blurEffect)
            visualEffectView.frame = alertWindow?.frame ?? UIScreen.main.bounds
            alertWindow?.addSubview(visualEffectView)
        }
        
        alertWindow?.makeKeyAndVisible()
        
        // Animate fade in
        alertWindow?.alpha = 0
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.alertWindow?.alpha = 1
        }
        
        // Needed for iPad presentation, will present from the bottom center of the screen
        popoverPresentationController?.sourceView = alertWindow?.rootViewController?.view
        popoverPresentationController?.sourceRect = CGRect(
            x: alertWindow?.rootViewController?.view.bounds.size.width ?? 0 / 2,
            y: alertWindow?.rootViewController?.view.bounds.size.height ?? 0,
            width: 1,
            height: 1)
        
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .fullScreen
        
        alertWindow?.rootViewController?.present(self, animated: animated, completion: nil)
        
        // Customize buttons tint color after presenting, or it won't work
        if tintColor != nil {
            alertWindow?.tintColor = tintColor
        }
    }
    
    public func hide(animated: Bool) {
        // Alert controller is hidden automatically
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    public override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
    
    public static func create(withTitle title: String?,
                       message: String?,
                       buttonCount: Int,
                       textFieldPlaceholders: [String],
                       tintColor: UIColor?) -> AlertDisplayer {
        
        // If more than 2 buttons - action sheet
        let alertController = AlertController.init(title: title,
                                                   message: message,
                                                   preferredStyle: (buttonCount > 1 && textFieldPlaceholders.count == 0) ? .actionSheet : .alert)
        
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
        let cancelTitle: String = cancelActionDict.allKeys.first as? String ?? "Ok"
        let cancelBlock: (()->Void)? = cancelActionDict.allValues.first as? (()->Void)
        
        let cancelAction = UIAlertAction.init(title: cancelTitle,
                                              style: .cancel) { (action) in
            cancelBlock?()
        }
        addAction(cancelAction)
        
        // Action buttons, if any
        for actionDict in buttonActionDicts {
            let actionTitle: String = actionDict.allKeys.first as! String
            let actionBlock: (()->Void)? = actionDict.allValues.first as? (()->Void)
            
            let action = UIAlertAction.init(title: actionTitle, style: .default) { (action) in
                actionBlock?()
            }
            addAction(action)
        }
        
        // Destructive action, if any
        if destructiveActionDict.count > 0 {
            let destructiveTitle: String = destructiveActionDict.allKeys.first as! String
            let destrBlock: (()->Void)? = destructiveActionDict.allValues.first as? ()->Void
            
            let destrAction = UIAlertAction.init(title: destructiveTitle,
                                                 style: .destructive) { (action) in
                                                    destrBlock?()
            }
            addAction(destrAction)
        }
    }
}
