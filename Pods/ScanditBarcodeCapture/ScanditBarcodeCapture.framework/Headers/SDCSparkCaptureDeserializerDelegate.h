/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class SDCSparkCaptureDeserializer;
@class SDCSparkCapture;
@class SDCSparkCaptureSettings;
@class SDCSparkCaptureOverlay;
@class SDCJSONValue;

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.9.0
 *
 * The listener for the spark capture deserializer.
 */
NS_SWIFT_NAME(SparkCaptureDeserializerDelegate)
@protocol SDCSparkCaptureDeserializerDelegate <NSObject>

/**
 * Added in version 6.9.0
 *
 * Called before the deserialization of spark capture started. This is the point to overwrite defaults before the deserialization is performed.
 */
- (void)sparkCaptureDeserializer:(SDCSparkCaptureDeserializer *)deserializer
       didStartDeserializingMode:(SDCSparkCapture *)mode
                   fromJSONValue:(SDCJSONValue *)JSONValue;
/**
 * Added in version 6.9.0
 *
 * Called when the deserialization of spark capture finished. This is the point to do additional deserialization.
 */
- (void)sparkCaptureDeserializer:(SDCSparkCaptureDeserializer *)deserializer
      didFinishDeserializingMode:(SDCSparkCapture *)mode
                   fromJSONValue:(SDCJSONValue *)JSONValue;

/**
 * Added in version 6.9.0
 *
 * Called before the deserialization of the spark capture settings started. This is the point to overwrite defaults before the deserialization is performed.
 */
- (void)sparkCaptureDeserializer:(SDCSparkCaptureDeserializer *)deserializer
    didStartDeserializingSettings:(SDCSparkCaptureSettings *)settings
                    fromJSONValue:(SDCJSONValue *)JSONValue;
/**
 * Added in version 6.9.0
 *
 * Called when the deserialization of the spark capture settings finished. This is the point to do additional deserialization.
 */
- (void)sparkCaptureDeserializer:(SDCSparkCaptureDeserializer *)deserializer
    didFinishDeserializingSettings:(SDCSparkCaptureSettings *)settings
                     fromJSONValue:(SDCJSONValue *)JSONValue;

@end

NS_ASSUME_NONNULL_END
