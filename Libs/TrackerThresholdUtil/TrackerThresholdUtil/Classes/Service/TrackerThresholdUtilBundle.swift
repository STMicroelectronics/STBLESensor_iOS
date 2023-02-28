import Foundation

public class TrackerThresholdUtilBundle {
    public static func bundle() -> Bundle {
        let myBundle = Bundle(for: Self.self)
        
        guard let resourceBundleURL = myBundle.url(forResource: "TrackerThresholdUtil", withExtension: "bundle") else {
            fatalError("TrackerThresholdUtil.bundle not found!")
        }
        
        guard let resourceBundle = Bundle(url: resourceBundleURL) else {
            fatalError("Cannot access TrackerThresholdUtil.bundle!")
        }
        
        return resourceBundle
    }
}
