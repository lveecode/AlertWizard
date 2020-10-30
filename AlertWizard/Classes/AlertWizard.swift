//
//  AlertHelper.swift
//  CulinarySubs
//
//  Created by Lesya Verbina on 6/26/19.
//  Copyright © 2019 Lesya Verbina. All rights reserved.
//

import UIKit

/// Displayer protocol for custom alert controllers.
@objc public protocol AlertDisplayer {
    
    /// Access the text fields.
    @objc var textFields: [UITextField]? { get }
    
    /// Initialize a displayer with alert info.
    ///
    /// - Parameters:
    ///   - title: Alert title, can be nil.
    ///   - message: Alert body, can be nil.
    ///   - buttonCount: Number of action buttons, can be used to determine the style of alert controller.
    ///   - textFieldPlaceholders: Array of text field placeholders.
    ///   - tintColor: Tint color for the buttons
    @objc static func create(withTitle title: String?,
                             message: String?,
                             buttonCount: Int,
                             textFieldPlaceholders: [String],
                             tintColor: UIColor?) -> AlertDisplayer
    
    ///  Add buttons and action blocks. Separate from initializer so that the instance can be passed on into the blocks.
    ///
    /// - Parameters:
    ///   - buttonActions: Array of dictionaries with action button titles and blocks, e.g. @{ @"Log out" : block}, @{@"Reset pin" : block }
    ///   - cancelAction: Dictionary with cancel button title and block, e.g. @{ @"Cancel" : block }
    ///   - destructiveAction: Dictionary with destructive button title and block.
    /// - Warning: Blocks are memory stack based, so you need to [block copy] before adding to the dictionary, if you want them to work as expected.
    @objc func add(buttonActionDicts: [NSDictionary],
                   cancelActionDict: NSDictionary,
                   destructiveActionDict: NSDictionary)
    
    /// Display the alert on screen.
    ///
    /// - Parameters:
    ///   - animated: Flag to animate the transition.
    ///   - blur: Flag to blur the background.
    @objc func show(animated: Bool, blur: Bool)
    
    
    /// Hide the alert
    ///
    /// - Parameter animated: Flag to animate the transition
    @objc func hide(animated: Bool)
}

/// Delegate much like UIAlertView delegate.
@objc public protocol AlertDisplayerDelegate {
    
    /// This method is called when dismiss action of an alert displayer is used.
    ///
    /// - Parameter reason: Reason of the alert displayer, as provided on creation.
    @objc optional func didUseCancelActionOfAlert(withReason reason: Int)
    
    /// This method is called when a destructive action of an alert displayer is used.
    ///
    /// - Parameter reason: Reason of the alert displayer, as provided on creation.
    @objc optional func didUseDestructiveActionOfAlert(withReason reason: Int)
    
    /// This method is called when one of the actions of displayer is used (except the cancel and destructive actions, those have their own delegate methods)
    ///
    /// - Parameters:
    ///   - index: Index of a used action.
    ///   - displayer: Alert displayer object, provided here so text fields can be accessed.
    ///   - reason: Reason of the alert displayer, as provided on creation.
    @objc func didUseAction(atIndex index: Int,
                            alertDisplayer displayer: AlertDisplayer,
                            reason: Int)
}

/**
 * Alert reasons will have to be provided as integers, and stored in enum format in your project.
 * Their ids need to correspond those in alerts JSON file, as this is the way JSON alerts will be retrieved.
 *
 * Example of alert reason enum:
 * enum {
 *      AlertReason = 100,
 *  };
 *
 * Corresponding JSON file
 * {
 *   "100": {
 *          "reason" : "AlertReason", // Readable reason, not used in code
 *          "title" : "Accept user?",   // Alert title
 *          "body" : "You can enter short message", // Alert body
 *          "action_titles" : ["Accept user", "Decline user"], // OPTIONAL Action titles,
 *          "cancel_title" : "Cancel", // OPTIONAL Cancel button title, if not provided, "OK" will be used
 *          "text_fields" : ["Message"], // OPTIONAL text fields to be added to controller, providing placeholder text as string
 *      }
 *  }
 */
