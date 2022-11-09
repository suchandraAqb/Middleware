/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <Foundation/Foundation.h>

#import <ScanditCaptureCore/SDCBase.h>
#import <ScanditCaptureCore/SDCDataCaptureComponentDeserializer.h>

@class SDCParserDeserializer;
@class SDCParser;
@class SDCJSONValue;
@class SDCDataCaptureContext;

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.1.0
 *
 * The listener for the parser deserializer.
 */
NS_SWIFT_NAME(ParserDeserializerDelegate)
@protocol SDCParserDeserializerDelegate <NSObject>

/**
 * Added in version 6.3.0
 *
 * Called before the deserialization of the parser started. This is the point to overwrite defaults before the deserialization is performed.
 */
- (void)parserDeserializer:(SDCParserDeserializer *)parserDeserializer
    didStartDeserializingParser:(SDCParser *)parser
                  fromJSONValue:(SDCJSONValue *)JSONValue;
/**
 * Added in version 6.3.0
 *
 * Called when the deserialization of the parser finished. This is the point to do additional deserialization.
 */
- (void)parserDeserializer:(SDCParserDeserializer *)parserDeserializer
    didFinishDeserializingParser:(SDCParser *)parser
                   fromJSONValue:(SDCJSONValue *)JSONValue;

@end

/**
 * Added in version 6.3.0
 *
 * A deserializer to construct a parser from JSON. For most use cases it is enough to use SDCParser.parserFromJSONString:context:error: which internally uses this deserializer. Using the deserializer gives the advantage of being able to listen to the deserialization events as they happen and potentially influence them. Additonally warnings can be read from the deserializer that would otherwise not be available.
 *
 * Related topics: Serialization.
 */
NS_SWIFT_NAME(ParserDeserializer)
SDC_EXPORTED_SYMBOL
@interface SDCParserDeserializer : NSObject <SDCDataCaptureComponentDeserializer>

/**
 * Added in version 6.3.0
 *
 * The object informed about deserialization events.
 */
@property (nonatomic, weak, nullable) id<SDCParserDeserializerDelegate> delegate;
/**
 * Added in version 6.3.0
 *
 * The warnings produced during deserialization, for example which properties were not used during deserialization.
 */
@property (nonatomic, nonnull, readonly) NSArray<NSString *> *warnings;

/**
 * Added in version 6.3.0
 *
 * Creates a new deserializer object.
 */
+ (instancetype)parserDeserializer;

/**
 * Added in version 6.3.0
 *
 * Deserializes a parser from JSON.
 *
 * An error is set if the provided JSON does not contain required properties or contains properties of the wrong type.
 */
- (nullable SDCParser *)parserFromJSONString:(nonnull NSString *)JSONString
                                     context:(nonnull SDCDataCaptureContext *)context
                                       error:(NSError *_Nullable *_Nullable)error;

/**
 * Added in version 6.3.0
 *
 * Takes an existing parser and updates it by deserializing new or changed properties from JSON. See Updating from JSON for details of how updates are being done.
 *
 * An error is set if the provided JSON does not contain required properties or contains properties of the wrong type.
 */
- (nullable SDCParser *)updateParser:(nonnull SDCParser *)parser
                      fromJSONString:(NSString *)JSONString
                               error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
