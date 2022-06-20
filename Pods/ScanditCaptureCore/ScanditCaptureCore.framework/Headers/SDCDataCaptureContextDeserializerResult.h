/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <Foundation/Foundation.h>

#import <ScanditCaptureCore/SDCBase.h>

NS_ASSUME_NONNULL_BEGIN

@class SDCDataCaptureContext;
@class SDCDataCaptureView;
@protocol SDCDataCaptureComponent;

/**
 * Added in version 6.1.0
 *
 * The result of a data capture context deserialization.
 */
NS_SWIFT_NAME(DataCaptureContextDeserializerResult)
SDC_EXPORTED_SYMBOL
@interface SDCDataCaptureContextDeserializerResult : NSObject

/**
 * Added in version 6.1.0
 *
 * The context created or updated through the deserialization.
 */
@property (nonatomic, strong, nonnull, readonly) SDCDataCaptureContext *context;
/**
 * Added in version 6.1.0
 *
 * The view created or updated through the context deserialization.
 */
@property (nonatomic, strong, nullable, readonly) SDCDataCaptureView *view;
/**
 * Added in version 6.1.0
 *
 * The warnings produced during deserialization, for example which properties were not used during deserialization.
 */
@property (nonatomic, strong, nonnull, readonly) NSArray<NSString *> *warnings;
/**
 * Added in version 6.3.0
 *
 * All components created or updated through the context deserialization.
 */
@property (nonatomic, strong, nonnull, readonly) NSArray<id<SDCDataCaptureComponent>> *components;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