@objc public class AlertWizard: NSObject {
    
    //
    // MARK: - Customization
    //
    
    ///  Set tint color of alert controller window so button's text color is customized.
    @objc public var tintColor: UIColor? = nil
    @objc public static func setButtonColor(_ color: UIColor) {
        shared.tintColor = color
    }
    
    /// Enable or disable full screen blur when the alert is displayed.
    @objc public var blurEnabled: Bool = false
    
    /// Path for alerts file, set it here in case it is not "Alerts.json" located in the main Bundle.
    /// Used for localization
    @objc public var pathToAlertsFile: String? = Bundle.main.path(forResource: "Alerts", ofType: "json")
    
    //
    // MARK: - default UIAlertController summoning
    //
    
    /// Method that creates and displays standart alert controller with provided reason. Info for controller will be taken from Alerts.json file in main bundle.
    /// Delegate will receive callbacks on dissmiss, destructive and regular actions.
    /// Can provide arguments for formatted title or message body.
    ///
    /// - Parameters:
    ///   - reason: Reason of alert controler, by which alert details will be accessed in Alerts.json file.
    ///   - titleArguments: Arguments for formatted string in alert title.
    ///   - bodyArguments: Arguments for formatted string in alert body.
    ///   - delegate: Delegate, if any.
    /// - Returns: Alert controller object that will be shown.
    @objc @discardableResult public static func displayAlertController(forReason reason: Int,
                                                                titleArguments: [String]? = nil,
                                                                bodyArguments: [String]? = nil,
                                                                delegate: AlertDisplayerDelegate? = nil) -> UIAlertController? {
        
        return shared.displayAlertController(forReason: reason,
                                             titleArguments: titleArguments,
                                             bodyArguments: bodyArguments,
                                             delegate: delegate)
    }
    
    //
    // MARK: - Custom alert displayer summoning
    //
    
    ///  Method that creates and displays custom alert controller, which must conform to WLAlertDisplayer protocol, with provided reason.
    /// Info for controller will be taken from Alerts.json file in main bundle.
    /// Delegate will receive callbacks on dissmiss, destructive and regular actions.
    /// Can provide arguments for formatted title or message body.
    ///
    /// - Parameters:
    ///   - aClass: Class of the custom Alert Displayer.
    ///   - reason: Reason of alert displayer, by which alert details will be accessed in Alerts.json file.
    ///   - titleArguments: Arguments for formatted string in alert title.
    ///   - bodyArguments: Arguments for formatted string in alert body.
    ///   - delegate: Delegate, if any
    /// - Returns: Alert displayer object that will be shown.
    @objc @discardableResult public static func displayAlertDisplayer(ofClass aClass: AlertDisplayer.Type,
                                                               reason: Int,
                                                               titleArguments: [String]? = nil,
                                                               bodyArguments: [String]? = nil,
                                                               delegate: AlertDisplayerDelegate? = nil) -> AlertDisplayer? {

        return shared.displayAlertDisplayer(ofClass: aClass,
                                            reason: reason,
                                            titleArguments: titleArguments,
                                            bodyArguments: bodyArguments,
                                            delegate: delegate)
    }


    //
    // MARK: - Private
    //
    
    @objc public static let shared = AlertWizard()
    @objc open var showingAlert: Bool = false
    
    private func displayAlertController(forReason reason: Int,
                                                                titleArguments: [String]? = nil,
                                                                bodyArguments: [String]? = nil,
                                                                delegate: AlertDisplayerDelegate? = nil) -> UIAlertController? {
        
        // Returning alert controller, so that view controller
        // can access it and text fields in it, in particular
        return displayAlertDisplayer(ofClass: AlertController.self,
                                     reason: reason,
                                     titleArguments: titleArguments,
                                     bodyArguments: bodyArguments,
                                     delegate: delegate) as? UIAlertController
    }
    
