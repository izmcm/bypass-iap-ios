
// Receipt validation missing
 
%hook SKPaymentTransaction
- (long long)transactionState {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bypass called!"
        message:@"Check if premium mode is unlocked when using the app"
        delegate:nil
        cancelButtonTitle:@"OK"
        otherButtonTitles:nil];
    [alert show];

	return 1;
}
%end

// Insecure Storage


// Hooking a class method
//+ (id)sharedInstance {
//	return %orig;
//}

// Hooking an instance method with an argument.
//- (void)messageName:(int)argument {
//	%log; // Write a message about this call, including its class, name and arguments, to the system log.

//	%orig; // Call through to the original function with its original arguments.
//	%orig(nil); // Call through to the original function with a custom argument.

//	// If you use %orig(), you MUST supply all arguments (except for self and _cmd, the automatically generated ones.)
//}

// Hooking an instance method with no arguments.


// Always make sure you clean up after yourself; Not doing so could have grave consequences!


