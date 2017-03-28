//
//  ORMPropertyCache.m
//  JSPatchDemoProject
//
//  Created by 晋爱元 on 2017/3/23.
//  Copyright © 2017年 jinaiyuan. All rights reserved.
//

#import "ORMPropertyCache.h"
#import "ORMPropertyInfo.h"
#import "ORMObject.h"
#import <objc/runtime.h>

@implementation ORMPropertyCache

+(NSArray<ORMPropertyInfo*>*) propertyInfoOfClass:(Class) klass{
    NSAssert([klass isSubclassOfClass:ORMObject.class], @"klass must be a subClass of ORMObject.");
    
    static NSMutableDictionary<NSString*,NSArray<ORMPropertyInfo*>*> *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSMutableDictionary alloc] init];
    });
    
    
    @synchronized (cache) {
        NSString *klassName = NSStringFromClass(klass);
        
        if (cache[klassName]) {
            return cache[klassName];
        }else{
            NSArray *sourceArray = [self parseClassProperty:klass];
            NSArray *sortedArray = [self sortedArrayByPropertyName:sourceArray];
            NSAssert((sortedArray.count>0), @"you must provide a property to be stored.");
            
            cache[klassName] = sortedArray;
            return sortedArray;
        }
    }
}

+ (NSArray<ORMPropertyInfo*>*) parseClassProperty:(Class) klass{
    unsigned int count = 0;
    objc_property_t *list = class_copyPropertyList(klass, &count);
    NSArray *ignoreProperties = [klass ignoreProperties];
    
    NSMutableArray<ORMPropertyInfo*> *propertyArray = [[NSMutableArray alloc] initWithCapacity:count];
    for (unsigned int idx = 0; idx < count; idx++){
        objc_property_t property = list[idx];
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        
        if (![ignoreProperties containsObject:propertyName]) {
            NSDictionary* colNameMapping = [klass colNameMapping];
            NSString *colName = colNameMapping[propertyName]? colNameMapping[propertyName] : propertyName;
            
            NSString *signature = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
            ORMPropertyType propertyType = [self valueTypeForSignature:signature];
            
            ORMPropertyInfo *propertyInfo = [[ORMPropertyInfo alloc] initWithPropertyName:propertyName colName:colName valueType:propertyType];
            [propertyArray addObject:propertyInfo];
        }
    }
    
    free(list);
    
    return propertyArray.copy;
}

//@see https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html

+ (ORMPropertyType) valueTypeForSignature:(NSString*) signature{
    
    if ([signature hasPrefix:@"Ti"] || [signature hasPrefix:@"TI"] || [signature hasPrefix:@"Ts"] || [signature hasPrefix:@"Tl"] || [signature hasPrefix:@"TL"] || [signature hasPrefix:@"Tq"] || [signature hasPrefix:@"TQ"]) {
        return ORMPropertyType_Integer;
    }
    
    if ([signature hasPrefix:@"Td"] || [signature hasPrefix:@"Tf"]) {
        return ORMPropertyType_Float;
    }
    
    if ([signature hasPrefix:@"T@\"NSString\""]) {
        return ORMPropertyType_String;
    }
    
    if ([signature hasPrefix:@"TB"]) {
        return ORMPropertyType_Boolean;
    }
    
    if ([signature hasPrefix:@"T@\"NSData\""]) {
        return ORMPropertyType_Data;
    }
    
    return ORMPropertyType_Undefined;
}

+ (NSArray<ORMPropertyInfo*>*) sortedArrayByPropertyName:(NSArray<ORMPropertyInfo*>*) sourceArray{
    return [sourceArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *propertName1 = [((ORMPropertyInfo*)obj1) realPropertyName];
        NSString *propertName2 = [((ORMPropertyInfo*)obj2) realPropertyName];
        
        return [propertName1 compare:propertName2];
    }];
}

@end
