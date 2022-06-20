/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <ScanditCaptureCore/SDCBase.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.8.0
 *
 * Standard rectangular viewfinder animation made up of an appear animation as well as a looping animation following the appearance.
 */
NS_SWIFT_NAME(RectangularViewfinderAnimation)
SDC_EXPORTED_SYMBOL
@interface SDCRectangularViewfinderAnimation : NSObject

/**
 * Added in version 6.8.0
 *
 * Whether the looping animation should be executed.
 */
@property (nonatomic, readonly) BOOL isLooping;
/**
 * Added in version 6.8.0
 *
 * Returns the JSON representation of the rectangular viewfinder animation
 */
@property (nonatomic, nonnull, readonly) NSString *JSONString;

/**
 * Added in version 6.8.0
 */
- (nonnull instancetype)initWithLooping:(BOOL)looping;

@end

NS_ASSUME_NONNULL_END
