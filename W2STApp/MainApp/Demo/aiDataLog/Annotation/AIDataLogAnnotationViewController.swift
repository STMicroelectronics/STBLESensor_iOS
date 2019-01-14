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

class AIDataLogAnnotationViewController : UIViewController, BlueSTSDKDemoViewProtocol{
    
    private static let INERT_LABEL_SEGUE = "aiDataLog_insertAnnotationSegue"
    
    private static let ERROR_TITLE = {
        return  NSLocalizedString("Error",
                                  tableName: nil,
                                  bundle: Bundle(for: AIDataLogAnnotationViewController.self),
                                  value: "Error",
                                  comment: "Error");
    }();
    
    private static let MISSING_SD_MSG = {
        return  NSLocalizedString("The node doesn't have the SD Card",
                                  tableName: nil,
                                  bundle: Bundle(for: AIDataLogAnnotationViewController.self),
                                  value: "The node doesn't have the SD Card",
                                  comment: "The node doesn't have the SD Card");
    }();
    
    private static let IO_ERROR_MSG = {
        return  NSLocalizedString("IO Error happen during the logging",
                                  tableName: nil,
                                  bundle: Bundle(for: AIDataLogAnnotationViewController.self),
                                  value: "IO Error happen during the logging",
                                  comment: "IO Error happen during the logging");
    }();
    
    private static let START_LOG_BUTTON = {
        return  NSLocalizedString("Start Log",
                                  tableName: nil,
                                  bundle: Bundle(for: AIDataLogAnnotationViewController.self),
                                  value: "Start Log",
                                  comment: "Start Log");
    }();
    
    private static let STOP_LOG_BUTTON = {
        return  NSLocalizedString("Stop Log",
                                  tableName: nil,
                                  bundle: Bundle(for: AIDataLogAnnotationViewController.self),
                                  value: "Stop Log",
                                  comment: "Stop Log");
    }();
    
    
    public var aiLoggingParameters:BlueSTSDKFeatureAILogging.Parameters!
    public var node: BlueSTSDKNode!
    public var menuDelegate: BlueSTSDKViewControllerMenuDelegate?
    
    private lazy var addLabelButton:UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showInsertLabel(_:)))
    }()
    
    @IBOutlet weak var annotationTableView: UITableView!
    @IBOutlet weak var mInsertAnnotationPlaceholder: UIView!
    @IBOutlet weak var mStartStopButton: UIButton!
    
    private let viewModel = AIDataLogAnnotationViewModel()
    
    override func viewDidLoad() {
        annotationTableView.dataSource = self
        annotationTableView.tableHeaderView = UIView(frame: CGRect.zero)
        annotationTableView.tableFooterView = UIView(frame: CGRect.zero)
        viewModel.onAnnotationsDataChanges = { [weak self] in
            self?.annotationTableView.reloadData()
        }
        viewModel.onMissingSDError = {[weak self] in
            self?.showMissingSDMessage()
        }
        viewModel.onIOError = {[weak self] in
            self?.showIOErrorMessage()
        }
        
        viewModel.onLogStart = {[weak self] in
            self?.showLogStartedView()
        }
        
        viewModel.onLogStop = {[weak self] in
            self?.showLogStoppedView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.start(with: self.node)
        showLogStoppedView()
        //in the ipad the demo navigation controller is in the foruground, so we have to add the button to it
        // on the iphone the naviagition contrtoller is hiddend and we add it to the main navigation controller...
        if(UIDevice.current.userInterfaceIdiom == .pad){
            navigationItem.rightBarButtonItem = addLabelButton
        }
        menuDelegate?.addBarButton(addLabelButton)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stop()
        menuDelegate?.removeBarButton(addLabelButton)
    }
    
    @objc public func showInsertLabel(_ sender:UIBarButtonItem){
        performSegue(withIdentifier: AIDataLogAnnotationViewController.INERT_LABEL_SEGUE, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AIDataLogInsertAnnotationViewController{
            destination.popoverPresentationController?.displayOnView(mInsertAnnotationPlaceholder)
            destination.onNewAnnotation = { [weak self] str in
                self?.viewModel.add(annotation: Annotation(label: str))
            }
        }
    }
    
    @IBAction func onStartStopButtonPressed(_ sender: UIButton) {
        viewModel.changeLogStatus(param: aiLoggingParameters)
    }
    
    private func showMissingSDMessage(){
        showAllert(title: AIDataLogAnnotationViewController.ERROR_TITLE,
                   message: AIDataLogAnnotationViewController.MISSING_SD_MSG,
                   closeController: false)
    }
    
    private func showIOErrorMessage(){
        showAllert(title: AIDataLogAnnotationViewController.ERROR_TITLE,
                   message: AIDataLogAnnotationViewController.IO_ERROR_MSG,
                   closeController: false)
    }
    
    private func showLogStartedView(){
        mStartStopButton.setTitle(AIDataLogAnnotationViewController.STOP_LOG_BUTTON, for: .normal)
    }
    
    private func showLogStoppedView(){
        mStartStopButton.setTitle(AIDataLogAnnotationViewController.START_LOG_BUTTON, for: .normal)
    }
    
}

extension AIDataLogAnnotationViewController : UITableViewDataSource{
    private static let cellTableIdentifier = "AIDataLogAnnotationViewCell"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.annotations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AIDataLogAnnotationViewController.cellTableIdentifier) as?
        AIDataLogAnnotationViewCell
        
        cell?.data=viewModel.annotations[indexPath.row]
        
        cell?.onDeleteAnnotationRequest = { [ weak self] annotation in
            self?.viewModel.remove(annotation: annotation)
        }
        
        cell?.onAnnotationSelected = { [ weak self] annotation in
            self?.viewModel.select(annotation: annotation.annotation)
        }
        
        cell?.onAnnotationDeselected = { [ weak self] annotation in
            self?.viewModel.deselect(annotation: annotation.annotation)
        }
        
        return cell!
    }
    
    
}