    private func displayAlertDisplayer(ofClass aClass: AlertDisplayer.Type,
                                                               reason: Int,
                                                               titleArguments: [String]? = nil,
                                                               bodyArguments: [String]? = nil,
                                                               delegate: AlertDisplayerDelegate? = nil) -> AlertDisplayer? {
        
        weak var weakDelegate = delegate
        
        // If already displaying alert - not displaying new one
        if (showingAlert) {
            return nil
        }
        showingAlert = true
        
        // Parsing alert contents
        let messageDict = AlertWizard.alertDictionaryFromJSON(forReason: reason)
        var title: String? = messageDict["title"] as? String
        var message: String? = messageDict["message"] as? String
        let actionTitles: [String] = (messageDict["action_titles"] as? [String]) ?? []
        var cancelTitle: String = (messageDict["cancel_title"] as? String) ?? ""
        let destrTitle: String = (messageDict["destructive_title"] as? String) ?? ""
        let textFieldPlaceholders: [String] = (messageDict["text_fields"] as? [String]) ?? []
        if cancelTitle.count == 0 {
            cancelTitle = NSLocalizedString("Ok", comment: "alert closing button")
        }
        
        // If provided arguments for title formatted string of body formatted string, adding them
        if titleArguments?.count ?? 0 > 0 {
            let a = titleArguments! + ["x","x","x","x","x","x","x","x","x","x"]
            title = String(format: title ?? "", a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10])
        }
        if bodyArguments?.count ?? 0 > 0 {
            let a = bodyArguments! + ["x","x","x","x","x","x","x","x","x","x"]
            message = String(format: message ?? "", a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10])
        }
        
        // If body or title are absent, hide them so no empty
        // lines show up
        if (message?.count == 0) {
            message = nil
        }
        if (title?.count == 0) {
            title = nil
        }
        
        let displayer = aClass.create(withTitle: title,
                                      message: message,
                                      buttonCount: actionTitles.count,
                                      textFieldPlaceholders: textFieldPlaceholders,
                                      tintColor: tintColor)
        
        // Construct dictionaries for alert displayer
        let cancelBlock: (()->Void) = { [weak self] in
            displayer.hide(animated: true)
            
            self?.showingAlert = false
            weakDelegate?.didUseCancelActionOfAlert?(withReason: reason)
        }
        let cancelDict = [cancelTitle : cancelBlock]
        
        var buttonActionDicts: [NSDictionary] = []
        for (i, actionTitle) in actionTitles.enumerated() {
            let actionBlock: (()->Void) = { [weak self] in
                displayer.hide(animated: true)
                
                self?.showingAlert = false
                weakDelegate?.didUseAction(atIndex: i, alertDisplayer: displayer, reason: reason)
            }
            
            buttonActionDicts.append([actionTitle : actionBlock] as NSDictionary)
        }
        
        var destrDict: [String: Any] = [:]
        if destrTitle.count > 0 {
            let destrBlock: ()->Void = { [weak self] in
                displayer.hide(animated: true)
                
                self?.showingAlert = false
                weakDelegate?.didUseDestructiveActionOfAlert?(withReason: reason)
            }
            
            destrDict.updateValue(destrBlock, forKey: destrTitle)
        }
        
        displayer.add(buttonActionDicts: buttonActionDicts,
                      cancelActionDict: cancelDict as NSDictionary,
                      destructiveActionDict: destrDict as NSDictionary)
        
        displayer.show(animated: true, blur: blurEnabled)
        
        return displayer
    }
    
    static func alertDictionaryFromJSON(forReason reason: Int) -> Dictionary<String, Any> {
        
        if shared.pathToAlertsFile == nil { return [:] }
        let jsonDictionary: Dictionary<String, Any> = objectFromJSONFile(atPath: self.shared.pathToAlertsFile!) as! Dictionary<String, Any>
        
        let reasonString = String(format: "%d", reason)
        return jsonDictionary[reasonString] as! Dictionary<String, Any>
    }
    
    static func objectFromJSONFile(atPath path: String) -> Any {
        
        // Parsing JSON file into array/dict
        let data: Data? = NSData.init(contentsOfFile: path) as Data?
        if data == nil { return [] }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0))
            return jsonObject
        }
        catch let error as NSError {
            print("Found an error - \(error)")
            return []
        }
    }
}
