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
//import StoreKit

class StampListController: UIViewController {
    
    @IBOutlet weak var payBtn: UIButton!
    
    private var stamps: [Stamp]?
    
    let disposeBag = DisposeBag()

    @IBOutlet weak var stampListCollectionView: UICollectionView!
    
    @IBAction func disAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
//        let request = SKProductsRequest(productIdentifiers: ["1111"])
//        request.delegate = self
//        request.start()
        
        
        payBtn.rx.tap
            .throttle(1, scheduler: MainScheduler.instance)
            .bind { [unowned self] in
                self.calculate()
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
        var totalPrice: Int = 0
        var stampOrders: [[String: String]] = [[String: String]]()
        for i in 0..<stamps!.count {
            let cell = stampListCollectionView.cellForItem(at: IndexPath(item: i, section: 0)) as! StampListCell
            if cell.stampCount.value > 0 {
                totalPrice += cell.stampCount.value * (cell.stamp?.price!)!
                stampOrders.append(["stampId": (cell.stamp?.id)!, "count": "\(cell.stampCount.value)"])
            }
        }
        HUD.show(.label("正在支付\(totalPrice)元？"))
        
        let provider = MoyaProvider<Request>()
        provider.rx.request(.orderStamp(stamps: stampOrders))
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode()
            .bind(onNext: { [weak self] (json) in
                HUD.flash(.success, delay: 1.0)
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
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


//extension StampListController: SKProductsRequestDelegate {
//    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
//        DLog(response.products)
//        DLog(response.invalidProductIdentifiers)
//    }
//    
//    
//    
//}

