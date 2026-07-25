//
//  ContentView.swift
//  BypassIAPTestApp
//
//  A deliberately vulnerable demo app used to exercise an IAP-bypass tweak.
//  Each section reproduces one vulnerability the tweak targets:
//    1. In-App Purchase with no receipt validation  (SKPaymentTransaction)
//    2. Boolean entitlement flags in UserDefaults    (boolForKey:)
//    3. Subscription expiration in UserDefaults       (doubleForKey:)
//

import SwiftUI

struct ContentView: View {
    @StateObject private var iap = IAPManager()
    @StateObject private var entitlements = EntitlementStore()

    var body: some View {
        NavigationView {
            List {
                iapSection
                boolFlagsSection
                expirationSection
            }
            .navigationTitle("IAP Bypass Test")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset", role: .destructive) {
                        iap.resetForTesting()
                        entitlements.resetForTesting()
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Vulnerability #1: In-App Purchase (no receipt validation)

    private var iapSection: some View {
        Section {
            statusRow(title: "Premium",
                      unlocked: iap.isPremiumUnlocked)

            Text(iap.statusMessage)
                .font(.footnote)
                .foregroundStyle(.secondary)

            Button {
                iap.buyPremium()
            } label: {
                Label(buyButtonTitle, systemImage: "cart")
            }
        } header: {
            Text("1. In-App Purchase")
        } footer: {
            Text("Unlocks based only on SKPaymentTransaction.transactionState. The receipt is never validated.")
        }
    }

    private var buyButtonTitle: String {
        if let price = iap.product?.localizedPriceString {
            return "Buy Premium (\(price))"
        }
        return "Buy Premium"
    }

    // MARK: - Vulnerability #2: Boolean flags in UserDefaults

    private var boolFlagsSection: some View {
        Section {
            statusRow(title: "Feature unlocked",
                      unlocked: entitlements.isUnlockedByFlags)

            ForEach(EntitlementStore.boolKeys, id: \.self) { key in
                Toggle(key, isOn: Binding(
                    get: { entitlements.boolValues[key] ?? false },
                    set: { entitlements.setFlag(key, to: $0) }
                ))
            }
        } header: {
            Text("2. UserDefaults Boolean Flags")
        } footer: {
            Text("Entitlements stored as plain booleans under predictable keys and read with boolForKey:.")
        }
    }

    // MARK: - Vulnerability #3: Subscription expiration in UserDefaults

    private var expirationSection: some View {
        Section {
            statusRow(title: "Subscription",
                      unlocked: entitlements.isSubscriptionActive)

            Text("Stored expiration: \(expirationDescription)")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Button {
                entitlements.startTrial(days: 7)
            } label: {
                Label("Start 7-day Trial", systemImage: "calendar")
            }
        } header: {
            Text("3. UserDefaults Subscription Expiration")
        } footer: {
            Text("Expiration timestamp read with doubleForKey:. A huge value keeps the subscription active forever.")
        }
    }

    private var expirationDescription: String {
        let timestamp = entitlements.expirationTimestamp
        guard timestamp > 0 else { return "none" }
        let date = Date(timeIntervalSince1970: timestamp)
        return date.formatted(date: .abbreviated, time: .shortened)
    }

    // MARK: - Helpers

    private func statusRow(title: String, unlocked: Bool) -> some View {
        HStack {
            Text(title)
            Spacer()
            Label(unlocked ? "Unlocked" : "Locked",
                  systemImage: unlocked ? "lock.open.fill" : "lock.fill")
                .foregroundStyle(unlocked ? .green : .secondary)
                .labelStyle(.titleAndIcon)
        }
    }
}

#Preview {
    ContentView()
}
