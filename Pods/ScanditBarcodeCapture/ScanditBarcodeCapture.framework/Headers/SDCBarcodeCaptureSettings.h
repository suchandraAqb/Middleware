/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <Foundation/Foundation.h>

#import <ScanditCaptureCore/SDCBase.h>
#import <ScanditBarcodeCapture/SDCSymbology.h>
#import <ScanditBarcodeCapture/SDCCompositeType.h>

@class SDCSymbologySettings;
@protocol SDCLocationSelection;

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.0.0
 *
 * Holds all the barcode recognition related settings, such as enabled symbologies and location selection. For the settings to take effect, they must be applied to a barcode capture instance using SDCBarcodeCapture.applySettings:completionHandler:.
 *
 * By default, all types of barcodes (symbologies) are disabled. To scan barcodes, you need to manually enable all the symbologies you want to scan in your application.
 *
 * The following lines of code show how to enable SDCSymbologyCode128 and apply the settings to barcode capture.
 *
 * @code
 * let settings = BarcodeCaptureSettings()
 * settings.set(symbology: .code128, enabled: true)
 * barcodeCapture.apply(settings, completionHandler: nil)
 * @endcode
 */
NS_SWIFT_NAME(BarcodeCaptureSettings)
SDC_EXPORTED_SYMBOL
@interface SDCBarcodeCaptureSettings : NSObject <NSCopying>

/**
 * Added in version 6.0.0
 *
 * Determines the time interval in which codes with the same symbology/data are filtered out as duplicates. By default, when the same code (data, symbology) is scanned in consecutive frames, it is reported again as a new scan. Use this property to change the interval or completely turn off duplicate filtering:
 *
 *   • Setting this property to value smaller than zero, means that the same code will not be reported again until the scanning has been stopped.
 *
 *   • Setting this property to a value of zero means that the same code will be reported every time it is found.
 *
 *   • Setting this property to a value larger than zero indicates the time that must pass between the same code to be reported again.
 *
 * The filtering is reset any time the capture mode is disabled (SDCDataCaptureMode.enabled is set to false) as this is when the session is cleaned and restarts from zero.
 */
@property (nonatomic, assign) NSTimeInterval codeDuplicateFilter;

/**
 * Added in version 6.0.0
 *
 * Returns the set of enabled symbologies.
 */
@property (nonatomic, nonnull, readonly)
    NSSet<NSNumber *> *enabledSymbologies NS_SWIFT_NAME(enabledSymbologyValues);

/**
 * Added in version 6.0.0
 *
 * Defines the strategy with which to select one out of many visible barcodes. See Location Selection Guide. By default, this property is nil and code selection is disabled.
 */
@property (nonatomic, strong, nullable) id<SDCLocationSelection> locationSelection;

/**
 * Added in version 6.6.0
 *
 * The enabled composite types. To enable composite codes scanning it is also needed to enable the symbologies that make up the specific type of composite code through enableSymbologiesForCompositeTypes:.
 */
@property (nonatomic, assign) SDCCompositeType enabledCompositeTypes;

/**
 * Added in version 6.0.0
 *
 * Creates new default settings instance. Recognition is setup for recognizing codes in the full image. Symbologies are all disabled. Before passing the settings to the SDCBarcodeCapture instance, make sure to enable the symbologies required by your application.
 */
+ (instancetype)settings;

/**
 * Added in version 6.0.0
 *
 * Get SDCSymbologySettings specific for the given SDCSymbology.
 *
 * Note that modifying the returned object doesn’t automatically apply the changes to SDCBarcodeCapture. After you made changes to the symbology settings, call SDCBarcodeCapture.applySettings:completionHandler: with these SDCBarcodeCaptureSettings to apply them.
 */
- (nonnull SDCSymbologySettings *)settingsForSymbology:(SDCSymbology)symbology;

/**
 * Added in version 6.0.0
 *
 * Sets a property to the provided value. Use this method to set properties that are not yet part of a stable API. Properties set through this method may or may not be used or change in a future release.
 */
- (void)setValue:(id)value forProperty:(NSString *)property NS_SWIFT_NAME(set(value:forProperty:));

/**
 * Added in version 6.0.0
 *
 * Retrieves the value of a previously set property. In case the property does not exist, nil is returned.
 */
- (nullable id)valueForProperty:(NSString *)property;

/**
 * Added in version 6.0.0
 *
 * Provides a convenient shortcut to enable decoding of particular symbologies without having to go through SDCSymbologySettings.
 * By default, all symbologies are turned off and symbologies need to be explicitly enabled.
 */
- (void)enableSymbologies:(nonnull NSSet<NSNumber *> *)symbologies;

/**
 * Added in version 6.6.0
 *
 * Enables all symbologies needed for the given composite types. To enable composite codes scanning it is also needed to enable the composite types through enabledCompositeTypes.
 * By default, all symbologies are turned off and symbologies need to be explicitly enabled.
 */
- (void)enableSymbologiesForCompositeTypes:(SDCCompositeType)types;

/**
 * Added in version 6.0.0
 *
 * Provides a convenient shortcut to enable/disable decoding of a particular symbology without having to go through SDCSymbologySettings.
 *
 * Some 1d barcode symbologies allow you to encode variable-length data. By default, the Scandit Data Capture SDK only scans barcodes in a certain length range.
 *
 * If your application requires scanning of one of these symbologies, and the length is falling outside the default range, you may need to adjust the active symbol counts for the symbology in addition to enabling it.
 */
- (void)setSymbology:(SDCSymbology)symbology
             enabled:(BOOL)enabled NS_SWIFT_NAME(set(symbology:enabled:));

@end

NS_ASSUME_NONNULL_END
