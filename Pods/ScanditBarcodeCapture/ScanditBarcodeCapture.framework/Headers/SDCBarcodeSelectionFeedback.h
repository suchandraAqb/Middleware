/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <ScanditCaptureCore/SDCBase.h>

@class SDCFeedback;

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.6.0
 *
 * Determines what feedback (vibration, sound) should be emitted when reading barcodes.
 * The feedback is specified for each SDCBarcodeSelection instance separately and can be changed
 * through the feedback property by either modifying an existing
 * instance of this class, or by assigning a new one.
 *
 * As of now, this class only allows to configure the feedback that gets emitted when a barcode is selected, through the selection property.
 *
 * See documentation on the SDCBarcodeSelection.feedback property for usage samples.
 */
NS_SWIFT_NAME(BarcodeSelectionFeedback)
SDC_EXPORTED_SYMBOL
@interface SDCBarcodeSelectionFeedback : NSObject

/**
 * Added in version 6.6.0
 *
 * Returns a barcode selection feedback with default configuration:
 *
 *   • default click sound
 *
 *   • no vibration
 */
@property (class, nonatomic, readonly) SDCBarcodeSelectionFeedback *defaultFeedback;

/**
 * Added in version 6.6.0
 *
 * A feedback for a selection event.
 */
@property (nonatomic, strong, nonnull) SDCFeedback *selection;
/**
 * Added in version 6.9.0
 *
 * Returns the JSON representation of the feedback.
 */
@property (nonatomic, nonnull, readonly) NSString *JSONString;

+ (nullable instancetype)barcodeSelectionFeedbackFromJSONString:(nonnull NSString *)JSONString
                                                          error:
                                                              (NSError *_Nullable *_Nullable)error;
@end

NS_ASSUME_NONNULL_END
