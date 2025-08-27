#line 1 "Tweak.x"



#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class SKPaymentTransaction; @class NSUserDefaults; 
static long long (*_logos_orig$_ungrouped$SKPaymentTransaction$transactionState)(_LOGOS_SELF_TYPE_NORMAL SKPaymentTransaction* _LOGOS_SELF_CONST, SEL); static long long _logos_method$_ungrouped$SKPaymentTransaction$transactionState(_LOGOS_SELF_TYPE_NORMAL SKPaymentTransaction* _LOGOS_SELF_CONST, SEL); static BOOL (*_logos_orig$_ungrouped$NSUserDefaults$boolForKey$)(_LOGOS_SELF_TYPE_NORMAL NSUserDefaults* _LOGOS_SELF_CONST, SEL, id); static BOOL _logos_method$_ungrouped$NSUserDefaults$boolForKey$(_LOGOS_SELF_TYPE_NORMAL NSUserDefaults* _LOGOS_SELF_CONST, SEL, id); static double (*_logos_orig$_ungrouped$NSUserDefaults$doubleForKey$)(_LOGOS_SELF_TYPE_NORMAL NSUserDefaults* _LOGOS_SELF_CONST, SEL, id); static double _logos_method$_ungrouped$NSUserDefaults$doubleForKey$(_LOGOS_SELF_TYPE_NORMAL NSUserDefaults* _LOGOS_SELF_CONST, SEL, id); 

#line 3 "Tweak.x"

static long long _logos_method$_ungrouped$SKPaymentTransaction$transactionState(_LOGOS_SELF_TYPE_NORMAL SKPaymentTransaction* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
	NSLog(@"-[<SKPaymentTransaction: %p> transactionState]", self);
	BOOL ans = _logos_orig$_ungrouped$SKPaymentTransaction$transactionState(self, _cmd);
	NSLog(@"SKPaymentTransaction bypass called! Changing %d to 1", ans);
	return 1;
}




static BOOL _logos_method$_ungrouped$NSUserDefaults$boolForKey$(_LOGOS_SELF_TYPE_NORMAL NSUserDefaults* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
	NSLog(@"-[<NSUserDefaults: %p> boolForKey:%@]", self, arg1);
	BOOL ans = _logos_orig$_ungrouped$NSUserDefaults$boolForKey$(self, _cmd, arg1);

	

	NSString *lowerKey = [arg1 lowercaseString];
	NSString *finalKey = [[lowerKey stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""];

	NSArray *trueKeys = [NSArray arrayWithObjects: @"plus", @"premium", @"vip", @"purchase", @"removeads", @"subscription", @"subscribed", @"includedebugmenu", @"versaocompleta", @"ispro", @"isenabled", @"subscribtion", @"fullversion", @"isactive", @"adunlock", @"bought", @"userusage", @"testmode", @"lifetimeaccess", @"showallcontent", @"playerregistered", @"isupgradeuser",  @"isusingpro", @"canuse", @"healthyalternativesenabled", @"simulatepro", @"featurefreedom", @"trialeligibilityenabled", @"viewall", @"qatracking", @"runningtests", @"ignorepro", @"istest", @"isfree", @"subscriber", @"islifetimeuser", @"isforeveruser", @"pro", @"versionenabled", nil];

	for(NSString *key in trueKeys) {
		if([finalKey containsString:key]) {
			NSLog(@"UserDefaults bypass called! Changing %d to 1", ans);
			ans = 1;
		}
	}

	NSArray *falseKeys = [NSArray arrayWithObjects: @"expire", @"expired", @"premiumdisabled", @"bpro", @"subscriptionancelled", nil];
	
	for(NSString *key in falseKeys) {
		if([finalKey containsString:key]) {
			NSLog(@"UserDefaults bypass called! Changing %d to 0", ans);
			ans = 0;
		}
	}


	return ans;
}

static double _logos_method$_ungrouped$NSUserDefaults$doubleForKey$(_LOGOS_SELF_TYPE_NORMAL NSUserDefaults* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
	NSLog(@"-[<NSUserDefaults: %p> doubleForKey:%@]", self, arg1);
	double ans = _logos_orig$_ungrouped$NSUserDefaults$doubleForKey$(self, _cmd, arg1);

	

	NSString *lowerKey = [arg1 lowercaseString];
	NSString *finalKey = [[lowerKey stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""];

	NSArray *trueKeys = [NSArray arrayWithObjects: @"vipdate", @"vipexpiretimestamp", @"premiumdate", @"expirationdate", @"expireddate", nil];

	
	for(NSString *key in trueKeys) {
		if([finalKey containsString:key]) {
			NSLog(@"UserDefaults bypass called! Changing %f to 999+", ans);
			return 9999999999999;
		}
	}

	return _logos_orig$_ungrouped$NSUserDefaults$doubleForKey$(self, _cmd, arg1);
}



static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SKPaymentTransaction = objc_getClass("SKPaymentTransaction"); { MSHookMessageEx(_logos_class$_ungrouped$SKPaymentTransaction, @selector(transactionState), (IMP)&_logos_method$_ungrouped$SKPaymentTransaction$transactionState, (IMP*)&_logos_orig$_ungrouped$SKPaymentTransaction$transactionState);}Class _logos_class$_ungrouped$NSUserDefaults = objc_getClass("NSUserDefaults"); { MSHookMessageEx(_logos_class$_ungrouped$NSUserDefaults, @selector(boolForKey:), (IMP)&_logos_method$_ungrouped$NSUserDefaults$boolForKey$, (IMP*)&_logos_orig$_ungrouped$NSUserDefaults$boolForKey$);}{ MSHookMessageEx(_logos_class$_ungrouped$NSUserDefaults, @selector(doubleForKey:), (IMP)&_logos_method$_ungrouped$NSUserDefaults$doubleForKey$, (IMP*)&_logos_orig$_ungrouped$NSUserDefaults$doubleForKey$);}} }
#line 69 "Tweak.x"
