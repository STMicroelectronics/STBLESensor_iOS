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

import UIKit

public class ThemeService {
    public static let shared: ThemeService = ThemeService()
    
    public private(set) var currentTheme: Theme = STDefaultTheme()
    
    public func update(with theme: Theme) {
        currentTheme = theme
    }
    
    public var stassetTrackingApp = "ST Asset Tracking"
    
    public func applyToAllViewType(){
        
        applyTabBarTheme(UITabBar.appearance())
        if(Bundle.main.infoDictionary!["CFBundleName"] as! String == stassetTrackingApp){
            applyUIToolBarTheme(UIToolbar.appearance())
        }else{
            applyButtonTheme(UIButton.appearance())
        }
        applyUINavigatorBarTheme(UINavigationBar.appearance())
        applyPageTheme(UIPageControl.appearance())
    }
    
    public func applyUINavigatorBarTheme(_ navigatiorBar: UINavigationBar){
        if #available(iOS 15, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.backgroundColor = currentTheme.color.navigationBar
            navigatiorBar.tintColor = currentTheme.color.navigationBarText
            navigationBarAppearance.titleTextAttributes = [
                .foregroundColor : currentTheme.color.navigationBarText
            ]
            let navigationBarButton = UIButton.appearance(whenContainedInInstancesOf: [UINavigationBar.self] )
            navigationBarButton.tintColor = currentTheme.color.navigationBarText
            navigationBarButton.setTitleColor(currentTheme.color.navigationBarText, for: .normal)
            
            navigatiorBar.standardAppearance = navigationBarAppearance
            navigatiorBar.scrollEdgeAppearance = navigationBarAppearance
            
        }else{
            navigatiorBar.barTintColor = currentTheme.color.navigationBar
            navigatiorBar.tintColor = currentTheme.color.navigationBarText
            
            navigatiorBar.titleTextAttributes = [
                .foregroundColor : currentTheme.color.navigationBarText
            ]
            
            let navigationBarButton = UIButton.appearance(whenContainedInInstancesOf: [UINavigationBar.self] )
            navigationBarButton.tintColor = currentTheme.color.navigationBarText
            navigationBarButton.setTitleColor(currentTheme.color.navigationBarText, for: .normal)
        }
    }
    
    public func applyUIToolBarTheme(_ toolBar: UIToolbar){
        toolBar.barTintColor = currentTheme.color.primary
        toolBar.tintColor = currentTheme.color.secondaryATR
    }
    
    public func applyTabBarTheme(_ tabBar: UITabBar){
        if #available(iOS 15, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            tabBarAppearance.backgroundColor = currentTheme.color.navigationBar
            
            tabBarAppearance.compactInlineLayoutAppearance.normal.iconColor = UIColor.white
            tabBarAppearance.compactInlineLayoutAppearance.normal.titleTextAttributes = [.foregroundColor : UIColor.white]
            
            tabBarAppearance.inlineLayoutAppearance.normal.iconColor = UIColor.white
            tabBarAppearance.inlineLayoutAppearance.normal.titleTextAttributes = [.foregroundColor : UIColor.white]
            
            tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.white
            tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor : UIColor.white]
            
            tabBar.standardAppearance = tabBarAppearance
            tabBar.scrollEdgeAppearance = tabBar.standardAppearance
            tabBar.tintColor = currentTheme.color.navigationBarText

        }else{
            tabBar.barTintColor = currentTheme.color.navigationBar
            tabBar.tintColor = currentTheme.color.navigationBarText
            tabBar.unselectedItemTintColor = UIColor.white
        }
    }
    
    public func applyButtonTheme(_ button: UIButton ){
        button.tintColor = currentTheme.color.secondary
        button.setTitleColor(currentTheme.color.secondary, for: .normal)
    }
    
    public func applyPageTheme(_ pageControl: UIPageControl ){
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = currentTheme.color.secondary
    }
}
