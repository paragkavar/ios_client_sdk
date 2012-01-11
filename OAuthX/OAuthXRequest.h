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
#import <UIKit/UIKit.h>
#import "OAuthXResponse.h"

@protocol OAuthXRequestDelegate;

/**
 * Do not use this interface directly, instead, use method in OAuthX.h
 */
@interface OAuthXRequest : NSObject {
    
}

@property(nonatomic,assign) id<OAuthXRequestDelegate> delegate;

/**
 * The service which will be contacted to execute the request.
 */
@property(nonatomic,copy) NSString* service;

/**
 * The URL which will be contacted to execute the request.
 */
@property(nonatomic,copy) NSString* url;

/**
 * The API method which will be called.
 */
@property(nonatomic,copy) NSString* httpMethod;

/**
 * The dictionary of parameters to pass to the method.
 *
 * These values in the dictionary will be converted to strings using the
 * standard Objective-C object-to-string conversion facilities.
 */
@property(nonatomic,retain) NSMutableDictionary* params;
@property(nonatomic,retain) NSMutableDictionary* options;
@property(nonatomic,retain) NSURLConnection*  connection;
@property(nonatomic,retain) OAuthXResponse*  response;


+ (NSString*) serializeURL: (NSString *)baseUrl params: (NSDictionary *)params;
+ (NSString*) serializeURL: (NSString *)baseUrl params: (NSDictionary *)params httpMethod: (NSString *)httpMethod;

+ (OAuthXRequest*) requestService: (NSString *) service 
                          withURL: (NSString *) url  
                        andParams: (NSMutableDictionary *) params
                    andHttpMethod: (NSString *) httpMethod
                       andOptions: (NSMutableDictionary *) options
                      andDelegate: (id<OAuthXRequestDelegate>)delegate;
- (void) connect;

- (BOOL) isLoading;

- (void) cancel;

@end

/************************************************************************************
 ** OAuthX Request Delegate
 ************************************************************************************/

/*
 *Your application should implement this delegate
 */
@protocol OAuthXRequestDelegate <NSObject>

@optional

/**
 * Called just before the request is sent to the server.
 */
- (void) oauthXRequestIsLoading: (OAuthXRequest *)request;

/**
 * Called when the server responds and begins to send back data.
 */
- (void) request: (OAuthXRequest *)request didReceiveResponse: (OAuthXResponse *)response;

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void) request: (OAuthXRequest *)request didFailWithError: (NSError *)error;

/**
 * Called when a request returns a response.
 *
 * The result object is the raw response from the server of type NSData
 */
- (void) request: (OAuthXRequest *)request didLoadRawResponse: (NSData *)data;

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number,
 * depending on thee format of the API response.
 */
- (void) request: (OAuthXRequest *)request didLoadResponse: (OAuthXResponse *)response;

@end

