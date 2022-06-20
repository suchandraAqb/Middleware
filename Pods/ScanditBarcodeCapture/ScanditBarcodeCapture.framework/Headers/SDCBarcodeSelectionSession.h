/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <ScanditCaptureCore/SDCBase.h>

@class SDCBarcode;

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.6.0
 *
 * Holds the ongoing state of a running SDCBarcodeSelection. An instance of this class is passed to SDCBarcodeSelectionListener.barcodeSelection:didUpdateSelection:frameData: when new barcodes are selected or currently selected barcodes are unselected.
 *
 * The barcode selection session should only be accessed from within barcodeSelection:didUpdateSelection:frameData: to which it is provided as an argument. It is not safe to be accessed from anywhere else since it may be concurrently modified.
 *
 * Specifically no reference to selectedBarcodes should be kept and traversed outside of barcodeSelection:didUpdateSelection:frameData:. Instead a copy of the list should be made to avoid concurrent modification. The individual barcodes can be referenced without copying as they are not further modified.
 */
NS_SWIFT_NAME(BarcodeSelectionSession)
SDC_EXPORTED_SYMBOL
@interface SDCBarcodeSelectionSession : NSObject

/**
 * Added in version 6.6.0
 *
 * List of codes that were newly selected in the last processed frame.
 */
@property (nonatomic, nonnull, readonly) NSArray<SDCBarcode *> *newlySelectedBarcodes;
/**
 * Added in version 6.6.0
 *
 * List of codes that were unselected in the last processed frame.
 */
@property (nonatomic, nonnull, readonly) NSArray<SDCBarcode *> *newlyUnselectedBarcodes;
/**
 * Added in version 6.6.0
 *
 * List of currently selected codes.
 */
@property (nonatomic, nonnull, readonly) NSArray<SDCBarcode *> *selectedBarcodes;
/**
 * Added in version 6.6.0
 *
 * The identifier of the current frame sequence.
 *
 * As long as there is no interruptions of frames coming from the camera, the frameSequenceId will stay the same.
 */
@property (nonatomic, readonly) NSInteger frameSequenceId;
/**
 * Added in version 6.6.0
 *
 * The identifier of the last processed frame.
 */
@property (nonatomic, readonly) NSInteger lastProcessedFrameId;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 * Added in version 6.6.0
 *
 * Resets the barcode selection session, effectively clearing the history of selected codes.
 */
- (void)reset;
/**
 * Added in version 6.6.0
 *
 * Returns how many times the given SDCBarcode was selected.
 */
- (NSInteger)countForBarcode:(nonnull SDCBarcode *)barcode;

@end

NS_ASSUME_NONNULL_END
