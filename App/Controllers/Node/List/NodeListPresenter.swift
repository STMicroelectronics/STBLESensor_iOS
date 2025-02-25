//
//  NodeListPresenter.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK
import STCore
import STDemos
import STCatalog
import STUserProfiling

final class NodeListPresenter: VoidPresenter<NodeListViewController> {

    static let defaultMinRSSI = -100

    var director: TableDirector?
    var minRSSI: Int = NodeListPresenter.defaultMinRSSI

    override func prepareSettingsMenu() {

        settingActions.removeAll()

        if var appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            
            if UserDefaults.standard.bool(forKey: "isBetaCatalogActivated") {
                appName += " (Beta)"
            }
            settingActions.append(SettingsAction(name: "\(appName) v\(STCore.appShortVersion)",
                                                 style: .default,
                                                 handler: { [weak self] in
                self?.view.present(
                    UINavigationController(rootViewController: AppInfoPresenter().start()),
                    animated: true
                )
            }))
        }

        if let sessionService: SessionService = Resolver.shared.resolve(),
           sessionService.permissions.contains(.addCustomFwDbEntry),
           !(Permission.addCustomFwDbEntry.isAuthenticationRequired) {
            settingActions.append(SettingsAction(name: Localizer.NodeList.Text.customFirmware.localized,
                                                 handler: {
                FilePicker.shared.pickFile(with: [ .bin ]) { [weak self] url in
                    guard let url = url else { return }
                    BlueManager.shared.updateCustomCatalog(with: url) { _, error in
                        self?.refresh()
                        if error == nil {
                            self?.showMessageAlert("Custom Firmware", "Custom Firmware DB Entry added.")
                        } else {
                            self?.showMessageAlert("WARNING", "Something went wrong. The selected file is not valid")
                        }
                    }
                }
            }))
        }

        if let sessionService: SessionService = Resolver.shared.resolve(),
           sessionService.permissions.contains(.addCustomDTDLEntry),
           !(Permission.addCustomDTDLEntry.isAuthenticationRequired) {
            settingActions.append(SettingsAction(name: Localizer.NodeList.Text.customDtdl.localized,
                                                 handler: {
                FilePicker.shared.pickFile(with: [ .bin ]) { [weak self] url in
                    guard let url = url else { return }
                    BlueManager.shared.updateCustomDtmi(with: url) { _, error in
                        self?.refresh()
                        if error == nil {
                            self?.showMessageAlert("Custom DTDL", "Custom DTDL entry added.")
                        } else {
                            self?.showMessageAlert("WARNING", "Something went wrong. The selected file is not valid")
                        }
                    }
                }
            }))
        }

        settingActions.append(SettingsAction(name: Localizer.NodeList.Action.changeProfile.localized,
                                             style: .default,
                                             handler: { [weak self] in
            self?.changeProfile()
        }))

        if let loginService: LoginService = Resolver.shared.resolve() {
            let actionName = loginService.isAuthenticated ?
            Localizer.NodeList.Action.logout.localized :
            Localizer.NodeList.Action.login.localized

            settingActions.append(SettingsAction(name: actionName,
                                                 style: .default,
                                                 handler: { [weak self] in
                self?.loginLogout()
            }))
        }

        settingActions.append(SettingsAction(name: "Privacy Policy",
                                             style: .default,
                                             handler: { [weak self] in
                self?.showPrivacyPolicy()
        }))

        settingActions.append(SettingsAction(name: "Appplication Source Code",
                                             style: .default,
                                             handler: { [weak self] in
                self?.showApplicationSourceCode()
        }))

        settingActions.append(SettingsAction(name: "About ST",
                                             style: .default,
                                             handler: { [weak self] in
                self?.showAboutST()
        }))

        if let sessionService: SessionService = Resolver.shared.resolve(),
           sessionService.permissions.contains(.addCustomFwDbEntry),
           !(Permission.addCustomFwDbEntry.isAuthenticationRequired) {
            settingActions.append(SettingsAction(name: Localizer.NodeList.Text.resetFwDB.localized,
                                                 style: .destructive,
                                                 handler: { [weak self] in
                BlueManager.shared.clearDB()
                self?.refresh()
            }))
        }

        super.prepareSettingsMenu()
    }
}

private extension NodeListPresenter {

