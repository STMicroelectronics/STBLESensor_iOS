 /*
  * Copyright (c) 2018  STMicroelectronics – All rights reserved
  * The STMicroelectronics corporate logo is a trademark of STMicroelectronics
  *
  * Redistribution and use in source and binary forms, with or without modification,
  * are permitted provided that the following conditions are met:
  *
  * - Redistributions of source code must retain the above copyright notice, this list of conditions
  * and the following disclaimer.
  *
  * - Redistributions in binary form must reproduce the above copyright notice, this list of
  * conditions and the following disclaimer in the documentation and/or other materials provided
  * with the distribution.
  *
  * - Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
  * STMicroelectronics company nor the names of its contributors may be used to endorse or
  * promote products derived from this software without specific prior written permission.
  *
  * - All of the icons, pictures, logos and other images that are provided with the source code
  * in a directory whose title begins with st_images may only be used for internal purposes and
  * shall not be redistributed to any third party or modified in any way.
  *
  * - Any redistributions in binary form shall not include the capability to display any of the
  * icons, pictures, logos and other images that are provided with the source code in a directory
  * whose title begins with st_images.
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
import UIKit

import AssetTrackingDataModel

public class TrackerDataShowDataPageViewController: UIPageViewController{
    
    public static func instanciateWithData(_ samples:[DataSample]) -> UIViewController {
        let bundle = TrackerThresholdUtilBundle.bundle()
        let storyboard = UIStoryboard(name: "ShowData", bundle: bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "TrackerDataShowDataPageViewController") as? TrackerDataShowDataPageViewController
        
        vc?.eventSample = samples.eventSamples
        vc?.sensorSample = samples.sensorSamples
        
        return vc!
    }
    
    var sensorSample : [SensorDataSample] = []
    var eventSample : [EventDataSample] = []
    
    /// List of controller to show in the pageViewController
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        let bundle = TrackerThresholdUtilBundle.bundle()
        let storyBoard = UIStoryboard(name: "ShowData", bundle: bundle)
        return [storyBoard.instantiateViewController(withIdentifier: "SmarTagSensorDataViewController"),
                storyBoard.instantiateViewController(withIdentifier: "SmarTagEventDataViewController")]
    }()
    
    /// show the fist view controller
    public override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        setPageDataSample()
        if let firstViewController = orderedViewControllers.first{
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }
    
    /// pass the sample to render to the child view controller
    private func setPageDataSample(){
        orderedViewControllers.forEach { viewController in
            switch viewController {
            case let eventsViewController as TrackerEventSampleViewController:
                let sampleProvider = DeviceDataSampleProvider(sampleHandler: { [weak self] handler in
                    guard let self = self else { return }
                    handler(self.eventSample.map { .event(data: $0) })
                })
                eventsViewController.sampleProvider = sampleProvider
                eventsViewController.showHeader = true
            
            case let sensorViewController as TrackerSensorSampleViewController:
                let sampleProvider = DeviceDataSampleProvider(sampleHandler: { [weak self] handler in
                    guard let self = self else { return }
                    handler(self.sensorSample.map { .sensor(data: $0) })
                })
                sensorViewController.sampleProvider = sampleProvider
                sensorViewController.showHeader = true
            
            default:
                return
            }
        }
    }
}

// MARK: - UIPageViewControllerDataSource
/// show the page using a circular buffer
extension TrackerDataShowDataPageViewController: UIPageViewControllerDataSource {
    
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of:viewController) else {
            return nil
        }
        
        let previousIndex = ((viewControllerIndex - 1) + orderedViewControllers.count) % orderedViewControllers.count
        
        return orderedViewControllers[previousIndex]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of:viewController) else {
            return nil
        }
        
        let previousIndex = ((viewControllerIndex + 1) + orderedViewControllers.count) % orderedViewControllers.count
        
        return orderedViewControllers[previousIndex]
    }
    
    ////////Start: functions needed to show the UIPageControl ////////////////////////////////
    public func presentationCount(for pageViewController: UIPageViewController) -> Int{
        return orderedViewControllers.count
    }
    
    public func presentationIndex(for pageViewController: UIPageViewController) -> Int{

        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers.firstIndex(of:firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
    //////// End: functions needed to show the UIPageControl ////////////////////////////////
}
