//
//  ORMPropertyCache.h
//  JSPatchDemoProject
//
//  Created by 晋爱元 on 2017/3/23.
//  Copyright © 2017年 jinaiyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ORMPropertyInfo;
@interface ORMPropertyCache : NSObject
+(NSArray<ORMPropertyInfo*>*) propertyInfoOfClass:(Class) klass;
@end
