/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <ScanditCaptureCore/SDCBase.h>
#import <ScanditCaptureCore/SDCMeasureUnit.h>
#import <ScanditCaptureCore/SDCViewfinder.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.4.0
 *
 * A viewfinder that is a container for other viewfinders. It allows you to have multiple viewfinders in one overlay.
 *
 * To use this viewfinder, create a new instance of it and assign it to the overlay, e.g. assign it to the barcode capture overlay with the SDCBarcodeCaptureOverlay.viewfinder property.
 */
NS_SWIFT_NAME(CombinedViewfinder)
SDC_EXPORTED_SYMBOL
@interface SDCCombinedViewfinder : NSObject <SDCViewfinder>

/**
 * Added in version 6.4.0
 *
 * Returns a new combined viewfinder.
 */
+ (nonnull instancetype)viewfinder;

/**
 * Added in version 6.4.0
 *
 * Adds viewfinder.
 */
- (void)addViewfinder:(nonnull id<SDCViewfinder>)viewfinder;
/**
 * Added in version 6.4.0
 *
 * Adds a viewfinder that uses the specified point of interest when drawing
 * the viewfinder on the overlay.
 */
- (void)addViewfinder:(nonnull id<SDCViewfinder>)viewfinder
    withPointOfInterest:(SDCPointWithUnit)pointOfInterest;
/**
 * Added in version 6.4.0
 *
 * Removes the given viewfinder.
 */
- (void)removeViewfinder:(nonnull id<SDCViewfinder>)viewfinder;
/**
 * Added in version 6.4.0
 *
 * Removes all contained viewfinders.
 */
- (void)removeAll;

@end

NS_ASSUME_NONNULL_END
