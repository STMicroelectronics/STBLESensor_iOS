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
import Charts

import AssetTrackingDataModel

public class TrackerSensorSampleViewController: UIViewController {
    
    public var sampleProvider: DataSampleProvider?
    public var showHeader: Bool = false
    
    private var samples: [SensorDataSample] = []
    private var range: ClosedRange<Double>? = nil
    
    /// create a chart data entry from a SensorDataSample
    ///
    /// - Parameters:
    ///   - sample: sample where extract the data
    ///   - extractData: function that select the sample data
    /// - Returns: A chartDataEntry containing the sensor data or nil if the data is not available.
    private func createChartDataEntry(sample: SensorDataSample, extractData: ((_ sample: SensorDataSample) -> Float?)) -> ChartDataEntry? {
        guard let value = extractData(sample) else { return nil }
        
        return ChartDataEntry(x: sample.date.timestampDouble,
                              y: Double(value))
    }
    
    /// list of chart entries containing the  samples
    private var temperatureData: [ChartDataEntry] {
        return samples.compactMap { createChartDataEntry(sample: $0) { $0.temperature} }
    }
    
    private var pressureData: [ChartDataEntry] {
        return samples.compactMap { createChartDataEntry(sample: $0) { $0.pressure} }
    }
    
    private var humidityData: [ChartDataEntry] {
        return samples.compactMap { createChartDataEntry(sample: $0) { $0.humidity} }
    }
    
    private var accelerationData: [ChartDataEntry] {
        return samples.compactMap { createChartDataEntry(sample: $0) { $0.acceleration} }
    }
    
    private var tableData: [TrackerDataSensorSampleViewCell.Data] = []
    private var detailsData: [TrackerDataSensorDetailsViewController.Data] = []
    
    @IBOutlet weak var mPlotTable: UITableView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        mPlotTable.dataSource = self
        mPlotTable.showsVerticalScrollIndicator = false
        
        if showHeader {
            let headerLabel = UILabel()
            headerLabel.font = UIFont.boldSystemFont(ofSize: 22)
            headerLabel.text = "Sensor data"
            mPlotTable.tableHeaderView = headerLabel
        }
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateHeaderViewHeight(for: mPlotTable.tableHeaderView)
    }
    
    func updateHeaderViewHeight(for header: UIView?) {
        guard showHeader,
              let header = header else { return }
        header.frame.size.height = header.systemLayoutSizeFitting(CGSize(width: view.bounds.width, height: 0)).height
    }
    
    /// create the cell and the details data to display
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    public func loadData() {
        sampleProvider?.getRange { [weak self] range in
            self?.range = range
            
            self?.sampleProvider?.getSamples { providerSamples in
                self?.samples = providerSamples.sensorSamples
                DispatchQueue.main.async { self?.refreshTable() }
            }
        }
    }
    
    private func refreshTable() {
        tableData = []
        detailsData = []
        let titleFormat = "%@ (%@)"
        if pressureData.isEmpty == false {
            let title = String(format: titleFormat, SensorType.Pressure.description,SensorType.Pressure.unit)
            tableData.append(TrackerDataSensorSampleViewCell.Data(name: title,
                                                                  samples: pressureData,
                                                                  plotRange: TrackerSensorSampleViewController.PRESSURE_EXTREME,
                                                                  timeRange: range))
            
            detailsData.append(TrackerDataSensorDetailsViewController.Data(title: SensorType.Pressure.description,
                                                                           dataFormat: SensorType.Pressure.umDataFormat,
                                                                           samples:pressureData))
        }
        if humidityData.isEmpty == false {
            let title = String(format: titleFormat, SensorType.Humidity.description,SensorType.Humidity.unit)
            tableData.append(TrackerDataSensorSampleViewCell.Data(name: title,
                                                                  samples: humidityData,
                                                                  plotRange: TrackerSensorSampleViewController.HUMIDITY_EXTREME,
                                                                  timeRange: range))

            detailsData.append(TrackerDataSensorDetailsViewController.Data(title: SensorType.Humidity.description,
                                                                           dataFormat: SensorType.Humidity.umDataFormat,
                                                                           samples:humidityData))
        }
        /*
         if let acceleration = accelerationData, !acceleration.isEmpty{
         let title = String(format: titleFormat, SmarTagSensorName.ACCELERATION,SmarTagSensorName.ACCELERATION_UNIT)
         tableData.append(TrackerDataSensorSampleViewCell.Data(name: title,
         samples: acceleration,
         plotRange: TrackerSensorSampleViewController.ACCELERATION_EXTREME))
         detailsData.append(TrackerDataSensorDetailsViewController.Data(title: SmarTagSensorName.ACCELERATION,
         dataFormat:SmarTagSensorName.ACCELERATION_FORMAT,
         samples:acceleration))
         }
         */
        if temperatureData.isEmpty == false {
            let title = String(format: titleFormat, SensorType.Temperature.description,SensorType.Temperature.unit)
            tableData.append(TrackerDataSensorSampleViewCell.Data(name: title,
                                                                  samples: temperatureData,
                                                                  plotRange: TrackerSensorSampleViewController.TEMPERATURE_EXTREME, timeRange: range))
            
            detailsData.append(TrackerDataSensorDetailsViewController.Data(title: SensorType.Temperature.description,
                                                                           dataFormat: SensorType.Temperature.umDataFormat,
                                                                           samples:temperatureData))
        }
        mPlotTable.reloadData()
    }
    
    /// pass the data to the details view controller
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? TrackerDataSensorDetailsViewController,
           let data = sender as? TrackerDataSensorDetailsViewController.Data{
            viewController.data = data;
        }
    }
    
    /// plot temperature range
    private static let TEMPERATURE_EXTREME = -5.0...45.0
    
    /// plot pressure range
    private static let PRESSURE_EXTREME = 950.0...1150.0
    
    /// plot humidity range
    private static let HUMIDITY_EXTREME = 0.0...100.0
    
    /// plot acceleration range
    private static let ACCELERATION_EXTREME = 600.0...63.0*256.0
}

extension TrackerSensorSampleViewController: UITableViewDataSource{
    private static let CELL_ID = "TrackerDataSensorSampleViewCell"
    private static let DETAILS_SEGUE_ID = "SmarTagSensorDetailsSegue"
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.CELL_ID) as! TrackerDataSensorSampleViewCell
        
        cell.setup(data: tableData[indexPath.row])
        
        let dataDetails = detailsData[indexPath.row]
        cell.onDetailsClick = {
            self.performSegue(withIdentifier: TrackerSensorSampleViewController.DETAILS_SEGUE_ID, sender: dataDetails)
        }
        
        return cell;
    }
}
