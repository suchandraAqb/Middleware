/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <Foundation/Foundation.h>

#import <ScanditCaptureCore/SDCBase.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.4.0
 *
 * States representing different expiration types.
 */
typedef NS_CLOSED_ENUM(NSUInteger, SDCExpiration) {
/**
     * Added in version 6.4.0
     *
     * An expiration date is available.
     */
    SDCExpirationAvailable,
/**
     * Added in version 6.4.0
     *
     * The license is perpetual and as such there is no expiration date.
     */
    SDCExpirationPerpetual,
/**
     * Added in version 6.4.0
     *
     * No information about the expiration date is available for this license type.
     */
    SDCExpirationNotAvailable
} NS_SWIFT_NAME(Expiration);

/**
 * Added in version 6.4.0
 *
 * Contains information about the license for which a context was created.
 */
NS_SWIFT_NAME(LicenseInfo)
SDC_EXPORTED_SYMBOL
@interface SDCLicenseInfo : NSObject

/**
 * Added in version 6.4.0
 *
 * The expiration date of the license.
 */
@property (nonatomic, nullable, readonly) NSDate *date;
/**
 * Added in version 6.4.0
 *
 * The license’s expiration. This information is not made available for all license types.
 */
@property (nonatomic, readonly) SDCExpiration expiration;
/**
 * Added in version 6.5.0
 *
 * Returns the JSON representation of the license info.
 */
@property (nonatomic, nonnull, readonly) NSString *JSONString;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
