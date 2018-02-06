//
//  StampListController.swift
//  SlowTime
//
//  Created by KKING on 2018/1/4.
//  Copyright © 2018年 KKING. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import PKHUD
import StoreKit

extension Notification.Name {
    static let calculate = Notification.Name("calculate")
}

class StampListController: UIViewController {
    
    @IBOutlet weak var payBtn: UIButton!
    @IBOutlet weak var total: UILabel!
    
    private var stamps: [Stamp]?
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var stampListCollectionView: UICollectionView!
    
    @IBAction func disAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    let VERIFY_RECEIPT_URL = "https://buy.itunes.apple.com/verifyReceipt"
    let ITMS_SANDBOX_VERIFY_RECEIPT_URL = "https://sandbox.itunes.apple.com/verifyReceipt"
    
    private var productDict: NSMutableDictionary!
    private var prices: [Int] = []
    private var stampOrders: [[String: String]] = [[String: String]]()
    
    
    private var totalPrice: Int = 0
    private var totalCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(forName: .calculate, object: nil, queue: .main) { [weak self] (_) in
            self?.calculate()
        }
        
        
        // 请求产品
        SKPaymentQueue.default().add(self)
        let request = SKProductsRequest(productIdentifiers: [
            "com.vincross.cqm.yp1",
            "com.vincross.cqm.yp3",
            "com.vincross.cqm.yp6",
            "com.vincross.cqm.yp8",
            "com.vincross.cqm.yp12",
            "com.vincross.cqm.yp18",
            "com.vincross.cqm.yp25",
            "com.vincross.cqm.yp28",
            "com.vincross.cqm.yp30",
            "com.vincross.cqm.yp40",
            "com.vincross.cqm.yp45",
            "com.vincross.cqm.yp50"
            ])
        request.delegate = self
        request.start()
        HUD.show(.progress)
        
        
        payBtn.rx.tap
            .throttle(1, scheduler: MainScheduler.instance)
            .bind { [unowned self] in
                self.buy()
            }
            .disposed(by: disposeBag)
        
        
        
        let provider = MoyaProvider<Request>()
        provider.rx.requestWithLoading(.stamps)
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode()
            .flatMap(to: Stamp.self)
            .subscribe { [weak self] (event) in
                if case .next(let stamps) = event {
                    self?.stamps = stamps
                    DispatchQueue.main.async {
                        self?.stampListCollectionView.reloadData()
                    }
                }else if case .error = event {
                    DLog("请求超时")
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func calculate() {
        totalCount = 0
        totalPrice = 0
        stampOrders.removeAll()
        
        for i in 0..<stamps!.count {
            let cell = stampListCollectionView.cellForItem(at: IndexPath(item: i, section: 0)) as! StampListCell
            if cell.stampCount.value > 0 {
                totalCount += cell.stampCount.value
                totalPrice += cell.stampCount.value * (cell.stamp?.price!)!
                stampOrders.append(["stampId": (cell.stamp?.id)!, "count": "\(cell.stampCount.value)"])
            }
        }
        total.text = "共 \(totalCount) 元"
        payBtn.isEnabled = totalCount != 0 ? true : false
    }
    
    private func buy() {
        
        if totalCount == 0 || totalCount > 50 || prices.count == 0 { return }
        
        if prices.contains(where: { $0 == totalCount }) {
            self.onSelectRechargePackages(productId: "com.vincross.cqm.yp\(totalCount)")
        }else {
            prices.append(totalCount)
            prices.sort(by: {$0 < $1})
            
            let countIndex = prices.index(of: totalCount)?.hashValue
            
            let alert = CQMAlert(title: "Apple Pay 的档位设置不允许支付\(totalCount)元，你可以加上\(prices[countIndex!+1]-totalCount)张凑\(prices[countIndex!+1])张，或减\(totalCount-prices[countIndex!-1])张凑\(prices[countIndex!-1])张。")
            let confirmAction = AlertOption(title: "好的", type: .normal, action: { [weak self] in
                self?.prices.remove((self?.totalCount)!)
            })
            alert.addAlertOptions([confirmAction])
            alert.show()
        }
    }
    
    
    deinit{
        NotificationCenter.default.removeObserver(self)
        SKPaymentQueue.default().remove(self)
    }
    
    
    // 点击购买产品后触发的
    func onSelectRechargePackages(productId: String){
        //先判断是否支持内购
        if(SKPaymentQueue.canMakePayments()){
            let payment = SKPayment(product: productDict[productId] as! SKProduct)
            SKPaymentQueue.default().add(payment)
        }
        else{
            DLog("============不支持内购功能")
        }
    }
}



extension StampListController: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    // 查询的回调函数
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if (productDict == nil) {
            productDict = NSMutableDictionary(capacity: response.products.count)
        }
        prices.removeAll()
        for product in response.products {
            // 激活了对应的销售操作按钮，相当于商店的商品上架允许销售
            DLog("=======Product id=======\(product.productIdentifier)")
            DLog("===产品标题 ==========\(product.localizedTitle)")
            DLog("====产品描述信息==========\(product.localizedDescription)")
            DLog("=====价格: =========\(product.price)")
            
            // 填充商品字典            
            productDict.setObject(product, forKey: product.productIdentifier as NSCopying)
            prices.append(Int(truncating: product.price))
        }
        HUD.hide()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        // 调试
        for transaction in transactions {
            // 如果小票状态是购买完成
            if (SKPaymentTransactionState.purchased == transaction.transactionState) {
                // 更新界面或者数据，把用户购买得商品交给用户
//                HexaHUD.show(with: "支付成功")
                // 验证购买凭据
                // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
                let receiptURL = Bundle.main.appStoreReceiptURL
                // 从沙盒中获取到购买凭据
                do {
                    let receiptData = try Data(contentsOf: receiptURL!)
                    
                    let encodeStr = receiptData.base64EncodedString(options: Data.Base64EncodingOptions.endLineWithLineFeed)
                    
                    let provider = MoyaProvider<Request>()
                    provider.rx.request(.orderStamp(receipt: encodeStr, stamps: stampOrders))
                        .asObservable()
                        .mapJSON()
                        .filterSuccessfulCode()
                        .bind(onNext: { [weak self] (json) in
                            HexaHUD.show(with: "购买邮票成功")
                            self?.dismiss(animated: true, completion: nil)
                        })
                        .disposed(by: disposeBag)
                    
                } catch {
                    print(error)
                }
                
                // 将交易从交易队列中删除
                SKPaymentQueue.default().finishTransaction(transaction)
            }
            else if(SKPaymentTransactionState.failed == transaction.transactionState){
                DLog("支付失败")
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
}


extension StampListController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stamps?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stampListCell", for: indexPath) as! StampListCell
        cell.stamp = stamps?[indexPath.row]
        return cell
    }
    
}

