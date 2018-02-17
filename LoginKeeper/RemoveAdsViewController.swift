//
//  RemoveAdsViewController.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 1/20/18.
//  Copyright © 2018 Dusan Juranovic. All rights reserved.
//

import UIKit
import StoreKit

class RemoveAdsViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    //MARK: - Outlets
    @IBOutlet weak var versionConstraint: NSLayoutConstraint!
    @IBOutlet weak var purchasePremiumButton: UIButton!
    @IBOutlet weak var unlockText: UILabel!
    @IBOutlet weak var priceText: UILabel!
    @IBOutlet weak var versionText: UILabel!
    @IBOutlet weak var purchasedText: UILabel!
    //MARK: - Properties
    let reachability = Reachability()
    let PRODUCT_ID = "com.loginkeeper.removeads"
    var productID = ""
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    var premiumPurchased = UserDefaults.standard.bool(forKey: "premiumPurchased")
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //MARK: - App life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGradient()
        
        if premiumPurchased {
            purchasedView()
        } else {
            notPurchasedView()
            if reachability.isReachable() {
                fetchAvailableProducts()
            } else {
                connectionCheckAlert()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        SKPaymentQueue.default().remove(self)
    }
    
    override func viewWillLayoutSubviews() {
        for v in view.layer.sublayers! {
            if v .isKind(of: CAGradientLayer.self) {
                v.frame = view.bounds
            }
        }
    }
    
    //MARK: - Initial Views
    func purchasedView() {
        unlockText.text = removedAdsLocalized
        UIView.animate(withDuration: 1, delay: 0, options:[.repeat, .autoreverse], animations: {
            self.unlockText.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }, completion: nil)
        versionConstraint.constant = 50
        versionText.text = premiumVersionLocalized
        versionText.textColor = UIColor(red: 44/255, green: 152/255, blue: 41/255, alpha: 1)
        purchasePremiumButton.isHidden = true
        priceText.isHidden = true
        purchasedText.isHidden = true
    }
    
    func notPurchasedView() {
        unlockText.text = unlockPremiumTextLocalized
        versionText.text = basicVersionLocalized
        versionText.textColor = UIColor(red: 216/255, green: 67/255, blue: 35/255, alpha: 1)
        purchasedText.text = premiumVersionLockedLocalized
        purchasedText.textColor = UIColor(red: 216/255, green: 67/255, blue: 35/255, alpha: 1)
        purchasePremiumButton.isHidden = false
        priceText.isHidden = false
        purchasedText.isHidden = false
    }
    
    
    //MARK: - Purchase methods
    @IBAction func purchasePremium(_ sender: UIButton) {
        if reachability.isReachable() {
            if UserDefaults.standard.bool(forKey: "premiumPurchased") {
                let alert = UIAlertController(title: "LoginKeeper", message: alreadyPurchasedLocalized, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: okLocalized, style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            } else {
                for product in iapProducts {
                    if product.productIdentifier == PRODUCT_ID {
                        purchaseMyProduct(product: product)
                    } else {
                        print("No products yet")
                    }
                }
            }
        } else {
            let alert = UIAlertController(title: "LoginKeeper" , message: connectionCheckLocalized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: okLocalized, style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func restorePurchase(_ sender: UIBarButtonItem) {
        if reachability.isReachable() {
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().restoreCompletedTransactions()
        } else {
            connectionCheckAlert()
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        premiumPurchased = true
        UserDefaults.standard.set(premiumPurchased, forKey: "premiumPurchased")
        purchasedView()
        let alert = UIAlertController(title: "LoginKeeper", message: successfullyRestoredLocalized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okLocalized, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func fetchAvailableProducts() {
        let productIdentifiers = NSSet(objects: PRODUCT_ID)
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    func canMakePurchases() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func purchaseMyProduct(product: SKProduct) {
        if reachability.isReachable() {
            if self.canMakePurchases() {
                let payment = SKPayment(product: product)
                SKPaymentQueue.default().add(self)
                SKPaymentQueue.default().add(payment)
                productID = product.productIdentifier
            } else {
                let alert = UIAlertController(title: "LoginKeeper", message: cannotMakePurchaseLocalized, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: okLocalized, style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        } else {
            connectionCheckAlert()
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count > 0 {
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            iapProducts = response.products
            let removeAdsProduct = response.products[0]
            numberFormatter.locale = removeAdsProduct.priceLocale
            
            let price2Str = numberFormatter.string(from: removeAdsProduct.price)
            
            priceText.text = removeAdsProduct.localizedDescription + " \(price2Str!)"
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction: Any in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    if productID == PRODUCT_ID {
                        SKPaymentQueue.default().finishTransaction(trans)
                        premiumPurchased = true
                        UserDefaults.standard.set(premiumPurchased, forKey: "premiumPurchased")
                        purchasedView()
                        let alert = UIAlertController(title: "LoginKeeper", message: successfullyPurchasedLocalized, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: okLocalized, style: .default, handler: nil))
                        present(alert, animated: true, completion: nil)
                    }
                case .failed:
                    SKPaymentQueue.default().finishTransaction(trans)
                case .restored:
                    SKPaymentQueue.default().finishTransaction(trans)
                default:
                    break
                }
            }
        }
    }
    
    //MARK: - Connection Check
    func connectionCheckAlert() {
        let alert = UIAlertController(title: "LoginKeeper" , message: connectionCheckLocalized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okLocalized, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
