//
//  UIManager.swift
//  GithubSearcher
//
//  Created by Jiang on 27/07/2021.
//


import UIKit

class UIManager {
    static let shared = UIManager()
    
    static var window: UIWindow? {
        return UIApplication.shared.delegate?.window ?? UIApplication.shared.windows.first ?? UIApplication.shared.keyWindow
    }
    
    func initTheme() {
        
    }
}

//App View
extension UIManager {
    
    static func showMain(animated: Bool = false) {
        if let controller = loadViewController(storyboard: "Main") {
            let navController = wrapNavigationController(controller: controller)
            self.setRootViewController(controller: navController, animated: animated)
        }
    }
}


//Alert
extension UIManager {
    
    static func showErrorAlert(_ title: String = "Sorry", message: String? = nil, actionTitle: String = "OK", parentController: UIViewController? = nil, completionHandler: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: actionTitle, style: .default) { (action) in
            completionHandler?()
        }
        alert.addAction(defaultAction)
        
        guard let presenter = parentController ?? (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController else {
            return
        }
        presenter.present(alert, animated: true, completion: nil)
    }
}

//Safe area
extension UIManager {
    static func bottomPadding() -> CGFloat {
        guard #available(iOS 11.0, *), let window = UIApplication.shared.windows.first else {
            return 0
        }
        return window.safeAreaInsets.bottom
    }
    
    static func topPadding() -> CGFloat {
        guard #available(iOS 11.0, *), let window = UIApplication.shared.windows.first else {
            return 0
        }
        return window.safeAreaInsets.top
    }
    
    static func windowFrame(of view: UIView) -> CGRect {
        var maskRect = view.convert(view.frame, to: UIApplication.shared.windows.first!)
        maskRect.origin.y = maskRect.origin.y + UIManager.topPadding()
        return maskRect
    }
}

//Primary
extension UIManager {
    static func present(controller: UIViewController, animated: Bool = true, parentController: UIViewController? = nil, isFullScreen: Bool = true) {
        guard let parent = parentController ?? UIApplication.shared.delegate?.window??.rootViewController else {
            return
        }
        if isFullScreen {
            controller.modalPresentationStyle = .overFullScreen
        }
        parent.present(controller, animated: true, completion: nil)
    }
    
    static func wrapNavigationController(controller: UIViewController) -> UINavigationController {
        return BaseNavigationController(rootViewController: controller)
    }
    
    static func loadViewController(storyboard name: String, controller identifier: String? = nil) -> UIViewController? {
        guard let identifier = identifier else {
            return UIStoryboard(name: name, bundle: nil).instantiateInitialViewController()
        }
        return UIStoryboard(name: name, bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    
    //change root view controller
    static func setRootViewController(controller: UIViewController, animated: Bool = false) {
        DispatchQueue.main.async {
            if let window = (UIApplication.shared.delegate as? AppDelegate)?.window {
                guard let rootViewController = window.rootViewController else {
                    return
                }
                
                controller.view.frame = rootViewController.view.frame
                controller.view.layoutIfNeeded()
                
                if animated {
                    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        let oldState: Bool = UIView.areAnimationsEnabled
                        UIView.setAnimationsEnabled(false)
                        window.rootViewController = controller
                        UIView.setAnimationsEnabled(oldState)
                    }, completion: nil)
                }
                else {
                    window.rootViewController = controller
                }
            }
            else {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
                appDelegate.window?.backgroundColor = UIColor.white
                appDelegate.window?.rootViewController = controller
                appDelegate.window?.makeKeyAndVisible()
            }
        }
    }
}
