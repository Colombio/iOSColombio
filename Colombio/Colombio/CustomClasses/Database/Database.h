//
//  Database.h
//  
//
//  Created by Matija Kraljić on 01/12/13.
//  Copyright (c) 2013 m2m. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Database : NSObject{
	sqlite3 *db;
}
//@property (nonatomic, readwrite)sqlite3 *db;
@property (readwrite) BOOL isEmptyDB;


-(void)CreateEmptyDB;
-(void)UpgradeDB;

- (id)getColForSQL:(NSString *)sql;
- (id)getColumnForSQL:(NSString *)sql;
- (NSMutableArray *)getAllForSQL:(NSString *)sql;
- (NSMutableDictionary *)getRowForSQL:(NSString *)sql;
- (void)updateSQL:(NSString *)sql forTable:(NSString *)table;
- (void)clearTable:(NSString*)table;

- (int)getCountWhere:(NSString *)where forTable:(NSString *)table;
- (int)getMax:(NSString *)key Where:(NSString *)where forTable:(NSString *)table;
- (int)getSum:(NSString *)key Where:(NSString *)where forTable:(NSString *)table;

-(BOOL)insertDictionaryWithoutColumnCheck:(NSDictionary *)dbData forTable:(NSString *)table;
- (void)checkTableforColumns:(NSDictionary *)dbData forTable:(NSString*)table;
- (BOOL)updateDictionary:(NSDictionary *)dbData forTable:(NSString *)table where:(NSString *)where;

-(void)execute:(NSString*)sql;
@end
