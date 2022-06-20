/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <ScanditCaptureCore/SDCBase.h>
#import <ScanditBarcodeCapture/SDCBarcodeSelectionType.h>

@protocol SDCBarcodeSelectionStrategy;

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.6.0
 *
 * Aimer based selection, customizable via selectionStrategy.
 */
NS_SWIFT_NAME(BarcodeSelectionAimerSelection)
SDC_EXPORTED_SYMBOL
@interface SDCBarcodeSelectionAimerSelection : NSObject <SDCBarcodeSelectionType>

/**
 * Added in version 6.6.0
 *
 * The selection strategy to use. Defaults to SDCBarcodeSelectionManualSelectionStrategy.
 */
@property (nonatomic, strong, nonnull) id<SDCBarcodeSelectionStrategy> selectionStrategy;

/**
 * Added in version 6.6.0
 *
 * Creates a new SDCBarcodeSelectionAimerSelection instance.
 */
+ (instancetype)aimerSelection;

@end

NS_ASSUME_NONNULL_END
