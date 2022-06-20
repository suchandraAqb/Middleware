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
 * Enumeration of possible focus gesture strategies to use.
 */
typedef NS_CLOSED_ENUM(NSUInteger, SDCFocusGestureStrategy) {
/**
     * Added in version 6.6.0
     *
     * No effect when performing a focus gesture.
     */
    SDCFocusGestureStrategyNone,
/**
     * Added in version 6.6.0
     *
     * Focus on PoI and only change with next focus gesture.
     */
    SDCFocusGestureStrategyManual,
/**
     * Added in version 6.6.0
     *
     * Focus on PoI and reset to previous focus strategy on capture.
     */
    SDCFocusGestureStrategyManualUntilCapture,
/**
     * Added in version 6.7.0
     *
     * Continuously focus on the location of the gesture and only change with next focus gesture.
     */
    SDCFocusGestureStrategyAutoOnLocation
} NS_SWIFT_NAME(FocusGestureStrategy);

/**
 * Added in version 6.7.0
 */
SDC_EXTERN NSString *_Nonnull NSStringFromFocusGestureStrategy(SDCFocusGestureStrategy focusGestureStrategy) NS_SWIFT_NAME(getter:SDCFocusGestureStrategy.jsonString(self:));
/**
 * Added in version 6.7.0
 */
SDC_EXTERN BOOL SDCFocusGestureStrategyFromJSONString(NSString *_Nonnull JSONString, SDCFocusGestureStrategy *_Nonnull focusGestureStrategy);

