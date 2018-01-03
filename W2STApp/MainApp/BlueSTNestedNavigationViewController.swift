/*
 * Copyright (c) 2017  STMicroelectronics – All rights reserved
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


/// When you have a NavigationController with a TabBarController wiht a Navigation controller,
/// the last navigation controller is hide by the first one. 
/// this class hide the navigation bar of all the previous controller to show the correct one.
public class BlueSTNestedNavigationViewController: UINavigationController{
    
    
    /// traverse all the view until the root and change the visibility to
    /// all the navigation bar
    ///
    /// - Parameter hide: true to hide the navigation bar, false to show it
    private func hideParentNatigationBar(hide:Bool){
        var parent = self.parent;
        while(parent != nil){
            if let navigation = parent?.navigationController{
                navigation.setNavigationBarHidden(hide, animated: false);
            }
            parent = parent?.parent;
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        //if there are more that one controller in the stack show this navigation bar
        // to go back
        if(viewControllers.count>1){
            hideParentNatigationBar(hide: true);
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        //when Disappear show the previus navigation bar
        hideParentNatigationBar(hide: false);
    }
    
    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        //when a new controlelr is add to the stack hide parent bar to show this one
        hideParentNatigationBar(hide: true);
        super.pushViewController(viewController, animated: animated)
    }
    
    public override func popViewController(animated: Bool) -> UIViewController? {

        //if only one controller will remain in the stack, show the parent navigation bar
        if (viewControllers.count==2){
            hideParentNatigationBar(hide: false)
        }
        
        return super.popViewController(animated: animated);
    }
    
}
