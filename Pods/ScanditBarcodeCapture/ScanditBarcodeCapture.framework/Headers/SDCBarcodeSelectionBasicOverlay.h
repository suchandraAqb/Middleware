/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import <ScanditCaptureCore/SDCBase.h>
#import <ScanditCaptureCore/SDCDataCaptureOverlay.h>

@class SDCBarcodeSelection;
@class SDCBrush;
@class SDCBarcode;
@class SDCDataCaptureView;
@protocol SDCViewfinder;

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.6.0
 *
 * An overlay for SDCDataCaptureView that shows a simple augmentation over each selected barcode.
 *
 * To display the augmentations, this overlay must be attached to a SDCDataCaptureView. This may be done either by creating it with overlayWithBarcodeSelection:forDataCaptureView: with a non-null view parameter or by passing this overlay to SDCDataCaptureView.addOverlay:.
 *
 * A user of this class may configure the appearance of the augmentations by configuring the brush properties.
 */
NS_SWIFT_NAME(BarcodeSelectionBasicOverlay)
SDC_EXPORTED_SYMBOL
@interface SDCBarcodeSelectionBasicOverlay : UIView <SDCDataCaptureOverlay>

/**
 * Added in version 6.6.0
 *
 * The default brush applied to recognized tracked barcodes.
 */
@property (class, nonatomic, nonnull, readonly) SDCBrush *defaultTrackedBrush;
/**
 * Added in version 6.6.0
 *
 * The default brush applied to aimed barcodes.
 */
@property (class, nonatomic, nonnull, readonly) SDCBrush *defaultAimedBrush;
/**
 * Added in version 6.6.0
 *
 * The default brush applied to barcodes currently being selected.
 */
@property (class, nonatomic, nonnull, readonly) SDCBrush *defaultSelectingBrush;
/**
 * Added in version 6.6.0
 *
 * The default brush applied to selected barcodes.
 */
@property (class, nonatomic, nonnull, readonly) SDCBrush *defaultSelectedBrush;

/**
 * Added in version 6.6.0
 *
 * The brush applied to recognized tracked barcodes, by default the value is set to defaultTrackedBrush.
 * Setting this brush to SDCBrush.transparentBrush hides all tracked barcodes.
 */
@property (nonatomic, strong, nonnull) SDCBrush *trackedBrush;
/**
 * Added in version 6.6.0
 *
 * The brush applied to the barcode that is currently being aimed at, by default the value is set to defaultAimedBrush.
 */
@property (nonatomic, strong, nonnull) SDCBrush *aimedBrush;
/**
 * Added in version 6.6.0
 *
 * The brush applied to the barcodes for the short moment when they are being selected, by default the value is set to defaultSelectingBrush.
 */
@property (nonatomic, strong, nonnull) SDCBrush *selectingBrush;
/**
 * Added in version 6.6.0
 *
 * The brush applied to selected barcodes, by default the value is set to defaultSelectedBrush.
 * Setting this brush to SDCBrush.transparentBrush hides all selected barcodes.
 */
@property (nonatomic, strong, nonnull) SDCBrush *selectedBrush;

/**
 * Added in version 6.6.0
 *
 * When set to YES, this overlay will visualize some hints explaining how to use barcode selection.
 *
 * By default this property is YES.
 */
@property (nonatomic, assign) BOOL shouldShowHints;
/**
 * Added in version 6.6.0
 *
 * When set to YES, this overlay will visualize the active scan area used for BarcodeSelection. This is useful to check margins defined on the SDCDataCaptureView are set correctly. This property is meant for debugging during development and is not intended for use in production.
 *
 * By default this property is NO.
 */
@property (nonatomic, assign) BOOL shouldShowScanAreaGuides;
/**
 * Added in version 6.6.0
 *
 * The viewfinder of the overlay. The viewfinder is only visible when the selection type is SDCBarcodeSelectionAimerSelection.
 */
@property (nonatomic, strong, nonnull, readonly) id<SDCViewfinder> viewfinder;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)decoder NS_UNAVAILABLE;

/**
 * Added in version 6.6.0
 *
 * Constructs a new barcode selection basic overlay for the barcode selection instance. For the overlay to be displayed on screen, it must be added to a SDCDataCaptureView.
 */
+ (instancetype)overlayWithBarcodeSelection:(nonnull SDCBarcodeSelection *)barcodeSelection
    NS_SWIFT_NAME(init(barcodeSelection:));
/**
 * Added in version 6.6.0
 *
 * Constructs a new barcode selection basic overlay for the barcode selection instance. The overlay is automatically added to the view.
 */
+ (instancetype)overlayWithBarcodeSelection:(nonnull SDCBarcodeSelection *)barcodeSelection
                         forDataCaptureView:(nullable SDCDataCaptureView *)view
    NS_SWIFT_NAME(init(barcodeSelection:view:));

/**
 * Added in version 6.6.0
 *
 * Clears all currently displayed visualizations for the on screen barcodes.
 *
 * This only applies to the currently displayed barcodes, the visualizations for the new ones will still appear.
 */
- (void)clearSelectedBarcodeBrushes;

@end

NS_ASSUME_NONNULL_END
