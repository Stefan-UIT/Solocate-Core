//
//  NSString+JKNormalRegex.h
//  JKCategories
//
//  Created by KevinHM on 15/6/24.
//  Copyright (c) 2015年 KevinHM. All rights reserved.
//   https://github.com/KevinHM

//
//  NSString+SDString.h
//  SDCoreiOS
//
//  Created by phunguyen on 6/12/17.
//  Copyright © 2017 phunguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (SDString)

@property (readonly) NSString *localized;
#pragma mark - Class methods
+ (NSString *)mimeTypeForFileAtPath: (NSString *)path;

#pragma mark - Regular Expression

- (BOOL)isMobileNumberClassification;

- (BOOL)isMobileNumber;

- (BOOL)isEmailAddress;

- (BOOL)simpleVerifyIdentityCardNum;

+ (BOOL)accurateVerifyIDCardNumber:(NSString *)value;

- (BOOL)isCarNumber;

- (BOOL)bankCardluhmCheck;

- (BOOL)isIPAddress;

- (BOOL)isMacAddress;

- (BOOL)isValidUrl;

- (BOOL)isValidChinese;

- (BOOL)isValidPostalcode;

- (BOOL)isValidTaxNo;

- (BOOL)isValidWithMinLenth:(NSInteger)minLenth
                      maxLenth:(NSInteger)maxLenth
                containChinese:(BOOL)containChinese
           firstCannotBeDigtal:(BOOL)firstCannotBeDigtal;

- (BOOL)isValidWithMinLenth:(NSInteger)minLenth
                      maxLenth:(NSInteger)maxLenth
                containChinese:(BOOL)containChinese
                 containDigtal:(BOOL)containDigtal
                 containLetter:(BOOL)containLetter
         containOtherCharacter:(NSString *)containOtherCharacter
           firstCannotBeDigtal:(BOOL)firstCannotBeDigtal;
- (NSString *)sha1;

@end
