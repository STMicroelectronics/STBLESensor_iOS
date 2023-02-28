 /*
  * Copyright (c) 2018  STMicroelectronics – All rights reserved
  * The STMicroelectronics corporate logo is a trademark of STMicroelectronics
  *
  * Redistribution and use in source and binary forms, with or without modification,
  * are permitted provided that the following conditions are met:
  *
  * - Redistributions of source code must retain the above copyright notice, this list of conditions
  *   and the following disclaimer.
  *
  * - Redistributions in binary form must reproduce the above copyright notice, this list of
  *   conditions and the following disclaimer in the documentation and/or other materials provided
  *   with the distribution.
  *
  * - Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
  *   STMicroelectronics company nor the names of its contributors may be used to endorse or
  *   promote products derived from this software without specific prior written permission.
  *
  * - All of the icons, pictures, logos and other images that are provided with the source code
  *   in a directory whose title begins with st_images may only be used for internal purposes and
  *   shall not be redistributed to any third party or modified in any way.
  *
  * - Any redistributions in binary form shall not include the capability to display any of the
  *   icons, pictures, logos and other images that are provided with the source code in a directory
  *   whose title begins with st_images.
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
  * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
  * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
  * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
  * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
  * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
  * OF SUCH DAMAGE.
  */

import Foundation

extension UIViewController{
    
    @objc public func changeViewController(_ newView:UIViewController){
        //check if we have a navigation controller
        if let nav = navigationController {
            nav.pushViewController(newView, animated: true)
        }else{
            present(newView, animated: true, completion: nil)
        }//if-else
    }
    
    public func removeCurrentViewController(){
        //check if we have a navigation controller
        if let nav = navigationController {
            nav.popViewController(animated: true)
        }else{
            dismiss(animated: true, completion: nil)
        }//if-else
    }
    
    
    /// change the current view controller with the new one and remove the current one from the navigation stack
    ///
    /// - Parameter newView: view controller to push in the navigation stack
    public func replaceViewController(_ newView:UIViewController, animated: Bool = true){
            /** Check if we have a navigation controller */
            if let navigationVc = navigationController{
                /** Used when we want push BlueSTSDKSeachOtaNodeViewController */
                if(parent?.navigationController?.viewControllers != nil){
                   for aViewController in parent!.navigationController!.viewControllers {
                       if aViewController is BlueSTSDKDemoViewController {
                           parent?.navigationController?.viewControllers.append(newView)
                           let currentIndex = parent?.navigationController?.viewControllers.count ?? 2
                           parent?.navigationController?.viewControllers.remove(at: currentIndex-2)
                       }
                   }
                } else if(self.navigationController?.viewControllers != nil){
                    /** Used when we want push BlueSTSDKFwUpgradeManagerViewController */
                    for aViewController in self.navigationController!.viewControllers {
                        if aViewController is BlueSTSDKSeachOtaNodeViewController {
                            self.navigationController?.viewControllers.append(newView)
                            let currentIndex = self.navigationController?.viewControllers.count ?? 2
                            self.navigationController?.viewControllers.remove(at: currentIndex-2)
                        }
                    }
                }
            }else{
                present(newView, animated: animated, completion: nil)
            }
        }
    
    private static let OK_BUTTON: String = {
        let bundle = Bundle(for: UIViewController.self);
        return NSLocalizedString("Ok", tableName: nil,
                                 bundle: bundle,
                                 value: "Ok",
                                 comment: "Ok");
    }();
    
    @objc public func showAllert( title:String,message:String, closeController:Bool=false){
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let okButton = UIAlertAction(title: UIViewController.OK_BUTTON,
                                     style: .default){ _ in
                                        if(closeController){
                                            if (self.navigationController != nil){
                                                self.navigationController?.popViewController(animated: true)
                                            }else{
                                                self.presentingViewController?.dismiss(animated: true, completion: nil)
                                            }
                                        }
        }
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
    
    @available(*, deprecated)
    @objc public func showErrorMsg(_ msg:String, title:String, closeController:Bool){
        showAllert(title: title,message: msg,closeController: closeController)
    }
    
    public func hasDarkTheme() -> Bool{
        if #available(iOS 13, *){
            return self.traitCollection.userInterfaceStyle == .dark
        }else{
            return false
        }
    }
    
}
