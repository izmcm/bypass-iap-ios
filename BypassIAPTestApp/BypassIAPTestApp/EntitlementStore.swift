//
//  EntitlementStore.swift
//  BypassIAPTestApp
//
//  Vulnerabilities #2 and #3: "Insecure Storage".
//
//  Entitlements are persisted directly in `UserDefaults`:
//   - as plain booleans under predictable keys (read with `bool(forKey:)`), and
//   - as an expiration timestamp (read with `double(forKey:)`).
//
//  Both reads go through -[NSUserDefaults boolForKey:] / -[NSUserDefaults doubleForKey:],
//  so a runtime hook can force premium flags to `true` or make the subscription
//  expiration look effectively infinite.
//

import Combine
import Foundation

@MainActor
final class EntitlementStore: ObservableObject {

    private let defaults = UserDefaults.standard

    // MARK: - Boolean feature flags (Vulnerability #2)

    /// Predictable keys that gate premium features. Storing entitlements like this
    /// is insecure: a tweak hooking `boolForKey:` can force any of them to `true`.
    static let boolKeys = ["isPremium", "removeAds", "isPro", "vipEnabled", "subscribed"]

    // MARK: - Subscription expiration (Vulnerability #3)

    /// Key whose value is a UNIX timestamp read with `double(forKey:)`.
    static let expirationKey = "subscriptionExpirationDate"

    // Published copies used only for display in the UI.
    @Published var boolValues: [String: Bool] = [:]
    @Published var expirationTimestamp: Double = 0

    init() {
        reload()
    }

    /// Refreshes the published display values from `UserDefaults`.
    func reload() {
        var values: [String: Bool] = [:]
        for key in Self.boolKeys {
            values[key] = defaults.bool(forKey: key)
        }
        boolValues = values
        expirationTimestamp = defaults.double(forKey: Self.expirationKey)
    }

    // MARK: - Mutators

    func setFlag(_ key: String, to value: Bool) {
        defaults.set(value, forKey: key)
        reload()
    }

    func startTrial(days: Int) {
        let expiry = Date().addingTimeInterval(Double(days) * 86_400).timeIntervalSince1970
        defaults.set(expiry, forKey: Self.expirationKey)
        reload()
    }

    func resetForTesting() {
        for key in Self.boolKeys {
            defaults.removeObject(forKey: key)
        }
        defaults.removeObject(forKey: Self.expirationKey)
        reload()
    }

    // MARK: - Live entitlement checks (read straight from UserDefaults)

    /// VULNERABILITY: unlocked whenever any flag reads `true`.
    /// Reads live so a `boolForKey:` hook is exercised on every check.
    var isUnlockedByFlags: Bool {
        for key in Self.boolKeys where defaults.bool(forKey: key) {
            return true
        }
        return false
    }

    /// VULNERABILITY: valid whenever the stored expiration is in the future.
    /// A `doubleForKey:` hook returning a huge value keeps this active forever.
    var isSubscriptionActive: Bool {
        defaults.double(forKey: Self.expirationKey) > Date().timeIntervalSince1970
    }
}
