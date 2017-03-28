//
//  ORMLite.m
//  JSPatchDemoProject
//
//  Created by 晋爱元 on 2017/3/22.
//  Copyright © 2017年 jinaiyuan. All rights reserved.
//

#import "ORMLite.h"
#import "ORMObject.h"
#import "ORMPropertyInfo.h"
#import "OMRSQLiteHelper.h"
#import "ORMPropertyCache.h"

@implementation ORMLite

+ (BOOL) deleteData:(ORMObject*) data{
    NSString *name = [data.class primaryColName];
    NSString *primaryKey = [data.class primaryKey];
    NSString *tableName = [data.class tableName];

    @synchronized (data.class) {
        NSString * sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@=?",tableName,name];
        id value = [data valueForKey:primaryKey];
        return [[OMRSQLiteHelper sharedInstance] executeUpdate:sql withArgumentsInArray:@[value]];
    }
}

+ (NSArray*) queryAll:(Class) klass{
    NSAssert([klass isSubclassOfClass:ORMObject.class], @"ORM Class must be a subClass of ORMObject..");
    NSString *tableName = [klass tableName];
    
    @synchronized (klass) {
        NSString * sql = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
        FMResultSet *set = [[OMRSQLiteHelper sharedInstance] executeQuery:sql];
        
        NSArray<ORMPropertyInfo*> *array = [ORMPropertyCache propertyInfoOfClass:klass];
        NSMutableArray *ret = [NSMutableArray new];
        
        while ([set next]) {
            ORMObject *ormObj = [[klass alloc] init];
            
            [array enumerateObjectsUsingBlock:^(ORMPropertyInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *colName = [obj tableColName];
                NSString *propertyName = [obj realPropertyName];
                
                id value = [set objectForColumnName:colName];
                if ([value isKindOfClass:NSNull.class]) {
                    value = nil;
                }
                
                [ormObj setValue:value forKey:propertyName];
            }];
            
            [ret addObject:ormObj];
        }
        
        return ret;
    }
}

+ (BOOL) createTableForClass:(Class) klass{
    NSAssert([klass isSubclassOfClass:ORMObject.class], @"ORM Class must be a subClass of ORMObject..");
    NSString *tableName = [klass tableName];
    NSAssert(tableName, @"table must be non-nil");

    @synchronized (klass) {
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@)",tableName,[self createTableSqlForClass:klass]];
        return [[OMRSQLiteHelper sharedInstance] executeStatements:sql];
    }
}

+ (NSString*) createTableSqlForClass:(Class) klass{
    NSString *primaryKey = [klass primaryKey];
    NSMutableString *ret = [[NSMutableString alloc] init];
    
    NSArray<ORMPropertyInfo*> *array = [ORMPropertyCache propertyInfoOfClass:klass];
    [array enumerateObjectsUsingBlock:^(ORMPropertyInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *propertyName = [obj realPropertyName];
        
        [ret appendString:[obj tableColName]];
        [ret appendString:@" "];
        [ret appendString:[obj transToSQLiteType]];
        
        if ([primaryKey isEqualToString:propertyName]) {
            [ret appendString:@" "];
            [ret appendString:@"PRIMARY KEY"];
        }
        
        if (idx < (array.count-1)) {
            [ret appendString:@","];
        }
        
    }];
    
    return ret.copy;
}

+ (BOOL) addOrUpdate:(ORMObject*) data{
    NSString *tableName = [data.class tableName];
    
    @synchronized (data.class) {
        NSString * sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (%@) VALUES (%@)",tableName,[self updateSqlForClass:data.class],[self updateStubSqlForClass:data.class]];

        return [[OMRSQLiteHelper sharedInstance] executeUpdate:sql withArgumentsInArray:[self argumentArrayWithData:data]];
    }
}

+ (NSString*) updateSqlForClass:(Class) klass{
    static NSMutableDictionary<NSString*,NSString*> *updateCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        updateCache = [[NSMutableDictionary alloc] init];
    });
    
    NSString *key = NSStringFromClass(klass);
    if (updateCache[key]) {
        return updateCache[key];
    }
    
    NSArray<ORMPropertyInfo*> *array = [ORMPropertyCache propertyInfoOfClass:klass];
    NSMutableString *ret = [[NSMutableString alloc] init];
    [array enumerateObjectsUsingBlock:^(ORMPropertyInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [ret appendString:[obj tableColName]];
        
        if (idx < (array.count-1)) {
            [ret appendString:@","];
        }
    }];
    
    updateCache[key] = ret.copy;
    return ret.copy;
}

+ (NSString*) updateStubSqlForClass:(Class) klass{
    static NSMutableDictionary<NSString*,NSString*> *stubCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stubCache = [[NSMutableDictionary alloc] init];
    });
    
    NSString *key = NSStringFromClass(klass);
    if (stubCache[key]) {
        return stubCache[key];
    }
    
    NSArray<ORMPropertyInfo*> *array = [ORMPropertyCache propertyInfoOfClass:klass];
    NSMutableString *ret = [[NSMutableString alloc] init];
    [array enumerateObjectsUsingBlock:^(ORMPropertyInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [ret appendString:@"?"];
        
        if (idx < (array.count-1)) {
            [ret appendString:@","];
        }
    }];
    
    stubCache[key] = ret.copy;
    return ret.copy;
}

+ (NSArray*) argumentArrayWithData:(ORMObject*) data{
    NSArray<ORMPropertyInfo*> *array = [ORMPropertyCache propertyInfoOfClass:data.class];

    NSMutableArray *ret = [[NSMutableArray alloc] init];
    [array enumerateObjectsUsingBlock:^(ORMPropertyInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *propertyName = [obj realPropertyName];
        
        id value = [data valueForKey:propertyName];
        
        if (!value) {
            NSDictionary *defaultValueDic = [data.class defaultValue];
            value = defaultValueDic[propertyName];
        }
        
        if (!value) {
            value = [NSNull null];
        }
        
        [ret addObject:value];
    }];
    
    return ret.copy;
}

@end
