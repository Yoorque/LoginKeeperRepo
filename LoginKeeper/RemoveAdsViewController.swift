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
    
    @IBOutlet weak var purchasePremiumButton: UIButton!
    @IBOutlet weak var unlockText: UILabel!
    @IBOutlet weak var priceText: UILabel!
    @IBOutlet weak var versionText: UILabel!
    @IBOutlet weak var purchasedText: UILabel!
    let reachability = Reachability()
    
    let PRODUCT_ID = "com.loginkeeper.removeads"
    var productID = ""
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    var premiumPurchased = UserDefaults.standard.bool(forKey: "premiumPurchased")
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    func purchasedView() {
        unlockText.text = removedAdsLocalized
        purchasedText.text = premiumVersionPurchasedLocalized
        purchasedText.textColor = UIColor(red: 44/255, green: 152/255, blue: 41/255, alpha: 1)
        purchasedText.font = UIFont(name: "Zapf Dingbats", size: 22)
        NSLayoutConstraint(item: purchasedText, attribute: .top, relatedBy: .equal, toItem: versionText, attribute: .bottom, multiplier: 1, constant: 8).isActive = true
        versionText.text = premiumVersionLocalized
        versionText.textColor = UIColor(red: 44/255, green: 152/255, blue: 41/255, alpha: 1)
        purchasePremiumButton.isHidden = true
        priceText.isHidden = true
    }
    
    func notPurchasedView() {
        priceText.isHidden = false
        unlockText.text = unlockPremiumTextLocalized
        versionText.text = basicVersionLocalized
        versionText.textColor = UIColor(red: 216/255, green: 67/255, blue: 35/255, alpha: 1)
        purchasedText.text = premiumVersionLockedLocalized
        purchasedText.textColor = UIColor(red: 216/255, green: 67/255, blue: 35/255, alpha: 1)
        purchasePremiumButton.isHidden = false
    }
    
    @IBAction func purchasePremium(_ sender: UIButton) {
        if reachability.isReachable() {
            if UserDefaults.standard.bool(forKey: "premiumPurchased") {
                let alert = UIAlertController(title: "LoginKeeper", message: alreadyPurchasedLocalized, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: okLocalized, style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            } else {
                purchaseMyProduct(product: iapProducts[0])
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
        
        if self.canMakePurchases() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            productID = product.productIdentifier
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
    
    func connectionCheckAlert() {
        let alert = UIAlertController(title: "LoginKeeper" , message: connectionCheckLocalized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okLocalized, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
