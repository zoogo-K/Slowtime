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
import Kingfisher
import PKHUD

class PackToSendController: BaseViewController {
    
    @IBOutlet weak var mailViewTimeLbl: UILabel!
    @IBOutlet weak var mailViewFromUserlbl: UILabel!
    @IBOutlet weak var mailViewMaillbl: UILabel!
    
    @IBOutlet weak var mailViewFromUserZip: UILabel!
    @IBOutlet weak var mailViewToUserZip: UILabel!
    
    
    @IBOutlet weak var mailView: UIView!
    
    @IBOutlet weak var enevlopeTopImg: UIImageView! {
        didSet {
            enevlopeTopImg.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        }
    }
    
    
    @IBOutlet weak var envelopeBottomViewStamp: UIImageView!
    @IBOutlet weak var envelopeBottomViewYouchuo: UIImageView!
    
    @IBOutlet weak var enevlopeBottomViewTouserlbl: UILabel!
    @IBOutlet weak var enevlopeBottomViewfromuserlbl: UILabel!
    @IBOutlet weak var enevlopeBottomView: UIView!
    
    @IBOutlet weak var enevlopBTopCons: NSLayoutConstraint!
    
    private var stamps: [Stamp] = [Stamp]()
    private var hasDrag: Bool = false
    
    private var canAnimation: Bool = false
    
    
    private var mailImagePointY: CGFloat = 0
    private var mailImageIdentyY: CGFloat = 0
    
    var mail: Mail?
    
    @IBOutlet weak var stampCollectionView: UICollectionView!
    
    @IBOutlet weak var statusLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mailViewMaillbl.text = mail?.content
        mailViewTimeLbl.text = mail?.updateTime?.StringFormartTime()
        mailViewFromUserlbl.text = mail?.fromUser?.nickname
        mailViewFromUserZip.text = mail?.fromUser?.zipCode
        mailViewToUserZip.text = mail?.toUser?.zipCode?.StringToZipCode()
        
        
        enevlopeBottomViewTouserlbl.text = "\(String(describing: mail?.toUser?.nickname ?? "")) 收"
        enevlopeBottomViewfromuserlbl.text = "\(String(describing: mail?.fromUser?.nickname ?? "")) 寄"
        
        
        navBar.barBackgroundImage = UIImage(color: .clear)
        navBar.backgroundColor = .clear
        navBar.wr_setBottomLineHidden(hidden: true)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mailImageIdentyY = mailView.y
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

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
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: view)
            if mailView.frame.contains(point) {
                mailImagePointY = point.y
            }
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: view)
            if mailView.frame.contains(point) {
                if mailView.frame.maxY < enevlopeBottomView.frame.maxY - 30 {
                    mailView.y = point.y - mailImagePointY
                } else {
                    canAnimation = true
                }
            }
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if canAnimation {
            enevlopeAnimation()
        }else {
            mailView.y = mailImageIdentyY
        }
    }
    
    
    private func enevlopeAnimation() {
        UIView.animate(withDuration: 0.5, animations: {
            self.mailView.isHidden = true
            self.enevlopeTopImg.layer.transform = CATransform3DMakeRotation(CGFloat.pi/2, 1, 0, 0)
        }){(finished) in
            self.enevlopeTopImg.isHidden = true
            self.statusLbl.text = "请选择邮票"
            
            UIView.animate(withDuration: 0.5, animations: {
                self.enevlopBTopCons.constant = 190
                self.view.layoutIfNeeded()
            }, completion: { (fin) in
                self.hasDrag = true
            })
        }
    }
    
    
    
    private func sendMailRequest(stampId: String, mailID: String) {
        let provider = MoyaProvider<Request>()
        provider.rx.requestWithLoading(.sendMail(stampId: stampId, mailId: mailID))
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode()
            .bind(onNext: { [weak self] (json) in
                self?.enevlopBTopCons.constant = -20
                UIView.animate(withDuration: 0.5, animations: {
                    self?.view.layoutIfNeeded()
                    self?.enevlopeBottomView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                    self?.enevlopeBottomView.alpha = 0.5
                }, completion: { (fin) in
                    if (self?.navigationController?.viewControllers.contains(where: { $0 is MailListController }))! {
                        for vc in (self?.navigationController?.viewControllers)! {
                            if vc is MailListController {
                                self?.navigationController?.popToViewController(vc, animated: true)
                            }
                        }
                    }else {
                        self?.navigationController?.popToRootViewController(animated: true)
                    }
                })
            })
            .disposed(by: disposeBag)
    }
}

extension PackToSendController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stamps.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.item < stamps.count else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stampCell", for: indexPath) as! MyStampCell
            cell.iconImg.image = RI.add_stamp()
            cell.countLbl.isHidden = true
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stampCell", for: indexPath) as! MyStampCell
        cell.stamp = stamps[indexPath.row]
        cell.countLbl.isHidden = false
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < stamps.count else {
            present(R.storyboard.mail().instantiateViewController(withIdentifier: "StampListController"), animated: true, completion: nil)
            return
        }
        
        if !hasDrag { return }
        
        // 隐藏返回按钮，禁用左滑返回
        navBar.wr_setLeftButton(title: "", titleColor: .black)
        view.isUserInteractionEnabled = false
        
        // 获取当前点击的cell
        let cell = collectionView.cellForItem(at: indexPath) as! MyStampCell
        
        // 坐标系转换，获得cell相对于view的坐标
        let point = collectionView.convert(cell.frame.origin, to: view)
        
        // 创建一个新的imageView
        let stampImageView = UIImageView()
        
        // 设置图片
        stampImageView.kf.setImage(with: ImageResource(downloadURL: URL(string: (cell.stamp?.icon)!) ?? URL(string: "")!), placeholder: RI.stamp())
        // envelopeBottomViewStamp设置图片
        envelopeBottomViewStamp.kf.setImage(with: ImageResource(downloadURL: URL(string: (cell.stamp?.icon)!) ?? URL(string: "")!), placeholder: RI.stamp())
        
        // 设置其frame
        stampImageView.frame = CGRect(x: point.x, y: point.y, width: envelopeBottomViewStamp.width, height: envelopeBottomViewStamp.height)
        
        // 添加到view上
        view.addSubview(stampImageView)
        
        collectionView.isHidden = true
        statusLbl.isHidden = true
        
        // envelopeBottomViewStamp相对于view的frame
        let ebvStampFrame = enevlopeBottomView.convert(envelopeBottomViewStamp.origin, to: view)
        
        UIView.animate(withDuration: 1, animations: {
            // 邮票移动动画
            stampImageView.transform = CGAffineTransform(translationX: ebvStampFrame.x - stampImageView.x, y: ebvStampFrame.y - stampImageView.y)
        }) { (fin) in
            // 显示envelopeBottomViewStamp，隐藏stampImageView
            self.envelopeBottomViewStamp.isHidden = false
            stampImageView.isHidden = true
            stampImageView.removeFromSuperview()
            
            // 邮戳动画
            self.envelopeBottomViewYouchuo.isHidden = false
            
            UIView.animate(withDuration: 0.3, animations: {
                self.envelopeBottomViewYouchuo.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
            }, completion: { (fin) in
                UIView.animate(withDuration: 0.3, animations: {
                    self.envelopeBottomViewYouchuo.transform = CGAffineTransform.identity
                }, completion: { (fin) in
                    self.sendMailRequest(stampId: self.stamps[indexPath.row].id!, mailID: (self.mail?.id)!)
                })
            })
        }
    }
    
}
