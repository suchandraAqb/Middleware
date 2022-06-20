/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <ScanditCaptureCore/SDCBase.h>

/**
 * Added in version 6.6.0
 *
 * Enum used to specify what happens when the user taps a barcode.
 */
typedef NS_CLOSED_ENUM(NSUInteger, SDCBarcodeSelectionTapBehavior) {
/**
     * Added in version 6.6.0
     *
     * Tapping an unselected barcode selects it. Tapping an already selected barcode will unselect it.
     */
    SDCBarcodeSelectionTapBehaviorToggleSelection,
/**
     * Added in version 6.6.0
     *
     * Tapping an unselected barcode selects it. Tapping on an already selected barcode will increment the count returned by SDCBarcodeSelectionSession.countForBarcode:.
     */
    SDCBarcodeSelectionTapBehaviorRepeatSelection
} NS_SWIFT_NAME(BarcodeSelectionTapBehavior);

