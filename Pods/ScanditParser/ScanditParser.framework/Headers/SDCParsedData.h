/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <Foundation/Foundation.h>

#import <ScanditCaptureCore/SDCBase.h>

@class SDCParsedField;

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.1.0
 *
 * Holds the result of a successfully parsed data string or raw data. Instances of this class are returned by SDCParser.parseString:error: and SDCParser.parseRawData:error: methods. The parsed data is divided into fields, each identified by a name.
 *
 * The data contained in this result object can be accessed in one of the following ways:
 *
 *   • Through an array of parser fields (see fields).
 *
 *   • Through a dictionary that maps field names to the field (see fieldsByName).
 *
 *   • Directly as a JSON string (see jsonString).
 */
NS_SWIFT_NAME(ParsedData)
SDC_EXPORTED_SYMBOL
@interface SDCParsedData : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 * Added in version 6.1.0
 *
 * The result object as a serialized JSON string.
 */
@property (nonatomic, nonnull, readonly) NSString *jsonString;
/**
 * Added in version 6.1.0
 *
 * Provides by-name lookup of the fields. The field names are data format specific. Consult the data format documentation for information on available fields.
 */
@property (nonatomic, nonnull, readonly) NSDictionary<NSString *, SDCParsedField *> *fieldsByName;
/**
 * Added in version 6.1.0
 *
 * The order of the fields matches the order in the original data string. The fields are data format specific. Consult the data format documentation for information on available fields.
 */
@property (nonatomic, nonnull, readonly) NSArray<SDCParsedField *> *fields;

@end

NS_ASSUME_NONNULL_END
