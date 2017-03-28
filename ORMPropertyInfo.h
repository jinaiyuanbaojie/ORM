//
//  ORMPropertyInfo.h
//  JSPatchDemoProject
//
//  Created by 晋爱元 on 2017/3/23.
//  Copyright © 2017年 jinaiyuan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ORMPropertyType) {
    ORMPropertyType_Undefined,
    ORMPropertyType_Integer,
    ORMPropertyType_Float,
    ORMPropertyType_String,
    ORMPropertyType_Boolean,
    ORMPropertyType_Data
};

@interface ORMPropertyInfo : NSObject
-(instancetype) initWithPropertyName:(NSString*) propertyName colName:(NSString*) colName valueType:(ORMPropertyType) valueType;
-(NSString*) transToSQLiteType;
-(NSString*) realPropertyName;
-(NSString*) tableColName;
@end