    func showApplicationSourceCode() {
        if let url = URL(string: "https://github.com/STMicroelectronics/STBLESensor_iOS") {
            UIApplication.shared.open(url)
        }
    }

    func showPrivacyPolicy() {
        if let url = URL(string: "https://www.st.com/content/st_com/en/common/privacy-portal/corporate-privacy-statement.html") {
            UIApplication.shared.open(url)
        }
    }

    func showAboutST() {
        if let url = URL(string: "https://www.st.com/content/st_com/en/about/st_company_information/who-we-are.html") {
            UIApplication.shared.open(url)
        }
    }

    func changeProfile() {
        let profile = Profile(steps: [
            Step.stepOne,
            Step.stepTwo
        ]) { [weak self] profile in
            if let sessionService: SessionService = Resolver.shared.resolve() {

                let appMode: AppMode = profile.steps[0].options[0].isSelected ? .beginner : .expert
                let userTypeIndex = profile.steps[1].options.firstIndex(where: { $0.isSelected }) ?? 0

                let userType: UserType = UserType(rawValue: userTypeIndex) ?? .none

                sessionService.update(appMode: appMode, userType: userType)
                self?.prepareSettingsMenu()
            }

            self?.view.dismiss(animated: true)
        }

        self.view.present(UserProfilingPresenter(param: profile).start().embeddedInNav(), animated: true)
    }

    func loginLogout() {
        guard let loginService: LoginService = Resolver.shared.resolve() else { return }

        if loginService.isAuthenticated {
            loginService.resetAuthentication(from: view) { [weak self] success in
                self?.prepareSettingsMenu()
            }
        } else {
            loginService.authenticate(from: view) { [weak self] error in
                guard let self else { return }
                if let error = error {
                    UIAlertController.presentAlert(from: self.view,
                                                   title: Localizer.Common.warning.localized,
                                                   message: error.localizedDescription,
                                                   actions: [ UIAlertAction.genericButton() ])
                } else {
                    self.prepareSettingsMenu()
                }
            }
        }
    }
}

// MARK: - MainViewControllerDelegate
extension NodeListPresenter: NodeListDelegate {

    func load() {
        view.configureView()

        prepareSettingsMenu()

        view.mainView.noResultView.titleLabel.text = Localizer.Home.NoResultView.Text.title.localized
        view.mainView.noResultView.descriptionLabel.text = Localizer.Home.NoResultView.Text.description.localized

        Buttonlayout.standard.apply(to: view.mainView.noResultView.actionButton,
                                    text: "DISCOVER OUR PRODUCTS")

        view.mainView.noResultView.imageView.image = ImageLayout.image(with: "img_discover_no_result")
        view.mainView.noResultView.actionButton.on(.touchUpInside) { [weak self] _ in
            self?.view.navigationController?.pushViewController(
                BoardListPresenter(
                    param: BoardListConf(
                        nodeTypesFilter: nil,
                        firmwareNamesFilter: nil,
                        isDemoListVisible: true)
                ).start(),
                animated: true
            )
        }

        if director == nil {
            director = TableDirector(with: view.mainView.tableView)
            director?.register(viewModel: NodeViewModel.self, bundle: .main)
            director?.register(viewModel: GroupCellViewModel<[any ViewViewModel]>.self,
                               type: .fromClass,
                               bundle: STUI.bundle)
        }

        director?.onSelect({ [weak self] indexPath in
            Logger.debug(text: "\(indexPath.section) - \(indexPath.row)")

            if indexPath.row - 1 < 0 {
                return
            }

            guard let element = self?.director?.elements[indexPath.row] as? NodeViewModel,
                  let node = element.param else { return }

//            let node = BlueManager.shared.discoveredNodes[indexPath.row - 1]
            StandardHUD.shared.show(with: "\(Localizer.NodeList.Text.connecting.localized) \(node.name ?? "n/a")")
            BlueManager.shared.discoveryStop()
            BlueManager.shared.connect(node)
        })

        self.view.mainView.noResultView.isHidden = true
        refresh()
    }

