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

@class SKPaymentTransaction; 
static long long (*_logos_orig$_ungrouped$SKPaymentTransaction$transactionState)(_LOGOS_SELF_TYPE_NORMAL SKPaymentTransaction* _LOGOS_SELF_CONST, SEL); static long long _logos_method$_ungrouped$SKPaymentTransaction$transactionState(_LOGOS_SELF_TYPE_NORMAL SKPaymentTransaction* _LOGOS_SELF_CONST, SEL); 

#line 4 "Tweak.x"

static long long _logos_method$_ungrouped$SKPaymentTransaction$transactionState(_LOGOS_SELF_TYPE_NORMAL SKPaymentTransaction* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bypass called!"
        message:@"Check if premium mode is unlocked when using the app"
        delegate:nil
        cancelButtonTitle:@"OK"
        otherButtonTitles:nil];
    [alert show];

	return 1;
}


























static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SKPaymentTransaction = objc_getClass("SKPaymentTransaction"); { MSHookMessageEx(_logos_class$_ungrouped$SKPaymentTransaction, @selector(transactionState), (IMP)&_logos_method$_ungrouped$SKPaymentTransaction$transactionState, (IMP*)&_logos_orig$_ungrouped$SKPaymentTransaction$transactionState);}} }
#line 41 "Tweak.x"
