/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <ScanditCaptureCore/SDCBase.h>
#import <ScanditBarcodeCapture/SDCSymbology.h>

@class SDCSymbologySettings;

@protocol SDCBarcodeSelectionType;

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.6.0
 *
 * Holds all the barcode selection related settings, such as enabled symbologies and tap behavior. For the settings to take effect, they must be applied to a barcode selection instance using SDCBarcodeSelection.applySettings:completionHandler:.
 */
NS_SWIFT_NAME(BarcodeSelectionSettings)
SDC_EXPORTED_SYMBOL
@interface SDCBarcodeSelectionSettings : NSObject <NSCopying>

/**
 * Added in version 6.6.0
 *
 * Returns the set of enabled symbologies.
 */
@property (nonatomic, nonnull, readonly)
    NSSet<NSNumber *> *enabledSymbologies NS_SWIFT_NAME(enabledSymbologyValues);
/**
 * Added in version 6.6.0
 *
 * Determines the time interval in which codes with the same symbology/data are considered not automatically selectable again (automatic selection can happen through singleBarcodeAutoDetection). By default, when the same code (data, symbology) stays in view after just having been selected (manually or automatically) it will not be automatically selected again for 500 milliseconds. This property has no influence on manual selection by tapping. Use this property to change the interval or completely turn off duplicate filtering:
 *
 *   • Setting this property to value smaller than zero, means that the same code will not be automatically selectable again until the selection has been stopped.
 *
 *   • Setting this property to a value of zero means that the same code will be automatically selectable again immediately. In use cases that includes automatic selection this is likely never wanted.
 *
 *   • Setting this property to a value larger than zero indicates the time that must pass between the same code to be automatically selected again.
 */
@property (nonatomic, assign) NSTimeInterval codeDuplicateFilter;
/**
 * Added in version 6.6.0
 *
 * If true, when a single barcode is tracked it’s automatically selected. Defaults to NO.
 *
 * @remark This setting is still in beta and may not yet work reliably in all situations.
 */
@property (nonatomic, assign) BOOL singleBarcodeAutoDetection;
/**
 * Added in version 6.6.0
 *
 * This setting is used to define the method that SDCBarcodeSelection will use to select barcodes. Defaults to SDCBarcodeSelectionTapSelection.
 */
@property (nonatomic, nonnull, retain) id<SDCBarcodeSelectionType> selectionType;

/**
 * Added in version 6.6.0
 *
 * Creates a new barcode selection settings instance. All symbologies are disabled. Make sure to enable the symbologies required by your app before applying the settings to SDCBarcodeSelection with SDCBarcodeSelection.applySettings:completionHandler:.
 */
+ (instancetype)settings;

/**
 * Added in version 6.6.0
 *
 * Get SDCSymbologySettings specific for the given SDCSymbology.
 *
 * Note that modifying the returned object doesn’t automatically apply the changes to SDCBarcodeSelection. After you made changes to the symbology settings, call SDCBarcodeSelection.applySettings:completionHandler: with these SDCBarcodeSelectionSettings to apply them.
 */
- (nonnull SDCSymbologySettings *)settingsForSymbology:(SDCSymbology)symbology;

/**
 * Added in version 6.6.0
 *
 * This function provides a convenient shortcut to enabling decoding of particular symbologies without having to go through SDCSymbologySettings.
 * By default, all symbologies are turned off and symbologies need to be explicitly enabled.
 */
- (void)enableSymbologies:(nonnull NSSet<NSNumber *> *)symbologies;
/**
 * Added in version 6.6.0
 *
 * This function provides a convenient shortcut to enabling/disabling decoding of a particular symbology without having to go through SDCSymbologySettings.
 *
 * Some 1d barcode symbologies allow you to encode variable-length data. By default, the Scandit Data Capture SDK only scans barcodes in a certain length range.
 *
 * If your application requires scanning of one of these symbologies, and the length is falling outside the default range, you may need to adjust the active symbol counts for the symbology in addition to enabling it.
 */
- (void)setSymbology:(SDCSymbology)symbology
             enabled:(BOOL)enabled NS_SWIFT_NAME(set(symbology:enabled:));

/**
 * Added in version 6.6.0
 *
 * Sets property to the provided value. Use this method to set properties that are not yet part of a stable API. Properties set through this method may or may not be used or change in a future release.
 */
- (void)setValue:(id)value forProperty:(NSString *)property NS_SWIFT_NAME(set(value:forProperty:));
/**
 * Added in version 6.6.0
 *
 * Retrieves the value of a previously set property. In case the property does not exist, nil is returned.
 */
- (nullable id)valueForProperty:(NSString *)property;

@end

NS_ASSUME_NONNULL_END
