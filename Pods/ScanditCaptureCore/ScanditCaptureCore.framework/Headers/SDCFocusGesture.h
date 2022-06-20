/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <ScanditCaptureCore/SDCBase.h>
#import <ScanditCaptureCore/SDCMeasureUnit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SDCFocusGesture;

/**
 * Added in version 6.7.0
 *
 * Listener for observing the focus gesture. This listener is typically used when you want to react to focus gestures being triggered to update UI elements or similar.
 */
NS_SWIFT_NAME(FocusGestureListener)
@protocol SDCFocusGestureListener <NSObject>
/**
 * Added in version 6.7.0
 *
 * Triggers a focus as if the gesture was executed.
 */
- (void)focusGesture:(nonnull id<SDCFocusGesture>)focusGesture
    didTriggerFocusAtPoint:(SDCPointWithUnit)pointWithUnit;
@end

/**
 * Added in version 6.6.0
 *
 * Common protocol for all the focus gestures.
 */
NS_SWIFT_NAME(FocusGesture)
@protocol SDCFocusGesture <NSObject>
/**
 * Added in version 6.7.0
 *
 * Returns the JSON representation of the focus gesture.
 */
@property (nonatomic, nonnull, readonly) NSString *JSONString;
/**
 * Added in version 6.7.0
 *
 * Adds the listener to this gesture.
 *
 * In case the same listener is already observing this instance, calling this method will not add the listener again. The listener is stored using a weak reference and must thus be retained by the caller for it to not go out of scope.
 */
- (void)addListener:(nonnull id<SDCFocusGestureListener>)listener;
/**
 * Added in version 6.7.0
 *
 * Removes a previously added listener from this gesture.
 *
 * In case the listener is not currently observing this instance, calling this method has no effect.
 */
- (void)removeListener:(nonnull id<SDCFocusGestureListener>)listener;
/**
 * Added in version 6.7.0
 *
 * Triggers a focus as if the focus gesture was performed.
 */
- (void)triggerFocus:(SDCPointWithUnit)pointWithUnit;
@end

/**
 * Added in version 6.6.0
 *
 * Tap to focus gesture.
 */
NS_SWIFT_NAME(TapToFocus)
SDC_EXPORTED_SYMBOL
@interface SDCTapToFocus : NSObject <SDCFocusGesture>

/**
 * Added in version 6.7.0
 *
 * Implemented from SDCFocusGesture. See SDCFocusGesture.JSONString.
 */
@property (nonatomic, nonnull, readonly) NSString *JSONString;

/**
 * Added in version 6.6.0
 *
 * Constructs a new TapToFocus instance. The focus strategy can be changed in the SDCCameraSettings through focusGestureStrategy.
 */
+ (nonnull SDCTapToFocus *)tapToFocus;

@end

NS_ASSUME_NONNULL_END
