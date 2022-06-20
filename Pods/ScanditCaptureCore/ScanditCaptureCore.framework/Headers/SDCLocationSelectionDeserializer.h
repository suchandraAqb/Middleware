/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <Foundation/Foundation.h>

#import <ScanditCaptureCore/SDCBase.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SDCLocationSelection;

/**
 * Added in version 6.3.0
 *
 * A deserializer to construct location selections from JSON.
 *
 * Related topics: Serialization.
 */
NS_SWIFT_NAME(LocationSelectionDeserializer)
SDC_EXPORTED_SYMBOL
@interface SDCLocationSelectionDeserializer : NSObject

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
+ (nonnull instancetype)locationSelectionDeserializer;

- (nullable id<SDCLocationSelection>)locationSelectionFromJSONString:(nonnull NSString *)JSONString
                                                               error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
