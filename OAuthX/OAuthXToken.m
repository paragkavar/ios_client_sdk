/*
 * Copyright 2011-2012 OAuthX
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


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
