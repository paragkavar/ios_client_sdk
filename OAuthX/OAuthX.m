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


#import "OAuthX.h"
#import "OAuthXRequest.h"

/************************************************************************************
 ** Constants
 ************************************************************************************/

static NSString* kAuthorizeURL = @"https://www.oauthx.com/authorize/";
static NSString* kProxyURL = @"https://www.oauthx.com/proxy";

/************************************************************************************
 ** Implementation
 ************************************************************************************/

@implementation OAuthX

@synthesize appKey, callbackUrl, tokens, sessionDelegate, request;

/************************************************************************************
 ** Initialization
 ************************************************************************************/

/**
 * Initialize OAuthX object with application key/id
 */
- (id) initWithAppKey:(NSString *)newAppKey {
    return [self initWithAppKey: newAppKey andCallbackUrl: [NSString stringWithFormat: @"oauthx%@://authorize", newAppKey]];
}

/**
 * Initialize OAuthX object with application id and callback URL
 */
- (id) initWithAppKey:(NSString *)newAppKey andCallbackUrl:(NSString *) newCallbackUrl {
    self = [super init];
    if (self) {
        self.appKey = newAppKey;
        self.callbackUrl = newCallbackUrl;
        self.tokens = [NSMutableDictionary dictionary];
    }
    return self;
}

/************************************************************************************
 ** Private Methods
 ************************************************************************************/

/**
 * A private function for parsing URL parameters.
 */
- (NSDictionary*)parseURLParams:(NSString *)query {
	NSArray *pairs = [query componentsSeparatedByString:@"&"];
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	for (NSString *pair in pairs) {
		NSArray *kv = [pair componentsSeparatedByString:@"="];
		NSString *val = [[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		[params setObject:val forKey:[kv objectAtIndex:0]];
	}
    return params;
}


/************************************************************************************
 ** Public Methods
 ************************************************************************************/

/**
 * Browser-based authorization flow. Works for all applications.
 */
- (void) authorizeService:(NSString *)service delegate:(id<OAuthXSessionDelegate>)delegate {
    self.sessionDelegate = delegate;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   service,              @"service",
                                   nil];
    
    NSString *oauthXAuthorizeUrl = [OAuthXRequest serializeURL:[kAuthorizeURL stringByAppendingString:self.appKey] params:params];
    NSLog(@"%@", oauthXAuthorizeUrl);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:oauthXAuthorizeUrl]];
}

/**
 * This function processes the URL the Safari used to
 * open your application during a single sign-on flow.
 *
 * You MUST call this function in your UIApplicationDelegate's handleOpenURL
 * method (see
 * http://developer.apple.com/library/ios/#documentation/uikit/reference/UIApplicationDelegate_Protocol/Reference/Reference.html
 * for more info).
 *
 * This will ensure that the authorization process will proceed smoothly once the
 * OAuthX application or Safari redirects back to your application.
 *
 * @param URL the URL that was passed to the application delegate's handleOpenURL method.
 *
 * @return YES if the URL starts with 'app_key://authorize and hence was handled
 *   by SDK, NO otherwise.
 */
- (BOOL)handleOpenURL:(NSURL *)url {
    NSLog(@"URL: %@", url);
    
    // If the URL's structure doesn't match the structure used for OAuthX authorization, abort.
    if (![[url absoluteString] hasPrefix:self.callbackUrl]) {
        return NO;
    }
    
    NSString *query = [url fragment];
    if (!query) {
        query = [url query];
    }

    // Key must be returned with authorization call
    NSDictionary *params = [self parseURLParams:query];
    if ([params objectForKey:@"key"] == nil || ![[params objectForKey:@"key"] isEqualToString:self.appKey]) {
        return NO;
    }

    // Key must much the SDK key
    if (![[params objectForKey:@"key"] isEqualToString:appKey]) {
        return NO;
    }

    NSString *service = [params objectForKey:@"service"];
    OAuthXToken *token = [OAuthXToken tokenFromParams:params];
    
    if (token == nil) {
        BOOL userDidCancel = NO;
        if ([[params objectForKey:@"message"] isEqualToString:@"canceled"]) {
            userDidCancel = YES;
        }
        
        if ([self.sessionDelegate respondsToSelector:@selector(oauthXDidNotLoginToService::)]) {
            [self.sessionDelegate oauthXDidNotLoginToService:service userCanceled:userDidCancel];
        }
        
        return YES;
    }
    
    [self.tokens setObject:token forKey:service];
     
    if ([self.sessionDelegate respondsToSelector:@selector(oauthXDidLoginToService:)]) {
        [self.sessionDelegate oauthXDidLoginToService:service];
    }
    return YES;
}

- (OAuthXRequest*) requestService: (NSString *)service
                          withURL: (NSString *)url
                      andDelegate: (id <OAuthXRequestDelegate>)delegate {
    
    return [self requestService: service
                        withURL: url
                      andParams: [NSMutableDictionary dictionary]
                  andHttpMethod: @"GET"
                    andDelegate: delegate];
    
}

- (OAuthXRequest*) requestService: (NSString *)service
                          withURL: (NSString *)url
                        andParams: (NSMutableDictionary *)params
                      andDelegate: (id <OAuthXRequestDelegate>)delegate {

    return [self requestService: service
                        withURL: url
                      andParams: params
                  andHttpMethod: @"GET"
                    andDelegate: delegate];
}

- (OAuthXRequest*) requestService: (NSString *)service
                          withURL: (NSString *)url
                        andParams: (NSMutableDictionary *)params
                    andHttpMethod: (NSString *)httpMethod
                      andDelegate: (id <OAuthXRequestDelegate>)delegate {
    
    return [self requestService: service
                        withURL: url
                      andParams: params
                  andHttpMethod: @"GET"
                     andOptions: [NSMutableDictionary dictionary]
                    andDelegate: delegate];
}

- (OAuthXRequest*) requestService: (NSString *)service
                          withURL: (NSString *)url
                        andParams: (NSMutableDictionary *)params
                    andHttpMethod: (NSString *)httpMethod
                       andOptions: (NSMutableDictionary *)options
                      andDelegate: (id <OAuthXRequestDelegate>)delegate {
    
    if (options && [options valueForKey:@"unauthorized"]) {
        // no need to add access token
    } else if ([self isAccessTokenValidForService:service]) {
        OAuthXToken *token = [self tokenForService:service];
        [token appendAccessTokenToParams:params];
    }
    
    self.request = [OAuthXRequest requestService: service 
                                         withURL: url 
                                       andParams: params 
                                   andHttpMethod: httpMethod 
                                      andOptions: options 
                                     andDelegate: delegate]; 
    [self.request connect];
    return self.request;
}

/**
 * @return boolean - whether access token is valid for a service
 */
- (BOOL) isAccessTokenValidForService:(NSString *) service {
    OAuthXToken *token = [self tokenForService:service];
    if (token == nil) return NO;
    return [token isValid];
}

- (OAuthXToken *) tokenForService:(NSString *) service {
    OAuthXToken *token = (OAuthXToken *) [tokens objectForKey:service];  
    return token;
}

@end
