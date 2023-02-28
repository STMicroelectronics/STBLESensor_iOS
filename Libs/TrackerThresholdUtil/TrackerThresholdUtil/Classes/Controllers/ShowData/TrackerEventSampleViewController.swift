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
import Charts
 
 /// View controller to display the event samples
public class TrackerEventSampleViewController : UIViewController {
    public var showHeader: Bool = false

    /// table where show the events
    @IBOutlet weak var mEventTable: UITableView!
    //label to show if no events are present
    @IBOutlet weak var mNoEventsLabel: UILabel!
    
    public var sampleProvider: DataSampleProvider?
    
    private var samples: [EventDataSample] = []
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        mEventTable.dataSource = self
        mEventTable.showsVerticalScrollIndicator = false
        
        if showHeader {
            let headerLabel = UILabel()
            headerLabel.font = UIFont.boldSystemFont(ofSize: 22)
            headerLabel.text = "Async events"
            mEventTable.tableHeaderView = headerLabel
        }
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateHeaderViewHeight(for: mEventTable.tableHeaderView)
    }
    
    func updateHeaderViewHeight(for header: UIView?) {
        guard showHeader,
              let header = header else { return }
        header.frame.size.height = header.systemLayoutSizeFitting(CGSize(width: view.bounds.width, height: 0)).height
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    public func loadData() {
        sampleProvider?.getSamples { [weak self] providerSamples in
            guard let self = self else { return }
            self.samples = providerSamples.eventSamples.sorted(by: { $0.date > $1.date} )
            // prevent nil when changing filter before first load
            guard self.mEventTable != nil,
                  self.mNoEventsLabel != nil,
                  self.mEventTable != nil else { return }
            
            DispatchQueue.main.async {
                self.mEventTable.isHidden = self.samples.isEmpty
                self.mNoEventsLabel.isHidden = !self.samples.isEmpty
                self.mEventTable.reloadData()
            }
        }
    }
}


// MARK: - UITableViewDataSource
extension TrackerEventSampleViewController : UITableViewDataSource{
    private static let CELL_ID = "TrackerEventSampleViewCell"
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return samples.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.CELL_ID) as! TrackerEventSampleViewCell
        
        let sample = samples[indexPath.row]
        cell.setData(sample)
        
        return cell
    }
    
}

 
/// Table row showing an asyncronous event
public class TrackerEventSampleViewCell : UITableViewCell{
    
    /// event type
    @IBOutlet weak var mEventTypeIcon: UIImageView!
    
    /// event date
    @IBOutlet weak var mDateLabel: UILabel!
    
    /// acceleration during the event
    @IBOutlet weak var mAccLabel: UILabel!
    
    /// event name
    @IBOutlet weak var mEventListLabel: UILabel!
    
    /// orientation icon
    @IBOutlet weak var mOrientationIcon: UIImageView!
    
    
    /// return the first event that has not the value "orientation"
    ///
    /// - Parameter events: list of events
    /// - Returns: first event different from orientation
    private static func selectFirstNotOrientationEvent(_ events:[AccelerationEvent]) -> AccelerationEvent?{
        return events.first{ $0 != AccelerationEvent.orientation}
    }
        
    private func showAcclerationEvents(_ events: [AccelerationEvent]) {
        let eventStrings = events
            .map{ $0.description }
            .joined(separator: ", ")
        mEventListLabel.text = String(format: Self.EVENTS_FORMAT, eventStrings)
    }
    
    private func showOrientationEvent(_ orientation: SensorOrientation?) {
        if let image = orientation?.toImage{
            mOrientationIcon.image = image
            mOrientationIcon.isHidden = false
        }else{
            mOrientationIcon.isHidden = true;
        }
    }
    
    public func setData(_ data:EventDataSample) {
        mDateLabel.text = DateFormatter.full.string(from: data.date)
        //showAcceleration(data.acceleration)
        showAcclerationEvents(data.accelerationEvents)
        showOrientationEvent(data.currentOrientation)
        let event = Self.selectFirstNotOrientationEvent(data.accelerationEvents) ?? AccelerationEvent.orientation
        mEventTypeIcon.image = event.toImage
    }
    
    private static let EVENTS_FORMAT = {
        return  NSLocalizedString("Events: %@",
                                  tableName: nil,
                                  bundle: TrackerThresholdUtilBundle.bundle(),
                                  value: "Events: %@",
                                  comment: "Events: %@");
    }()
}
