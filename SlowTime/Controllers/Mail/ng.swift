import UIKit
import StoreKit


class IAPTestViewController: UIViewController ,SKProductsRequestDelegate, SKPaymentTransactionObserver{
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
    
    let VERIFY_RECEIPT_URL = "https://buy.itunes.apple.com/verifyReceipt"
    let ITMS_SANDBOX_VERIFY_RECEIPT_URL = "https://sandbox.itunes.apple.com/verifyReceipt"
    
    var productDict:NSMutableDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SKPaymentQueue.default().add(self)
        requestProducts()//请求产品列表资料
        
    }
    deinit{
        SKPaymentQueue.default().remove(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // 点击购买产品后触发的
    func onSelectRechargePackages(productId: String){
        //先判断是否支持内购
        if(SKPaymentQueue.canMakePayments()){
            buyProduct(product: productDict[productId] as! SKProduct)
        }
        else{
            DLog("============不支持内购功能")
        }
        
    }
    //询问苹果的服务器能够销售哪些商品
    func requestProducts(){
        let request = SKProductsRequest(productIdentifiers: ["com.vincross.cqm.yp1"])
        request.delegate = self
        request.start()
    }
    
    // 以上查询的回调函数
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if (productDict == nil) {
            productDict = NSMutableDictionary(capacity: response.products.count)
        }
        
        for product in response.products {
            // 激活了对应的销售操作按钮，相当于商店的商品上架允许销售
            DLog("=======Product id=======\(product.productIdentifier)")
            DLog("===产品标题 ==========\(product.localizedTitle)")
            DLog("====产品描述信息==========\(product.localizedDescription)")
            DLog("=====价格: =========\(product.price)")
            
            // 填充商品字典
            productDict.setObject(product, forKey: product.productIdentifier as NSCopying)
            
            
        }
    }
    // 购买对应的产品
    func buyProduct(product: SKProduct){
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    private func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!){
        // 调试
        for transaction in transactions {
            // 如果小票状态是购买完成
            if (SKPaymentTransactionState.purchased == transaction.transactionState) {
                // 更新界面或者数据，把用户购买得商品交给用户
                DLog("支付成了＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝")
                // 验证购买凭据
//                self.verifyPruchase()
                
                // 将交易从交易队列中删除
                SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                
            }
            else if(SKPaymentTransactionState.failed == transaction.transactionState){
                DLog("支付失败＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝")
                SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
            }
            else if (SKPaymentTransactionState.restored == transaction.transactionState) {//恢复购买
                // 更新界面或者数据，把用户购买得商品交给用户
                
                // 将交易从交易队列中删除
                SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
            }
            
        }
        
    }
    
    
//    func verifyPruchase(){
//        // 验证凭据，获取到苹果返回的交易凭据
//        // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
//        let receiptURL = Bundle.main.appStoreReceiptURL
//        // 从沙盒中获取到购买凭据
//        do {
//            let receiptData = try Data(contentsOf: receiptURL!)
//
//            // 发送网络POST请求，对购买凭据进行验证
//            let url = NSURL(string: ITMS_SANDBOX_VERIFY_RECEIPT_URL)
//            // 国内访问苹果服务器比较慢，timeoutInterval需要长一
//            let request = NSMutableURLRequest(url: url! as URL, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 10)
//            request.httpMethod = "POST"
//            // 在网络中传输数据，大多情况下是传输的字符串而不是二进制数据
//            // 传输的是BASE64编码的字符串
//            /**
//             BASE64 常用的编码方案，通常用于数据传输，以及加密算法的基础算法，传输过程中能够保证数据传输的稳定性
//             BASE64是可以编码和解码的
//             */
//            let encodeStr = receiptData.base64EncodedString(options: Data.Base64EncodingOptions.endLineWithLineFeed)
//
//            let payload = NSString(string: "{\"receipt-data\" : \"" + encodeStr + "\"}")
//            DLog(payload)
//            let payloadData = payload.data(using: String.Encoding.utf8.rawValue)
//
//            request.httpBody = payloadData;
//
//            // 提交验证请求，并获得官方的验证JSON结果
////            let result = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
//
//            // 官方验证结果为空
//            if (result == nil) {
//                //验证失败
//                DLog("验证失败")
//                return
//            }
//            var dict: AnyObject? = JSONSerialization.JSONObjectWithData(result!, options: NSJSONReadingOptions.AllowFragments, error: nil)
//            if (dict != nil) {
//                // 比对字典中以下信息基本上可以保证数据安全
//                // bundle_id&application_version&product_id&transaction_id
//                // 验证成功
//                DLog(dict)
//            }
//
//
//        } catch {
//            print(error)
//        }
//    }
    
    
    func restorePurchase(){
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}
