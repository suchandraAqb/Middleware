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
 * Holds settings related to the data capture context.
 */
NS_SWIFT_NAME(DataCaptureContextSettings)
SDC_EXPORTED_SYMBOL
@interface SDCDataCaptureContextSettings : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * Added in version 6.4.0
 *
 * Creates a new settings object with the default values.
 */
+ (instancetype)settings;

/**
 * Added in version 6.4.0
 *
 * Sets a property to the provided value. Use this method to set properties that are not yet part of a stable API. Properties set through this method may or may not be used or change in a future release.
 */
- (void)setValue:(nullable id)value
     forProperty:(nonnull NSString *)property NS_SWIFT_NAME(set(value:forProperty:));
/**
 * Added in version 6.4.0
 *
 * Retrieves the value of a previously set property. In case the property does not exist, nil is returned.
 */
- (nullable id)valueForProperty:(nonnull NSString *)property;

@end

NS_ASSUME_NONNULL_END
