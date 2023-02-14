
// Receipt validation missing
%hook SKPaymentTransaction
- (long long)transactionState {
	%log;
	NSLog(@"SKPaymentTransaction bypass called!");
	return 1;
}
%end

// Insecure Storage
%hook NSUserDefaults
- (BOOL)boolForKey:(id)arg1 {
	%log;
	NSString *lowerKey = [arg1 lowercaseString];
	NSString *finalKey = [[lowerKey stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""];

	NSArray *trueKeys = [NSArray arrayWithObjects: @"plus", @"premium", @"vip", @"purchase", @"removeads", @"subscription", @"subscribed", @"includedebugmenu", @"versaocompleta", @"ispro", @"subscribtion", nil];
	
	for(NSString *key in trueKeys) {
		if([finalKey containsString:key]) {
			NSLog(@"UserDefaults bypass called!");
			return 1;
		}
	}

	return %orig;
}

- (double)doubleForKey:(id)arg1 {
	%log;
	NSString *lowerKey = [arg1 lowercaseString];
	NSString *finalKey = [[lowerKey stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""];

	NSArray *trueKeys = [NSArray arrayWithObjects: @"vipdate", @"premiumdate", @"expirationdate", @"expireddate", nil];
	
	for(NSString *key in trueKeys) {
		if([finalKey containsString:key]) {
			NSLog(@"UserDefaults bypass called!");
			return 9999999999999;
		}
	}

	return %orig;
}
%end


