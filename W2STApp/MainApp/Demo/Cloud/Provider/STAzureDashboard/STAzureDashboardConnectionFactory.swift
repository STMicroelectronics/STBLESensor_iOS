

import Foundation

class STAzureDashboardConnectionFactory : BlueMSCloudIotConnectionFactory {
    private static let DATA_URL = URL(string: "https://stm32ode.azurewebsites.net/")
    
    private let mDeviceParameters: STAzureRegisterdDevice
    
    init(forDevice device:STAzureRegisterdDevice){
        mDeviceParameters = device
    }
    
    func getSession() -> BlueMSCloudIotClient {
        return STAzureDashboardClient(connectionString: mDeviceParameters.connectionString)
    }
    
    func getDataUrl() -> URL? {
        return Self.DATA_URL
    }
    
    func getFeatureDelegate(withSession session: BlueMSCloudIotClient, minUpdateInterval: TimeInterval) -> BlueSTSDKFeatureDelegate {
        let dashboardClient = session as! STAzureDashboardClient;
        return STAzureDashboardFeatureListener(client: dashboardClient, minUpdateInterval: minUpdateInterval)
    }
    
    func isSupportedFeature(_ feature: BlueSTSDKFeature) -> Bool {
        STAzureDashboardFeatureListener.isSupportedFeature(feature)
    }
    
    func enableCloudFwUpgrade(for: BlueSTSDKNode, connection: BlueMSCloudIotClient, callback: @escaping OnFwUpgradeAvailableCallback) -> Bool {
        guard let dashboardClient = connection as? STAzureDashboardClient else{
            return false
        }
        return dashboardClient.enableCloudFwUpgrade(callback: callback)
    }
}
