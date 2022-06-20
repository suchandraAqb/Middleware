/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <ScanditCaptureCore/SDCBase.h>
#import <ScanditBarcodeCapture/SDCBarcodeSelectionType.h>
#import <ScanditBarcodeCapture/SDCBarcodeSelectionTapBehavior.h>
#import <ScanditBarcodeCapture/SDCBarcodeSelectionFreezeBehavior.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.6.0
 *
 * Tap based selection, customizable via freezeBehavior and tapBehavior.
 */
NS_SWIFT_NAME(BarcodeSelectionTapSelection)
SDC_EXPORTED_SYMBOL
@interface SDCBarcodeSelectionTapSelection : NSObject <SDCBarcodeSelectionType>

/**
 * Added in version 6.6.0
 *
 * Freeze behavior to use, defaults to SDCBarcodeSelectionFreezeBehaviorManual
 */
@property (nonatomic) SDCBarcodeSelectionFreezeBehavior freezeBehavior;
/**
 * Added in version 6.6.0
 *
 * Tap behavior to use, defaults to SDCBarcodeSelectionTapBehaviorToggleSelection
 */
@property (nonatomic) SDCBarcodeSelectionTapBehavior tapBehavior;

/**
 * Added in version 6.6.0
 *
 * Creates a new SDCBarcodeSelectionTapSelection instance.
 */
+ (instancetype)tapSelection;
+ (instancetype)tapSelectionWithFreezeBehavior:(SDCBarcodeSelectionFreezeBehavior)freezeBehavior
                                   tapBehavior:(SDCBarcodeSelectionTapBehavior)tapBehavior;

@end

NS_ASSUME_NONNULL_END
