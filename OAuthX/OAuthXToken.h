//
//  OauthXToken.h
//  BirthdayCalendar
//
//  Created by Michael Berkovich on 8/12/11.
//  Copyright 2011 Geni.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OAuthXToken : NSObject {
}

@property(nonatomic, retain) NSString *service;
@property(nonatomic, retain) NSString *serviceSecret;       // used by OAuth 1.0
@property(nonatomic, retain) NSString *oauthVersion;        // supports OAuth 1.0 and 2.0
@property(nonatomic, retain) NSString *accessToken;         // used by OAuth 2.0
@property(nonatomic, retain) NSString *oauthToken;          // used by OAuth 1.0
@property(nonatomic, retain) NSString *oauthTokenSecret;    // used by OAuth 1.0
@property(nonatomic, retain) NSDate   *expiresAt;           // used by OAuth 2.0

+ (OAuthXToken *) tokenFromParams:(NSDictionary *) params;

- (void) appendAccessTokenToParams:(NSMutableDictionary *) params;

- (BOOL) isValid;

@end
