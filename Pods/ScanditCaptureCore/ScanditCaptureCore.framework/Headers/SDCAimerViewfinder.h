/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <ScanditCaptureCore/SDCBase.h>
#import <ScanditCaptureCore/SDCViewfinder.h>

@class UIColor;

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.6.0
 *
 * Aimer viewfinder with an embedded Scandit logo. This is the recommended viewfinder when using SDCRadiusLocationSelection and it is automatically displayed in SDCBarcodeSelection when configured to use SDCBarcodeSelectionAimerSelection.
 *
 * To use this viewfinder, create a new instance and assign it to the overlay, e.g. the barcode capture overlay via the SDCBarcodeCaptureOverlay.viewfinder property.
 */
NS_SWIFT_NAME(AimerViewfinder)
SDC_EXPORTED_SYMBOL
@interface SDCAimerViewfinder : NSObject <SDCViewfinder>

/**
 * Added in version 6.6.0
 *
 * Returns a new aimer viewfinder with default parameters.
 */
+ (nonnull instancetype)viewfinder;

/**
 * Added in version 6.6.0
 *
 * The color of the outer frame.
 */
@property (nonatomic, strong, nonnull) UIColor *frameColor;
/**
 * Added in version 6.6.0
 *
 * The color of the central dot. The alpha value is ignored and remains at 70%.
 */
@property (nonatomic, strong, nonnull) UIColor *dotColor;

@end

NS_ASSUME_NONNULL_END
