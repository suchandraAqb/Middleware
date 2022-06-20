/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <Foundation/Foundation.h>

#import <ScanditCaptureCore/SDCBase.h>

@protocol SDCViewfinder;

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.3.0
 *
 * A deserializer to construct viewfinders from JSON.
 *
 * Related topics: Serialization.
 */
NS_SWIFT_NAME(ViewfinderDeserializer)
SDC_EXPORTED_SYMBOL
@interface SDCViewfinderDeserializer : NSObject
/**
 * Added in version 6.3.0
 *
 * The warnings produced during deserialization, for example which properties were not used during deserialization.
 */
@property (nonatomic, readonly) NSArray<NSString *> *warnings;

/**
 * Added in version 6.3.0
 *
 * Creates a new deserializer object.
 */
+ (nonnull instancetype)viewfinderDeserializer;

/**
 * Added in version 6.3.0
 *
 * Deserializes a viewfinder from JSON.
 *
 * An error is set if the provided JSON does not contain required properties or contains properties of the wrong type.
 */
- (nullable id<SDCViewfinder>)viewfinderFromJSONString:(nonnull NSString *)JSONString
                                                 error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
