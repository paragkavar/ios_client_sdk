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

#import <Foundation/Foundation.h>
#import "OAuthXRequest.h"
#import "OAuthXToken.h"

@protocol OAuthXSessionDelegate;

@interface OAuthX : NSObject <OAuthXRequestDelegate> {
}

@property(nonatomic, retain) NSString* appKey;

@property(nonatomic, retain) NSString* callbackUrl;

@property(nonatomic, retain) NSMutableDictionary* tokens;

@property(nonatomic, assign) id<OAuthXSessionDelegate> sessionDelegate;

@property(nonatomic, retain) OAuthXRequest* request;

- (id) initWithAppKey:(NSString *)newAppKey;

- (id) initWithAppKey:(NSString *)newAppKey andCallbackUrl:(NSString *) newCallbackUrl;

- (void) authorizeService:(NSString *)service delegate:(id<OAuthXSessionDelegate>)delegate;

- (BOOL) handleOpenURL:(NSURL *)url;

// authorized requests
- (OAuthXRequest*) requestService: (NSString *)service
                          withURL: (NSString *)url
                      andDelegate: (id <OAuthXRequestDelegate>)delegate;

- (OAuthXRequest*) requestService: (NSString *)service
                          withURL: (NSString *)url
                        andParams: (NSMutableDictionary *)params
                      andDelegate: (id <OAuthXRequestDelegate>)delegate;

- (OAuthXRequest*) requestService: (NSString *)service
                          withURL: (NSString *)url
                        andParams: (NSMutableDictionary *)params
                    andHttpMethod: (NSString *)httpMethod
                      andDelegate: (id <OAuthXRequestDelegate>)delegate;

- (OAuthXRequest*) requestService: (NSString *)service
                          withURL: (NSString *)url
                        andParams: (NSMutableDictionary *)params
                    andHttpMethod: (NSString *)httpMethod
                       andOptions: (NSMutableDictionary *)options
                      andDelegate: (id <OAuthXRequestDelegate>)delegate;

- (OAuthXToken *) tokenForService:(NSString *) service;

- (BOOL) isAccessTokenValidForService:(NSString *) service;

@end


/************************************************************************************
 ** OAuthX Session Delegate
 ************************************************************************************/

/**
 * Your application should implement this delegate to receive session callbacks.
 */
@protocol OAuthXSessionDelegate <NSObject>

@optional

/**
 * Called when the user successfully logged in 
 * or when the access token was validated.
 */
- (void) oauthXDidLoginToService:(NSString *)service;

/**
 * Called when the user dismissed the dialog without logging in.
 * or when the access token was not validated.
 */
- (void) oauthXDidNotLoginToService:(NSString *)service userCanceled:(BOOL)cancelled;

/**
 * Called when the user logged out.
 */
- (void) oauthXDidLogoutFromService:(NSString *)service;

@end
