/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <ScanditCaptureCore/SDCBase.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SDCZoomGesture;

/**
 * Added in version 6.7.0
 *
 * Listener for observing the zoom gesture. This listener is typically used when you want to react to zoom gestures being triggered to update UI elements or similar.
 */
@protocol SDCZoomGestureListener <NSObject>
/**
 * Added in version 6.7.0
 *
 * Called when a zoom in gesture is triggered.
 */
- (void)zoomGestureDidZoomIn:(nonnull id<SDCZoomGesture>)zoomGesture;
/**
 * Added in version 6.7.0
 *
 * Called when a zoom out gesture is triggered.
 */
- (void)zoomGestureDidZoomOut:(nonnull id<SDCZoomGesture>)zoomGesture;
@end

/**
 * Added in version 6.6.0
 *
 * Common protocol for all the zoom gestures.
 */
NS_SWIFT_NAME(ZoomGesture)
@protocol SDCZoomGesture <NSObject>
/**
 * Added in version 6.7.0
 *
 * Returns the JSON representation of the zoom gesture.
 */
@property (nonatomic, nonnull, readonly) NSString *JSONString;
/**
 * Added in version 6.1.0
 *
 * Adds the listener to this gesture.
 *
 * In case the same listener is already observing this instance, calling this method will not add the listener again. The listener is stored using a weak reference and must thus be retained by the caller for it to not go out of scope.
 */
- (void)addListener:(nonnull id<SDCZoomGestureListener>)listener;
/**
 * Added in version 6.1.0
 *
 * Removes a previously added listener from this gesture.
 *
 * In case the listener is not currently observing this instance, calling this method has no effect.
 */
- (void)removeListener:(nonnull id<SDCZoomGestureListener>)listener;
/**
 * Added in version 6.7.0
 *
 * Triggers a zoom in as if the zoom in gesture was performed.
 */
- (void)triggerZoomIn;
/**
 * Added in version 6.7.0
 *
 * Triggers a zoom out as if the zoom out gesture was performed.
 */
- (void)triggerZoomOut;
@end

/**
 * Added in version 6.6.0
 *
 * Swipe to zoom gesture.
 */
NS_SWIFT_NAME(SwipeToZoom)
SDC_EXPORTED_SYMBOL
@interface SDCSwipeToZoom : NSObject <SDCZoomGesture>

/**
 * Added in version 6.7.0
 *
 * Implemented from SDCZoomGesture. See SDCZoomGesture.JSONString.
 */
@property (nonatomic, nonnull, readonly) NSString *JSONString;

/**
 * Added in version 6.6.0
 *
 * Constructs a new SwipeToZoom instance. The zoom levels can be changed in the SDCCameraSettings through zoomFactor (zoom factor when zoomed out) and zoomGestureZoomFactor (zoom factor when zoomed in).
 */
+ (nonnull SDCSwipeToZoom *)swipeToZoom;

@end

NS_ASSUME_NONNULL_END
