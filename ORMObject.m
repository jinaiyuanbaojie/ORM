//
//  ORMObject.m
//  JSPatchDemoProject
//
//  Created by 晋爱元 on 2017/3/22.
//  Copyright © 2017年 jinaiyuan. All rights reserved.
//

#import "ORMObject.h"
#import "ORMLite.h"

@implementation ORMObject

+(NSString*) primaryKey{
    return nil;
}

+(NSString*) primaryColName{
    NSString *primaryKey = [self primaryKey];
    NSDictionary *mapping = [self colNameMapping];
    return mapping[primaryKey] ? mapping[primaryKey]:primaryKey;
}

+(NSString*) tableName{
    return nil;
}

+(NSDictionary*) defaultValue{
    return nil;
}

+(NSDictionary*) colNameMapping{
    return nil;
}

+(NSArray*) ignoreProperties{
    return nil;
}


#pragma mark - operation
+(BOOL) createTable{
   return [ORMLite createTableForClass:self];
}

-(BOOL) addOrUpdate{
    return [ORMLite addOrUpdate:self];
}

-(BOOL) deleteData{
    return [ORMLite deleteData:self];
}

+(NSArray*) queryAll{
    return [ORMLite queryAll:self];
}
@end
