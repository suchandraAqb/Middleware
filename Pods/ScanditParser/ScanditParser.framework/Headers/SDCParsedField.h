/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <Foundation/Foundation.h>

#import <ScanditCaptureCore/SDCBase.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.1.0
 */
NS_SWIFT_NAME(ParsedField)
SDC_EXPORTED_SYMBOL
@interface SDCParsedField : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 * Added in version 6.1.0
 *
 * The name of the field.
 */
@property (nonatomic, readonly) NSString *name;
/**
 * Added in version 6.1.0
 *
 * The parsed data contained in this field. Depending on the field type, this returns a NSNumber, NSDictionary or NSString instance. Consult the field documentation for information on the type for the fields you are interested in.
 */
@property (nonatomic, nullable, readonly) NSObject *parsed;
/**
 * Added in version 6.1.0
 *
 * The raw string that represents this field in the input string/data.
 */
@property (nonatomic, readonly) NSString *rawString;
/**
 * Added in version 6.1.0
 *
 * The raw string that represents this field in the input string/data.
 */
@property (nonatomic, strong, readonly) NSArray<NSString *> *issues;
@end

NS_ASSUME_NONNULL_END
