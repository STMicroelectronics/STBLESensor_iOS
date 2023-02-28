/*
 * Copyright (c) 2019  STMicroelectronics – All rights reserved
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
import CoreData
import STTheme
import BlueSTSDK_Gui
import CoreNFC
import KeychainAccess


@UIApplicationMain
public class BlueMSAppDelegate : UIResponder,UIApplicationDelegate {
    public var window:UIWindow?
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        //DATA Accepted in this form-> blesensor://connect?Pin=___&Add=___
        let pin = url.valueOf("Pin")
        let mac = url.valueOf("Add")
        
        if !(mac==nil) {
            if let nav = app.windows[0].rootViewController as? UINavigationController, let delegate = nav.topViewController as? BlueMSMainViewController {
                let nodeListView = BlueSTSDKNodeListViewController.buildWith(delegate: delegate, mac: mac!)
                
                if !(pin==nil) {
                    let pinDialogAlert = UIAlertController(title: "Board PIN", message: "Board PIN is \(pin!.description).\nCopy and paste when required during Bluetooth Pairing Request.", preferredStyle: .alert)
                    let confirmButton = UIAlertAction(title: "Copy PIN ⎘", style: .default, handler: { (action) -> Void in
                        /**Continue only after click Ok button. The user has the time to read the board PIN**/
                        UIPasteboard.general.string = pin
                        nav.pushViewController(nodeListView, animated: true)
                    })
                    pinDialogAlert.addAction(confirmButton)
                    nav.present(pinDialogAlert, animated: true, completion: nil)
                }else{
                    nav.pushViewController(nodeListView, animated: true)
                }
                
            }
        }
        
        return true
    }
    
    public func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool{
        self.clearKeychainIfWillUnistall()
        configureApperance()
        return true
    }
    
    func clearKeychainIfWillUnistall() {
        let freshInstall = !UserDefaults.standard.bool(forKey: "alreadyInstalled")
        if freshInstall {
            do {
                /** Delete Keychain*/
                var keychain = Keychain(service: "com.st")
                keychain = keychain.accessibility(.afterFirstUnlock)
                try keychain.removeAll()
            } catch {
                NSLog("Keychain: saving error", error.localizedDescription)
            }
            UserDefaults.standard.set(true, forKey: "alreadyInstalled")
        }
    }
    
    private func configureApperance(){
        ThemeService.shared.applyToAllViewType()
     /*  UIImageView.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).tintColor=ThemeService.shared.currentTheme.color.secondary.light    }
    */
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "STAzureRegisteredDeviceModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}
