//
//  ORMPropertyInfo.m
//  JSPatchDemoProject
//
//  Created by 晋爱元 on 2017/3/23.
//  Copyright © 2017年 jinaiyuan. All rights reserved.
//

#import "ORMPropertyInfo.h"

@interface ORMPropertyInfo()
@property (nonatomic,copy)      NSString            *propertyName;
@property (nonatomic,copy)      NSString            *colName;
@property (nonatomic,assign)    ORMPropertyType     valueType;
@end

@implementation ORMPropertyInfo

-(instancetype) initWithPropertyName:(NSString*) propertyName colName:(NSString*) colName valueType:(ORMPropertyType) valueType{
    self = [super init];
    if (self) {
        _propertyName = propertyName;
        _colName = colName;
        _valueType = valueType;
    }
    
    return self;
}

-(NSString*) transToSQLiteType{
    if (_valueType == ORMPropertyType_Boolean || _valueType == ORMPropertyType_Integer) {
        return @"INTEGER";
    }
    
    if (_valueType == ORMPropertyType_Float) {
        return @"DOUBLE";
    }
    
    if (_valueType == ORMPropertyType_String) {
        return @"TEXT";
    }
    
    if (_valueType == ORMPropertyType_Data) {
        return @"BLOB";
    }
    
    NSAssert(0, @"Undefined Type");
    
    return nil;
}

-(NSString*) realPropertyName{
    return _propertyName;
}

-(NSString*) tableColName{
    return _colName;
}

@end
