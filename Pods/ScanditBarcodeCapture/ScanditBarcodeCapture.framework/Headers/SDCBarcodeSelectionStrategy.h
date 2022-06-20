/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <ScanditCaptureCore/SDCBase.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.6.0
 *
 * The protocol for all barcode selection strategies. These strategies are used to configure SDCBarcodeSelectionAimerSelection.
 */
NS_SWIFT_NAME(BarcodeSelectionStrategy)
@protocol SDCBarcodeSelectionStrategy <NSObject>
@end

/**
 * Added in version 6.6.0
 *
 * Barcodes are selected automatically when aiming at them as soon as the intention is understood by our internal algorithms.
 */
NS_SWIFT_NAME(BarcodeSelectionAutoSelectionStrategy)
SDC_EXPORTED_SYMBOL
@interface SDCBarcodeSelectionAutoSelectionStrategy : NSObject <SDCBarcodeSelectionStrategy>

/**
 * Added in version 6.6.0
 *
 * Creates a new SDCBarcodeSelectionAutoSelectionStrategy instance.
 */
+ (instancetype)autoSelectionStrategy;

@end

/**
 * Added in version 6.6.0
 *
 * Barcodes are selected when aiming at them and tapping anywhere on the screen.
 */
NS_SWIFT_NAME(BarcodeSelectionManualSelectionStrategy)
SDC_EXPORTED_SYMBOL
@interface SDCBarcodeSelectionManualSelectionStrategy : NSObject <SDCBarcodeSelectionStrategy>

/**
 * Added in version 6.6.0
 *
 * Creates a new SDCBarcodeSelectionManualSelectionStrategy instance.
 */
+ (instancetype)manualSelectionStrategy;

@end

NS_ASSUME_NONNULL_END
