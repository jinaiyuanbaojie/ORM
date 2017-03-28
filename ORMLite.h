//
//  ORMLite.h
//  JSPatchDemoProject
//
//  Created by 晋爱元 on 2017/3/22.
//  Copyright © 2017年 jinaiyuan. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * CoreData Realm
 */
@class ORMObject;
@interface ORMLite : NSObject
+(BOOL) createTableForClass:(Class) klass;
+(BOOL) addOrUpdate:(ORMObject*) data;
+(BOOL) deleteData:(ORMObject*) data;
+(NSArray*) queryAll:(Class) klass;
@end
