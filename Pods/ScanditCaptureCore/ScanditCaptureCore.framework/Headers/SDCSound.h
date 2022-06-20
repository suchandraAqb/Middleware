/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <Foundation/Foundation.h>

#import <ScanditCaptureCore/SDCBase.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.0.0
 *
 * A sound, to be played for example when a code has been successfully scanned.
 */
NS_SWIFT_NAME(Sound)
SDC_EXPORTED_SYMBOL
@interface SDCSound : NSObject

/**
 * Added in version 6.0.0
 *
 * The default beep sound for a successful scan.
 */
@property (class, nonatomic, readonly) SDCSound *defaultSound;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 * Added in version 6.0.0
 *
 * Creates a new Sound loading the given file.
 */
- (nullable instancetype)initWithURL:(nonnull NSURL *)url;
/**
 * Added in version 6.7.0
 *
 * Creates a new Sound for the given resource name. The resource should be placed in the main application bundle.
 */
- (nullable instancetype)initWithResourceName:(nonnull NSString *)resourceName;

/**
 * Added in version 6.9.0
 *
 * Returns the JSON representation of the sound.
 */
@property (nonatomic, nonnull, readonly) NSString *JSONString;

@end

NS_ASSUME_NONNULL_END
