//
//  ORMObject.h
//  JSPatchDemoProject
//
//  Created by 晋爱元 on 2017/3/22.
//  Copyright © 2017年 jinaiyuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ORMObject : NSObject

#pragma mark - override

//required
+(NSString*) primaryKey;
+(NSString*) tableName;

//optional
+(NSDictionary*) defaultValue;
+(NSDictionary*) colNameMapping;
+(NSArray*) ignoreProperties;

#pragma mark - operation
+(BOOL) createTable;
-(BOOL) addOrUpdate;
-(BOOL) deleteData;
+(NSArray*) queryAll;

#pragma mark - helper
+(NSString*) primaryColName;

@end
