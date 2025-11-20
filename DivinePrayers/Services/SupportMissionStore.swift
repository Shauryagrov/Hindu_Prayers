//
//  SupportMissionStore.swift
//  DivinePrayers
//
//  Created by GPT-5 Codex on 11/10/25.
//

import Foundation
import OSLog
import StoreKit

@MainActor
final class SupportMissionStore: ObservableObject {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "DivinePrayers",
        category: "SupportMissionStore"
    )
    enum SupportProduct: String, CaseIterable {
        case small = "tip_small_fresh"
        case medium = "tip_medium_fresh"
        case large = "tip_large_fresh"
    }
    
    enum SupportError: Error, LocalizedError {
        case productsNotLoaded
        case purchaseInProgress
        
        var errorDescription: String? {
            switch self {
            case .productsNotLoaded:
                return "We couldn’t reach the App Store. Please try again."
            case .purchaseInProgress:
                return "A purchase is already in progress."
            }
        }
    }
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    private let productIDs = SupportProduct.allCases.map(\.rawValue)
    
    private var purchaseTask: Task<Void, Never>?
    private let purchasedDefaultsKey = "SupportMissionStore.PurchasedProductIDs"
    
    init() {
        loadCachedPurchases()
        listenForTransactions()
    }
    
    func loadProducts() async {
        guard !isLoading else {
            Self.logger.debug("Skipping loadProducts because a load is already in progress.")
            return
        }
        isLoading = true
        errorMessage = nil
        
        let idsToLoad = self.productIDs
        print("🔍 [SupportMissionStore] Starting loadProducts with IDs: \(idsToLoad)")
        Self.logger.debug("Requesting products with IDs: \(idsToLoad)")
        
        #if targetEnvironment(simulator)
        print("📱 [SupportMissionStore] Running in SIMULATOR environment")
        #else
        print("📱 [SupportMissionStore] Running on DEVICE environment")
        #endif
        
        do {
            print("⏳ [SupportMissionStore] Calling Product.products(for:)...")
            let storeProducts = try await Product.products(for: idsToLoad)
            print("✅ [SupportMissionStore] Product.products returned \(storeProducts.count) items")
            
            for product in storeProducts {
                print("   - Found: \(product.id) (\(product.displayName)) Price: \(product.displayPrice)")
            }
            
            let sortedProducts = storeProducts.sorted { $0.price < $1.price }
            products = sortedProducts
            Self.logger.debug("Loaded \(sortedProducts.count) products from StoreKit: \(sortedProducts.map { $0.id })")
            
            // If no products were loaded, log a helpful message
            if sortedProducts.isEmpty {
                print("⚠️ [SupportMissionStore] WARNING: Returned product list is EMPTY.")
                Self.logger.info("No products loaded. This is normal in development. Products will be available once configured in App Store Connect for production.")
            }
        } catch {
            print("❌ [SupportMissionStore] ERROR loading products: \(error)")
            // StoreKit errors are common in development - don't show error to user unless critical
            Self.logger.info("StoreKit products not available (development mode): \(error.localizedDescription, privacy: .public)")
            // Only set error message if we're in production or if it's a critical error
            #if !DEBUG
            errorMessage = error.localizedDescription
            #else
            // In debug mode, silently fail - StoreKit will work in production
            #endif
        }
        isLoading = false
    }
    
    func purchase(_ product: Product) async {
        if purchaseTask != nil { return }
        
        purchaseTask = Task {
            defer { purchaseTask = nil }
            do {
                let result = try await product.purchase()
                switch result {
                case .success(let verificationResult):
                    let transaction = try verificationResult.payloadValue
                    await updatePurchasedProducts(with: transaction)
                    await transaction.finish()
                case .userCancelled, .pending:
                    break
                default:
                    break
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
        }
        
        await purchaseTask?.value
    }
    
    func restorePurchases() async {
        errorMessage = nil
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try result.payloadValue
                await updatePurchasedProducts(with: transaction)
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func hasPurchased(_ productID: String) -> Bool {
        purchasedProductIDs.contains(productID)
    }
    
    private func listenForTransactions() {
        Task.detached(priority: .background) { [weak self] in
            guard let self else { return }
            for await result in Transaction.updates {
                do {
                    let transaction = try result.payloadValue
                    await self.updatePurchasedProducts(with: transaction)
                    await transaction.finish()
                } catch {
                    await MainActor.run {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    private func loadCachedPurchases() {
        if let data = UserDefaults.standard.data(forKey: purchasedDefaultsKey),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            purchasedProductIDs = decoded
        }
    }
    
    private func persistPurchasedProducts() {
        if let data = try? JSONEncoder().encode(purchasedProductIDs) {
            UserDefaults.standard.set(data, forKey: purchasedDefaultsKey)
        }
    }
    
    private func updatePurchasedProducts(with transaction: Transaction) async {
        guard productIDs.contains(transaction.productID) else { return }
        await MainActor.run {
            purchasedProductIDs.insert(transaction.productID)
            persistPurchasedProducts()
        }
    }
}

