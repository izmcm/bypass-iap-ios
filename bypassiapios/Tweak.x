
// Receipt validation missing
%hook SKPaymentTransaction
- (long long)transactionState {
	%log;
	BOOL ans = %orig;
	NSLog(@"SKPaymentTransaction bypass called! Changing %d to 1", ans);
	return 1;
}
%end

// Insecure Storage
%hook NSUserDefaults
- (BOOL)boolForKey:(id)arg1 {
	%log;
	BOOL ans = %orig;

	// NSLog(@"UserDefaults response is %d", ans);

	NSString *lowerKey = [arg1 lowercaseString];
	NSString *finalKey = [[lowerKey stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""];

	NSArray *trueKeys = [NSArray arrayWithObjects: @"plus", @"premium", @"vip", @"purchase", @"removeads", @"subscription", @"subscribed", @"includedebugmenu", @"versaocompleta", @"ispro", @"isenabled", @"subscribtion", @"fullversion", @"isactive", @"adunlock", @"bought", @"userusage", @"testmode", @"lifetimeaccess", @"showallcontent", @"playerregistered", @"isupgradeuser",  @"isusingpro", @"canuse", @"healthyalternativesenabled", @"simulatepro", @"featurefreedom", @"trialeligibilityenabled", @"viewall", @"qatracking", @"runningtests", @"ignorepro", @"istest", @"isfree", @"subscriber", @"islifetimeuser", @"isforeveruser", nil];

	for(NSString *key in trueKeys) {
		if([finalKey containsString:key]) {
			NSLog(@"UserDefaults bypass called! Changing %d to 1", ans);
			ans = 1;
		}
	}

	NSArray *falseKeys = [NSArray arrayWithObjects: @"expire", @"expired", @"premiumdisabled", @"bpro", nil];
	
	for(NSString *key in falseKeys) {
		if([finalKey containsString:key]) {
			NSLog(@"UserDefaults bypass called! Changing %d to 0", ans);
			ans = 0;
		}
	}


	return ans;
}

- (double)doubleForKey:(id)arg1 {
	%log;
	double ans = %orig;

	// NSLog(@"UserDefaults response is %f", ans);

	NSString *lowerKey = [arg1 lowercaseString];
	NSString *finalKey = [[lowerKey stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""];

	NSArray *trueKeys = [NSArray arrayWithObjects: @"vipdate", @"vipexpiretimestamp", @"premiumdate", @"expirationdate", @"expireddate", nil];

	
	for(NSString *key in trueKeys) {
		if([finalKey containsString:key]) {
			NSLog(@"UserDefaults bypass called! Changing %f to 999+", ans);
			return 9999999999999;
		}
	}

	return %orig;
}
%end


