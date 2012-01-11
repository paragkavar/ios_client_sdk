//
//  OauthXToken.m
//  BirthdayCalendar
//
//  Created by Michael Berkovich on 8/12/11.
//  Copyright 2011 Geni.com. All rights reserved.
//

#import "OAuthXToken.h"

@implementation OAuthXToken
@synthesize service, serviceSecret, accessToken, oauthToken, oauthTokenSecret, oauthVersion, expiresAt;

+ (OAuthXToken *) tokenFromParams:(NSDictionary *) params {
    if ([[params objectForKey:@"status"] isEqualToString:@"authorized"]) {
        return nil;
    }

    OAuthXToken *token = [[OAuthXToken alloc] init];
    token.service = [params objectForKey:@"service"];
    token.oauthVersion = [params objectForKey:@"oauth_version"];
    if ([params objectForKey:@"expires_in"]) {
//        token.expiresAt = [params objectForKey:@"expires_in"];
    }
    
    if ([token.oauthVersion isEqualToString:@"1.0"]) {
        token.oauthToken = [params objectForKey:@"oauth_token"];
        token.oauthTokenSecret = [params objectForKey:@"oauth_token_secret"];
        token.serviceSecret = [params objectForKey:@"service_secret"];
        return token;
    }
    
    if ([token.oauthVersion isEqualToString:@"2.0"]) {
        token.accessToken = [params objectForKey:@"access_token"];
        return token;
    }

    return nil;
}

- (NSString *) createSignatureFromParams: (NSDictionary *) params {
    // add required signature
    return @"";
}

- (void) appendAccessTokenToParams:(NSMutableDictionary *) params {
    if ([self.oauthVersion isEqualToString:@"2.0"]) {
        [params setValue:self.accessToken forKey:@"access_token"];    
    } else {
        // sign params
        [params setValue:self.oauthToken forKey:@"oauth_token"];    
    }
}

- (BOOL) isValid {
    return YES;
}

@end
