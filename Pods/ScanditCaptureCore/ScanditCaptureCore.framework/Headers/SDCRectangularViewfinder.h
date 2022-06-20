/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <ScanditCaptureCore/SDCBase.h>
#import <ScanditCaptureCore/SDCViewfinder.h>
#import <ScanditCaptureCore/SDCMeasureUnit.h>

@class UIColor;
@class SDCSizeWithUnitAndAspect;
@class SDCRectangularViewfinderAnimation;

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.8.0
 *
 * The style of the SDCRectangularViewfinder.
 */
typedef NS_CLOSED_ENUM(NSUInteger, SDCRectangularViewfinderStyle) {
/**
     * Added in version 6.8.0
     *
     * Legacy style from versions before 6.8.
     */
    SDCRectangularViewfinderStyleLegacy,
/**
     * Added in version 6.8.0
     *
     * New style from version 6.8 onwards with square corners.
     */
    SDCRectangularViewfinderStyleSquare,
/**
     * Added in version 6.8.0
     *
     * New style from version 6.8 onwards with rounded corners.
     */
    SDCRectangularViewfinderStyleRounded,
} NS_SWIFT_NAME(RectangularViewfinderStyle);

SDC_EXTERN
NSString *_Nonnull NSStringFromRectangularViewfinderStyle(SDCRectangularViewfinderStyle style) NS_SWIFT_NAME(getter:SDCRectangularViewfinderStyle.jsonString(self:));
/**
 * Added in version 6.8.0
 *
 * Deserialize the viewfinder style from a JSON string.
 */
SDC_EXTERN BOOL SDCRectangularViewfinderStyleFromJSONString(NSString *_Nonnull JSONString,
                                                            SDCRectangularViewfinderStyle *_Nonnull style);

/**
 * Added in version 6.8.0
 *
 * The style of the lines drawn as part of the SDCRectangularViewfinder for all styles except SDCRectangularViewfinderStyleLegacy.
 */
typedef NS_CLOSED_ENUM(NSUInteger, SDCRectangularViewfinderLineStyle) {
/**
     * Added in version 6.8.0
     *
     * Draws lines with a width of 5 dips/points.
     */
    SDCRectangularViewfinderLineStyleBold,
/**
     * Added in version 6.8.0
     *
     * Draws lines with a width of 3 dips/points.
     */
    SDCRectangularViewfinderLineStyleLight,
} NS_SWIFT_NAME(RectangularViewfinderLineStyle);

/**
 * Added in version 6.8.0
 *
 * Serialize the viewfinder style in a JSON string.
 *
 * Added in version 6.8.0
 *
 * Serialize the viewfinder line style in a JSON string.
 */
SDC_EXTERN NSString *_Nonnull NSStringFromRectangularViewfinderLineStyle(SDCRectangularViewfinderLineStyle style) NS_SWIFT_NAME(getter:SDCRectangularViewfinderLineStyle.jsonString(self:));
/**
 * Added in version 6.8.0
 *
 * Deserialize the viewfinder line style from a JSON string.
 */
SDC_EXTERN BOOL SDCRectangularViewfinderLineStyleFromJSONString(NSString *_Nonnull JSONString,
                                                                SDCRectangularViewfinderLineStyle *_Nonnull style);

/**
 * Added in version 6.0.0
 *
 * Rectangular viewfinder with an embedded Scandit logo. The rectangle is always centered on the point of interest of the view.
 *
 * The rectangular viewfinder is displayed when the recognition is active and hidden when it is not.
 *
 * To use this viewfinder, create a new instance and assign it to the overlay, e.g. the barcode capture overlay by assigning to the SDCBarcodeCaptureOverlay.viewfinder property.
 */
NS_SWIFT_NAME(RectangularViewfinder)
SDC_EXPORTED_SYMBOL
@interface SDCRectangularViewfinder : NSObject <SDCViewfinder>

/**
 * Added in version 6.0.0
 *
 * The color used to draw the logo and viewfinder when the mode is enabled. The color is always used at full opacity, changing the alpha value has no effect.
 */
@property (nonatomic, strong, nonnull) UIColor *color;
/**
 * Added in version 6.3.0
 *
 * The color used to draw the logo and viewfinder when the mode is disabled. By default transparent.
 */
@property (nonatomic, strong, nonnull) UIColor *disabledColor;
/**
 * Added in version 6.8.0
 *
 * The style of the viewfinder.
 */
@property (nonatomic, readonly) SDCRectangularViewfinderStyle style;
/**
 * Added in version 6.8.0
 *
 * The style of the viewfinder’s lines. Not available for SDCRectangularViewfinderStyleLegacy.
 */
@property (nonatomic, readonly) SDCRectangularViewfinderLineStyle lineStyle;
/**
 * Added in version 6.0.0
 *
 * The size and sizing mode of the viewfinder.
 */
@property (nonatomic, readonly) SDCSizeWithUnitAndAspect *sizeWithUnitAndAspect;
/**
 * Added in version 6.8.0
 *
 * The amount the area outside the viewfinder’s rectangle is dimmed by. Accepts values between 0 (no dimming) and 1 (fully blacked out). Not available for SDCRectangularViewfinderStyleLegacy.
 */
@property (nonatomic, assign) CGFloat dimming;
/**
 * Added in version 6.8.0
 *
 * The animation used for the viewfinder, if any. Not available for SDCRectangularViewfinderStyleLegacy.
 */
@property (nonatomic, strong, nullable) SDCRectangularViewfinderAnimation *animation;

/**
 * Added in version 6.0.0
 */
+ (nonnull instancetype)viewfinder;
/**
 * Added in version 6.8.0
 */
+ (nonnull instancetype)viewfinderWithStyle:(SDCRectangularViewfinderStyle)style;
/**
 * Added in version 6.8.0
 *
 * Constructs a new rectangular viewfinder with the specified style and line style.
 */
+ (nonnull instancetype)viewfinderWithStyle:(SDCRectangularViewfinderStyle)style
                                  lineStyle:(SDCRectangularViewfinderLineStyle)lineStyle;

/**
 * Added in version 6.0.0
 *
 * Sets the horizontal and vertical size of the viewfinder to the provided value. When the unit is relative (unit in either x or y is SDCMeasureUnitFraction) the size is computed relative to the view size minus the scan area margins.
 */
- (void)setSize:(SDCSizeWithUnit)size;
/**
 * Added in version 6.0.0
 *
 * Sets the width of the viewfinder and compute height automatically based on the provided height/width aspect ratio. When the unit is relative (SDCMeasureUnitFraction), the width is computed relative to the view size minus the scan area margins.
 */
- (void)setWidth:(SDCFloatWithUnit)width aspectRatio:(CGFloat)heightToWidthAspectRatio;
/**
 * Added in version 6.0.0
 *
 * Sets the height of the viewfinder and compute width automatically based on the provided width/height aspect ratio. When the unit is relative (SDCMeasureUnitFraction), the height is computed relative to the view size minus the scan area margins.
 */
- (void)setHeight:(SDCFloatWithUnit)height aspectRatio:(CGFloat)widthToHeightAspectRatio;
/**
 * Added in version 6.8.0
 *
 * Sets the viewfinder size on the short side of the scan area as fraction of the scan area size. The size on the long side is calculated based on the provided short side/long side aspectRatio.
 */
- (void)setShorterDimension:(CGFloat)fraction aspectRatio:(CGFloat)aspectRatio;

@end

NS_ASSUME_NONNULL_END
