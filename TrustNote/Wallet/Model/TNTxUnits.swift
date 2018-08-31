//
//  TNTxUnits.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/3.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import Foundation
import RxDataSources
import HandyJSON

enum TNTransactionAction: String {
    case invalid = "INVALID"
    case sent = "SENT"
    case move = "MOVED"
    case received = "RECEIVED"
}

struct TNTxUnits {
    var plus: Int64 = 0
    var has_minus: Bool = false
    var unit: String = ""
    var level: Int32 = 0
    var is_stable: Bool = true
    var sequence: String = ""
    var address: String = ""
    var ts: Int64 = 0
    var fee: Int32 = 0
    var amount: Int64 = 0
    var to_address: String?
    var from_address: String?
    var mci: Int32 = 0
    var arrMyRecipients: [[String : Any]] = []
}

struct TNTransactionRecord {
    
    var action: TNTransactionAction?
    var amount: Int64?
    var my_address: String?
    var addressTo: String?
    var confirmations: Bool = false
    var unit: String = ""
    var fee: Int32 = 0
    var time: Int64 = 0
    var level: Int32 = 0
    var mci: Int32 = 0
    var arrPayerAddresses: [String] = []
}

struct TNTxoutputs {
    var address: String?
    var amount: Int64?
    var is_external: Bool = false
}

struct TNParentsUnit: HandyJSON {
    var parent_units: [String]?
    var last_stable_mc_ball: String = ""
    var last_stable_mc_ball_unit: String = ""
    var last_stable_mc_ball_mci: Int = 0
    var witness_list_unit: String = ""
}

struct TNPaymentInfo {
    var walletId: String = ""
    var walletPubkey: String = ""
    var receiverAddress: String = ""
    var amount: String = ""
    var lastBallMCI: Int = 0
}

struct TNFundedAddress {
    var address: String = ""
    var total: Int64 = 0
}

struct TNOutputObject {
    var unit: String = ""
    var messageIndex: Int = 0
    var outputIndex: Int = 0
    var amount: Int64 = 0
    var address: String = ""
}

//extension TNRecordSection: SectionModelType {
//
//    typealias Item = TNTransactionRecord
//
//    init(original: TNRecordSection, items: [Item]) {
//        self = original
//        self.items = items
//    }
//
//    init(items: [Item]?) {
//        self.items = items ?? [Item]()
//    }
//}
