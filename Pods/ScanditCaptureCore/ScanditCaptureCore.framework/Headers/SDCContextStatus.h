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
 * Holds information on the current context status. This information is available to data capture context listeners (see context:didChangeStatus: method). The initial context status will always be Unknown (0) but change very quickly to either Success (1) or an error (2+, see below).
 */
NS_SWIFT_NAME(ContextStatus)
SDC_EXPORTED_SYMBOL
@interface SDCContextStatus : NSObject

/**
 * Added in version 6.0.0
 *
 * A human readable representation of the current context status, containing more information about potential issues. In case there are no issues (isValid is YES), the message is empty.
 */
@property (nonatomic, nonnull, readonly) NSString *message;
/**
 * Added in version 6.0.0
 *
 * The context status code.
 */
@property (nonatomic, readonly) NSUInteger code;
/**
 * Added in version 6.0.0
 *
 * Whether the context is valid.
 */
@property (nonatomic, readonly) BOOL isValid;
/**
 * Added in version 6.1.0
 *
 * Returns the JSON representation of the context status.
 */
@property (nonatomic, nonnull, readonly) NSString *JSONString;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
