//
//  TNTradeRecordsListController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/20.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import ReusableKit
import RxDataSources
import RxCocoa
import RxSwift
import IQKeyboardManagerSwift

class TNTradeRecordsListController: TNNavigationController {
    
    var wallet: TNWalletModel!
    
    let viewModel = TNTradeRecordViewModel()
    
    var dataSource: [TNTransactionRecord] = []
    
    var syncOperation = TNSyncWalletData()
    
    init(wallet: TNWalletModel) {
        super.init()
        self.wallet = wallet
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate lazy var tradeRecordHeaderview: TNTradeRecordHeaderview = {
        let tradeRecordHeaderview = TNTradeRecordHeaderview.tradeRecordHeaderview()
        return tradeRecordHeaderview
    }()
    
    fileprivate lazy var switchView: TNTradeRecordSwitchView = {
        let switchView = TNTradeRecordSwitchView.recordSwitchView()
        return switchView
    }()
    
    fileprivate lazy var listHeaderView: UIView = {
        let tableHeaderView = UIView()
        tableHeaderView.backgroundColor = kBackgroundColor
        tableHeaderView.frame = CGRect(x: 0, y: 0, width: kScreenW, height: 42)
        let titleLabel = UILabel()
        titleLabel.text = "Recent transaction records".localized
        titleLabel.textColor = UIColor.hexColor(rgbValue: 0x666666)
        titleLabel.font = UIFont.systemFont(ofSize: 14.0)
        titleLabel.sizeToFit()
        titleLabel.x = CGFloat(kLeftMargin)
        titleLabel.centerY = tableHeaderView.height * 0.5
        tableHeaderView.addSubview(titleLabel)
        return tableHeaderView
    }()
    
    let tableView = UITableView().then {
        $0.backgroundColor = UIColor.clear
        $0.tn_registerCell(cell: TNTradeRecordCell.self)
        $0.showsVerticalScrollIndicator = false
        $0.tableFooterView = UIView()
        $0.separatorStyle = .none
    }
    
    let emptyRecordsImgView = UIImageView().then {
        $0.image = UIImage(named: "no_records")
    }
    
    let emptyRecordsLabel = UILabel().then {
        $0.textColor = UIColor.hexColor(rgbValue: 0x8EA0B8)
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.text = "No records".localized
    }
    
    let containerView = UIView().then {
        $0.isHidden = false
        $0.backgroundColor = UIColor.clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        view.backgroundColor = kBackgroundColor
        switchView.receivingTransferrinrBlock = {[unowned self] in
            let vc = TNMyReceiveAddressController(wallet: self.wallet)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        switchView.transferAccountBlock = {[unowned self] in
            let vc = TNSendViewController(wallet: self.wallet)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        tradeRecordHeaderview.walletNameLabel.text = wallet.walletName
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
        updateData()
        
        setRefreshHeader()
        
        NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: TNDidFinishUpdateDatabaseNotification)).subscribe(onNext: {[unowned self] value in
            TNWalletBalanceViewModel().calculatBalance(self.wallet) { (walletModel) in
                self.wallet = walletModel
                self.updateData()
            }
        }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    
    fileprivate func updateData() {
        
        viewModel.queryTransactionRecordList(walletId: wallet.walletId) {[unowned self] (records) in
            self.tradeRecordHeaderview.walletModel = self.wallet
            self.dataSource = records.filter {
                return $0.action != .move
            }
            self.containerView.isHidden = self.dataSource.isEmpty ? false : true
            self.tableView.reloadData()
        }
    }
    
    deinit {
        syncOperation.syncWalletDataComlpetion = nil
    }
}



extension TNTradeRecordsListController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TNTradeRecordCell = tableView.tn_dequeueReusableCell(indexPath: indexPath)
        cell.model = dataSource[indexPath.row]
        cell.lineView.isHidden = indexPath.row == tableView.numberOfRows(inSection: 0) - 1 ? true : false
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = TNTransactiondDetailController(detailModel: dataSource[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension TNTradeRecordsListController {
    
    fileprivate func setRefreshHeader() {
        
        tableView.gtm_addRefreshHeaderView(refreshHeader: TNRefreshHeader()) {
            [weak self] in
            self?.pullTorefresh()
        }
    }
    
    func pullTorefresh() {
        let homeVC = navigationController?.viewControllers.first as! TNWalletHomeController
        if syncOperation.isLoading || homeVC.syncOperation.isLoading {
            endRefresing()
            return
        }
        syncOperation.isRefresh = true
        syncOperation.syncWalletDataComlpetion = {[unowned self] in
            self.endRefresing()
        }
        syncOperation.syncWalletsData(wallets: [wallet])
    }
    
    func endRefresing() {
        tableView.endRefreshing(isSuccess: true)
    }
}

extension TNTradeRecordsListController {
    
    fileprivate func setupUI() {
        view.addSubview(tradeRecordHeaderview)
        tradeRecordHeaderview.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(180)
        }
        
        view.addSubview(switchView)
        switchView.snp.makeConstraints { (make) in
            make.top.equalTo(tradeRecordHeaderview.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(70)
        }
        
        view.addSubview(listHeaderView)
        listHeaderView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(switchView.snp.bottom)
            make.height.equalTo(42)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(listHeaderView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kSafeAreaBottomH)
        }
        
        view.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerX.equalTo(tableView.snp.centerX)
            make.centerY.equalTo(tableView.snp.centerY)
            make.height.equalTo(116)
        }
        
        containerView.addSubview(emptyRecordsImgView)
        emptyRecordsImgView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        containerView.addSubview(emptyRecordsLabel)
        emptyRecordsLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }

}
