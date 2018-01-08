//
//  PackToSendController.swift
//  SlowTime
//
//  Created by KKING on 2017/12/28.
//  Copyright © 2017年 KKING. All rights reserved.
//

import UIKit
import Moya
import RxSwift

class PackToSendController: UIViewController {
    
    @IBOutlet weak var mailView: UIView!
    
    private var mailImagePointY: CGFloat = 0
    private var mailImageIdentyY: CGFloat = 0
    
    
    @IBOutlet weak var enevlopeTopImg: UIImageView! {
        didSet {
            enevlopeTopImg.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        }
    }
    @IBOutlet weak var enevlopeBottomView: UIView!
    
    @IBOutlet weak var enevlopBTopCons: NSLayoutConstraint!
    
    private var stamps: [Stamp]?
    
    var mailId: String = ""
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var stampCollectionView: UICollectionView!
    
    @IBAction func disAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var statusLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let provider = MoyaProvider<Request>()
        provider.rx.requestWithLoading(.userStamp)
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode()
            .flatMap(to: Stamp.self)
            .subscribe { [weak self] (event) in
                if case .next(let stamps) = event {
                    self?.stamps = stamps
                    DispatchQueue.main.async {
                        self?.stampCollectionView.reloadData()
                    }
                }else if case .error = event {
                    DLog("请求超时")
                }
            }
            .disposed(by: disposeBag)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mailImageIdentyY = mailView.y
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: view)
            if mailView.frame.contains(point) {
                mailImagePointY = point.y
            } else if (stampCollectionView.superview?.frame.contains(point))! {
                DLog(point)
                DLog(view.convert(point, to: stampCollectionView))
                
                stampCollectionView.cellForItem(at: IndexPath(row: 0, section: 0))?.center = point
            }
            
            
            
            
            
            
            
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: view)
            if mailView.frame.contains(point) {
                mailView.y = point.y - mailImagePointY
            } else if stampCollectionView.frame.contains(point) {
                stampCollectionView.cellForItem(at: IndexPath(row: 0, section: 0))?.center = point
            }
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: view)
            
            if enevlopeBottomView.frame.contains(point) {
                mailView.isHidden = true
                enevlopeAnimation()
            } else {
                mailView.y = mailImageIdentyY
            }
        }
    }
    
    
    
    private func enevlopeAnimation() {
        UIView.animate(withDuration: 0.5, animations: {
            self.enevlopeTopImg.layer.transform = CATransform3DMakeRotation(CGFloat.pi/2, 1, 0, 0)
        }){(finished) in
            self.enevlopeTopImg.isHidden = true
            self.statusLbl.text = "请选择邮票"
            UIView.animate(withDuration: 0.5, animations: {
                self.enevlopBTopCons.constant = 190
                self.view.layoutIfNeeded()
            })
        }
    }
    
    
    
    private func sendMailRequest(stampId: String, mailID: String) {
        let provider = MoyaProvider<Request>()
        provider.rx.requestWithLoading(.sendMail(stampId: stampId, mailID: mailID))
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode()
            .bind(onNext: { [weak self] (json) in
                self?.enevlopBTopCons.constant = 0
                UIView.animate(withDuration: 1, animations: {
                    self?.view.layoutIfNeeded()
                }, completion: { (fin) in
                    self?.dismiss(animated: true, completion: nil)
                })
            })
            .disposed(by: disposeBag)
    }
}

extension PackToSendController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stamps?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stampCell", for: indexPath) as! MyStampCell
        cell.stamp = stamps?[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == (stamps?.count)! - 1 {
            present(R.storyboard.mail().instantiateViewController(withIdentifier: "StampListController"), animated: true, completion: nil)
        }else {
            let stampImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 108))
            stampImageView.image = RI.stamp()
            view.addSubview(stampImageView)
            
            collectionView.isHidden = true
            statusLbl.isHidden = true
            
            
            UIView.animate(withDuration: 1, animations: {
                stampImageView.transform = CGAffineTransform(translationX: 280, y: 180)
            }) { (fin) in
                self.sendMailRequest(stampId: self.stamps![indexPath.row].id!, mailID: self.mailId)
            }
        }
    }
}
