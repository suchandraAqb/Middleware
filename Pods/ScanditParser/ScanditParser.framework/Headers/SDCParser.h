/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <Foundation/Foundation.h>

#import <ScanditCaptureCore/SDCBase.h>
#import <ScanditCaptureCore/SDCDataCaptureComponent.h>

@class SDCParsedData;
@class SDCDataCaptureContext;

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.1.0
 *
 * Data formats supported by the SDCParser.
 */
typedef NS_CLOSED_ENUM(NSUInteger, SDCParserDataFormat) {
/**
     * Added in version 6.1.0
     */
    SDCParserDataFormatGS1AI NS_SWIFT_NAME(gs1AI),
/**
     * Added in version 6.1.0
     */
    SDCParserDataFormatHIBC NS_SWIFT_NAME(hibc),
/**
     * Added in version 6.1.0
     */
    SDCParserDataFormatDLID NS_SWIFT_NAME(dlid),
/**
     * Added in version 6.1.0
     */
    SDCParserDataFormatMRTD NS_SWIFT_NAME(mrtd),
/**
     * Added in version 6.1.0
     */
    SDCParserDataFormatSwissQR NS_SWIFT_NAME(swissQR),
/**
     * Added in version 6.1.0
     */
    SDCParserDataFormatVIN NS_SWIFT_NAME(vin),
/**
     * Added in version 6.3.0
     */
    SDCParserDataFormatUsUsid NS_SWIFT_NAME(usUsid),
} NS_SWIFT_NAME(ParserDataFormat);

/**
 * Added in version 6.1.0
 */
NS_SWIFT_NAME(Parser)
SDC_EXPORTED_SYMBOL
@interface SDCParser : NSObject <SDCDataCaptureComponent>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 * Added in version 6.1.0
 *
 * Create new parser for the provided data format and context. The license key with which the data capture context was constructed must have the parser feature enabled.
 *
 * In case the parser could not be created, more detailed information on why creation failed is stored in the error argument, if non-nil.
 */
+ (nullable instancetype)parserForContext:(nonnull SDCDataCaptureContext *)context
                                   format:(SDCParserDataFormat)dataFormat
                                    error:(NSError *_Nullable *_Nullable)error
    NS_SWIFT_NAME(init(context:format:));
/**
 * Added in version 6.1.0
 *
 * Parses the data string and returns the contained field in the result object. Typical inputs to this method is the data contained in a barcode (see SDCBarcode.data)
 *
 * In case the data string could not be parsed, the error message is contained in the error parameter.
 *
 * specify exception type
 */
- (nullable SDCParsedData *)parseString:(NSString *)string
                                  error:(NSError *_Nullable *_Nullable)error;
/**
 * Added in version 6.1.0
 *
 * Parses the raw data and returns the contained field in the result object. Typical inputs to this method is the raw data of a barcode (see SDCBarcode.rawData).
 *
 * In case the data string could not be parsed, the error message is contained in the error parameter.
 *
 * specify exception type
 */
- (nullable SDCParsedData *)parseRawData:(NSData *)data error:(NSError *_Nullable *_Nullable)error;
/**
 * Added in version 6.1.0
 *
 * Set the provided options on the parser.
 *
 * Available options depend on the data format type of the parser and are documented for each of the supported data formats.
 *
 * In case the options are invalid, this method returns NO and the error argument is filled with more information on the failure.
 */
- (BOOL)setOptions:(NSDictionary<NSString *, NSObject *> *)options
             error:(NSError *_Nullable *_Nullable)error;

/**
 * Added in version 6.3.0
 *
 * Construct a new parser with the provided JSON serialization. See Serialization for details.
 */
+ (nullable instancetype)parserFromJSONString:(nonnull NSString *)JSONString
                                      context:(nonnull SDCDataCaptureContext *)context
                                        error:(NSError *_Nullable *_Nullable)error;
/**
 * Added in version 6.3.0
 *
 * Updates the parser according to a JSON serialization. See Serialization for details.
 */
- (BOOL)updateFromJSONString:(nonnull NSString *)JSONString
                       error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
