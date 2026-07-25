//
//  IAPManager.swift
//  BypassIAPTestApp
//
//  Vulnerability #1: "Receipt validation missing".
//
//  This manager uses the classic StoreKit 1 payment queue and unlocks the
//  premium entitlement based purely on `SKPaymentTransaction.transactionState`.
//  It NEVER validates the App Store receipt (locally or server-side), so any
//  runtime hook that forces `-[SKPaymentTransaction transactionState]` to
//  return `.purchased` (raw value 1) will unlock premium for free.
//

import Combine
import Foundation
import StoreKit

@MainActor
final class IAPManager: NSObject, ObservableObject {

    /// Must match the product identifier declared in `Products.storekit`.
    static let premiumProductID = "com.izmcm.BypassIAPTestApp.premium"

    @Published var product: SKProduct?
    @Published var isPremiumUnlocked = false
    @Published var statusMessage = "Premium locked"

    private var productsRequest: SKProductsRequest?

    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        fetchProduct()
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }

    /// Loads the product metadata from the store (or the local StoreKit config).
    func fetchProduct() {
        let request = SKProductsRequest(productIdentifiers: [Self.premiumProductID])
        request.delegate = self
        request.start()
        productsRequest = request
    }

    /// Starts a purchase for the premium product.
    func buyPremium() {
        guard let product else {
            statusMessage = "Product not loaded yet"
            return
        }
        statusMessage = "Purchasing…"
        SKPaymentQueue.default().add(SKPayment(product: product))
    }

    /// Local reset so the vulnerability can be tested with and without the tweak.
    func resetForTesting() {
        isPremiumUnlocked = false
        statusMessage = "Premium locked"
    }
}

extension SKProduct {
    /// The product price formatted in its own locale, e.g. "$0.99".
    var localizedPriceString: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)
    }
}

extension IAPManager: SKProductsRequestDelegate {
    nonisolated func productsRequest(_ request: SKProductsRequest,
                                     didReceive response: SKProductsResponse) {
        let loaded = response.products.first
        Task { @MainActor in
            self.product = loaded
            if loaded == nil {
                self.statusMessage = "Product not available"
            }
        }
    }
}

extension IAPManager: SKPaymentTransactionObserver {
    nonisolated func paymentQueue(_ queue: SKPaymentQueue,
                                  updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            // VULNERABILITY: the app trusts `transaction.transactionState` and never
            // verifies the receipt. A tweak hooking -[SKPaymentTransaction transactionState]
            // to always return .purchased (1) will unlock premium without paying.
            switch transaction.transactionState {
            case .purchased, .restored:
                queue.finishTransaction(transaction)
                Task { @MainActor in
                    self.isPremiumUnlocked = true
                    self.statusMessage = "Premium unlocked (no receipt check)"
                }
            case .failed:
                queue.finishTransaction(transaction)
                Task { @MainActor in
                    self.statusMessage = "Purchase failed"
                }
            case .deferred, .purchasing:
                break
            @unknown default:
                break
            }
        }
    }
}
