/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <ScanditCaptureCore/SDCDataCaptureModeDeserializer.h>

@class SDCSparkCapture;
@class SDCDataCaptureContext;
@class SDCSparkCaptureSettings;
@class SDCSparkCaptureOverlay;
@protocol SDCSparkCaptureDeserializerDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.9.0
 *
 * A deserializer to construct spark capture from JSON. For most use cases it is enough to use SDCSparkCapture.sparkCaptureFromJSONString:context:error: which internally uses this deserializer. Using the deserializer gives the advantage of being able to listen to the deserialization events as they happen and potentially influence them. Additonally warnings can be read from the deserializer that would otherwise not be available.
 *
 * Related topics: Serialization.
 */
NS_SWIFT_NAME(SparkCaptureDeserializer)
@interface SDCSparkCaptureDeserializer : NSObject <SDCDataCaptureModeDeserializer>

/**
 * Added in version 6.9.0
 *
 * The object informed about deserialization events.
 */
@property (nonatomic, weak, nullable) id<SDCSparkCaptureDeserializerDelegate> delegate;
/**
 * Added in version 6.9.0
 *
 * The warnings produced during deserialization, for example which properties were not used during deserialization.
 */
@property (nonatomic, readonly) NSArray<NSString *> *warnings;

/**
 * Added in version 6.9.0
 *
 * Creates a new deserializer object.
 */
+ (instancetype)sparkCaptureDeserializer;

/**
 * Added in version 6.9.0
 *
 * Deserializes spark capture from JSON.
 *
 * An error is set if the provided JSON does not contain required properties or contains properties of the wrong type.
 */
- (nullable SDCSparkCapture *)modeFromJSONString:(NSString *)JSONString
                                     withContext:(SDCDataCaptureContext *)context
                                           error:(NSError *_Nullable *_Nullable)error;
/**
 * Added in version 6.9.0
 *
 * Takes an existing spark capture and updates it by deserializing new or changed properties from JSON. See Updating from JSON for details of how updates are being done.
 *
 * An error is set if the provided JSON does not contain required properties or contains properties of the wrong type.
 */
- (nullable SDCSparkCapture *)updateMode:(SDCSparkCapture *)sparkCapture
                          fromJSONString:(NSString *)JSONString
                                   error:(NSError *_Nullable *_Nullable)error;

/**
 * Added in version 6.9.0
 *
 * Deserializes spark capture settings from JSON.
 *
 * An error is set if the provided JSON does not contain required properties or contains properties of the wrong type.
 */
- (nullable SDCSparkCaptureSettings *)settingsFromJSONString:(NSString *)JSONString
                                                       error:(NSError *_Nullable *_Nullable)error;
/**
 * Added in version 6.9.0
 *
 * Takes existing spark capture settings and updates them by deserializing new or changed properties from JSON. See Updating from JSON for details of how updates are being done.
 *
 * An error is set if the provided JSON does not contain required properties or contains properties of the wrong type.
 */
- (nullable SDCSparkCaptureSettings *)updateSettings:(SDCSparkCaptureSettings *)settings
                                      fromJSONString:(NSString *)JSONString
                                               error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
