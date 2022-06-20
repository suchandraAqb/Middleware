/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <ScanditCaptureCore/SDCBase.h>
#import <ScanditBarcodeCapture/SDCCompositeType.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.6.0
 *
 * Description specific to a particular composite type.
 */
NS_SWIFT_NAME(CompositeTypeDescription)
SDC_EXPORTED_SYMBOL
@interface SDCCompositeTypeDescription : NSObject

/**
 * Added in version 6.6.0
 *
 * A list of descriptions, one for each individual SDCCompositeType.
 */
@property (class, nonatomic, nonnull, readonly)
    NSArray<SDCCompositeTypeDescription *> *allCompositeTypeDescriptions NS_SWIFT_NAME(all);

/**
 * Added in version 6.6.0
 *
 * All symbologies that can be part of a composite code with the given composite type.
 */
@property (nonatomic, nonnull, readonly) NSSet<NSNumber *> *symbologies;
/**
 * Added in version 6.6.0
 *
 * Returns the JSON representation of the symbology description.
 */
@property (nonatomic, nonnull, readonly) NSString *JSONString;
/**
 * Added in version 6.6.0
 *
 * The composite types described by the description.
 */
@property (nonatomic, readonly) SDCCompositeType compositeTypes;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (SDCCompositeTypeDescription *)descriptionFromCompositeType:(SDCCompositeType)compositeType;
/**
 * Added in version 6.6.0
 *
 * Creates a new composite type description for a given composite type.
 */
- (instancetype)initWithCompositeType:(SDCCompositeType)compositeType NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