    func refresh() {

        let layout = Layout.standard.text(textLayout: Layout.standard.textLayout?.alignment(.center))

        let viewModels = [ LabelViewModel(param: CodeValue<String>(keys: [ UUID().uuidString ],
                                                                   value: Localizer.NodeList.Text.welcome.localized),
                                          layout: layout) ]

        director?.elements.removeAll()
        director?.elements.append(GroupCellViewModel(childViewModels: viewModels,
                                                     layout: layout,
                                                     isCard: false))
        let nodes = BlueManager.shared.discoveredNodes
            .filter({ ($0.rssi ?? 0) >= self.minRSSI })
            .map({ NodeViewModel(param: $0) })

        director?.elements.append(contentsOf: nodes)
        director?.reloadData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self else { return }

            self.view.mainView.noResultView.isHidden = !BlueManager.shared.discoveredNodes.isEmpty
            self.view.mainView.tableView.isHidden = BlueManager.shared.discoveredNodes.isEmpty
        }
    }

    func show(_ node: Node) {
        view.navigationController?.show(DemoListPresenter(param: node).start(), sender: nil)
    }

    func showFilters() {
        view.present(NodeFilterPresenter(with: self.minRSSI,
                                         rssiChangeHandler: { [weak self] minRssi in
            self?.minRSSI = minRssi
            self?.updateNodes()
        }).start(), animated: true)
    }

    // swiftlint:disable:next function_body_length
    func updateNodes() {
        let nodes = BlueManager.shared.discoveredNodes
            .filter({ ($0.rssi ?? 0) >= self.minRSSI })

        var nodesToBeAdded = [Node]()

        nodes.forEach { [weak self] node in
            guard let self else { return }

            let found = self.director?.elements.first(where: { viewModel in
                if let model = viewModel as? NodeViewModel,
                   model.param == node {
                    return true
                } else {
                    return false
                }
            }) as? NodeViewModel

            if let found = found {
                found.param = node
            } else {
                nodesToBeAdded.append(node)
            }
        }

        guard let favoriteService: FavoritesService = Resolver.shared.resolve() else { return }

        // Add new favorite nodes

        let favoritesNodeViewModelsToBeAdded = nodesToBeAdded
            .filter({ favoriteService.isFavorite(node: $0) })
            .map({ NodeViewModel(param: $0) })

        if !favoritesNodeViewModelsToBeAdded.isEmpty {
            let indexes = favoritesNodeViewModelsToBeAdded
                .map { _ in IndexPath(row: 1, section: 0) }

            self.director?.elements.insert(contentsOf: favoritesNodeViewModelsToBeAdded, at: 1)
            self.director?.tableView?.insertRows(at: indexes, with: .fade)
        }

        // Add other new nodes

        let otherNodeViewModelsToBeAdded = nodesToBeAdded
            .filter({ !favoriteService.isFavorite(node: $0) })
            .map({ NodeViewModel(param: $0) })

        let startIndex = self.director?.elements.count ?? 0

        if !otherNodeViewModelsToBeAdded.isEmpty {
            let indexes = otherNodeViewModelsToBeAdded.enumerated()
                .map { $0.offset }
                .map { IndexPath(row: startIndex + $0, section: 0)}

            self.director?.elements.append(contentsOf: otherNodeViewModelsToBeAdded)
            self.director?.tableView?.insertRows(at: indexes, with: .fade)
        }

        // Remove nodes that not satisfy filter settings

        var indexPathsToBeRemoved = [IndexPath]()

        self.director?.elements.enumerated().forEach({ index, element in
            if let model = element as? NodeViewModel,
               let node = model.param,
               !nodes.contains(node) {
                indexPathsToBeRemoved.append(IndexPath(row: index, section: 0))
            }
        })

        if !indexPathsToBeRemoved.isEmpty {
            indexPathsToBeRemoved.map { $0.row }.forEach { [weak self] index in
                guard let self else { return }
                if let tableDirector = self.director {
                    if !tableDirector.elements.isEmpty {
                        if index <= tableDirector.elements.count - 1 {
                            tableDirector.elements.remove(at: index)
                        }
                    }
                }
            }

            self.director?.tableView?.deleteRows(at: indexPathsToBeRemoved, with: .fade)
        }

        // Update only visible cell to optimize tableview scrolling

        self.director?.configureVisibleCells()
    }

    private func showMessageAlert(_ title: String, _ message: String) {
        UIAlertController.presentAlert(
            from: self.view,
            title: title,
            message: message,
            actions: [
                UIAlertAction.genericButton(Localizer.Common.ok.localized) { _ in }
            ]
        )
    }

}
