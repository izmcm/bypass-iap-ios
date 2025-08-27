#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import <objc/runtime.h>
#import <os/log.h>

#define TWEAK_LOG os_log_create("com.assistente-srd.bypass-iap", "BypassIAP")

@implementation SKPaymentTransaction (Hook)
- (NSInteger)hooked_transactionState {
    os_log_error(TWEAK_LOG, "BYPASS: -[SKPaymentTransaction transactionState] -> Forcing state to 'Purchased' (1)");
    return SKPaymentTransactionStatePurchased;
}

- (NSError*)hooked_transactionError {
    os_log_error(TWEAK_LOG, "BYPASS: -[SKPaymentTransaction transactionError] -> Forcing state to 'NULL'");
    return NULL;
}
@end

@implementation NSUserDefaults (Hook)

- (BOOL)hooked_boolForKey:(NSString *)key {
    BOOL originalValue = [self hooked_boolForKey:key];

    NSString *processedKey = [[[[key lowercaseString] stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // List of keywords that should return YES.
    static NSArray *trueKeys = nil;
    if (!trueKeys) {
        trueKeys = @[@"ledbpro", @"plus", @"premium", @"vip", @"purchase", @"removeads", @"subscription", @"subscribed", @"includedebugmenu", @"versaocompleta", @"ispro", @"isenabled", @"fullversion", @"isactive", @"adunlock", @"bought", @"testmode", @"lifetimeaccess", @"showallcontent", @"playerregistered", @"isupgradeuser", @"isusingpro", @"canuse", @"simulatepro", @"featurefreedom", @"subscriber", @"islifetimeuser", @"isforeveruser", @"versionenabled"];
    }

    // List of keywords that should return NO.
    static NSArray *falseKeys = nil;
    if (!falseKeys) {
        falseKeys = @[@"expire", @"expired", @"premiumdisabled", @"subscriptionancelled"];
    }

    for (NSString *falseKey in falseKeys) {
        if ([processedKey containsString:falseKey]) {
            os_log_error(TWEAK_LOG, "BYPASS: -[NSUserDefaults boolForKey:@\"%{public}@\"] -> Forcing to NO (was %d)", key, originalValue);
            return NO;
        }
    }

    for (NSString *trueKey in trueKeys) {
        if ([processedKey containsString:trueKey]) {
            os_log_error(TWEAK_LOG, "BYPASS: -[NSUserDefaults boolForKey:@\"%{public}@\"] -> Forcing to YES (was %d)", key, originalValue);
            return YES;
        }
    }
    
    return originalValue;
}

- (double)hooked_doubleForKey:(NSString *)key {
    double originalValue = [self hooked_doubleForKey:key];

    NSString *processedKey = [[[[key lowercaseString] stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];

    static NSArray *expirationKeys = nil;
    if (!expirationKeys) {
        expirationKeys = @[@"vipdate", @"vipexpiretimestamp", @"premiumdate", @"expirationdate", @"expireddate"];
    }
    
    for (NSString *expKey in expirationKeys) {
        if ([processedKey containsString:expKey]) {
            os_log_error(TWEAK_LOG, "BYPASS: -[NSUserDefaults doubleForKey:@\"%{public}@\"] -> Forcing to future timestamp (was %f)", key, originalValue);
            return 9999999999999.0;
        }
    }

    return originalValue;
}
@end

@interface BypassIAPTweakInjector : NSObject
@end

@implementation BypassIAPTweakInjector
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        os_log_error(TWEAK_LOG, "[*] BypassIAPTweakInjector: Loaded and ready to apply hooks.");

        // Hook 1: SKPaymentTransaction
        method_exchangeImplementations(
            class_getInstanceMethod(objc_getClass("SKPaymentTransaction"), @selector(transactionState)),
            class_getInstanceMethod(objc_getClass("SKPaymentTransaction"), @selector(hooked_transactionState))
        );

        method_exchangeImplementations(
            class_getInstanceMethod(objc_getClass("SKPaymentTransaction"), @selector(error)),
            class_getInstanceMethod(objc_getClass("SKPaymentTransaction"), @selector(hooked_transactionError))
        );

        // Hook 2: NSUserDefaults boolForKey
        method_exchangeImplementations(
            class_getInstanceMethod(objc_getClass("NSUserDefaults"), @selector(boolForKey:)),
            class_getInstanceMethod(objc_getClass("NSUserDefaults"), @selector(hooked_boolForKey:))
        );

        // Hook 3: NSUserDefaults doubleForKey
        method_exchangeImplementations(
            class_getInstanceMethod(objc_getClass("NSUserDefaults"), @selector(doubleForKey:)),
            class_getInstanceMethod(objc_getClass("NSUserDefaults"), @selector(hooked_doubleForKey:))
        );
        
        os_log_error(TWEAK_LOG, "[*] BypassIAPTweakInjector: Hooks applied successfully.");
    });
}
@end