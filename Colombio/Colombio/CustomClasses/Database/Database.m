//
//  Database.m
//  
//
//  Created by Matija Kraljić on 01/12/13.
//  Copyright (c) 2013 m2m. All rights reserved.
//

#import "Database.h"

@implementation Database

- (id) init{
    self = [super init];
    if (self) {
        [self UpgradeDB];
    }
    return self;
}

-(NSString*) GetDatabasePath
{
    return [Database getDatabasePath];
}

+(NSString*) getDatabasePath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) ;
    NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:@"colombio.sqlite"] ;
}

+(NSString*) getDocumentsDirectory
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) ;
    return NSTemporaryDirectory();
    return [paths objectAtIndex:0];
}

-(void)CreateEmptyDB
{
    /*self.isEmptyDB = YES;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"emptyDB"];*/
    
    //USER
    sqlite3_exec(db, "CREATE TABLE USER(user_id TEXT UNIQUE PRIMARY KEY, user_pass TEXT, user_pass_confirm TEXT, user_email TEXT, first_name TEXT, last_name TEXT, phone_number TEXT, anonymous NUMBER, token TEXT, sign TEXT, user_name TEXT, paypal_email TEXT, city TEXT, zip TEXT, balance DECIMAL, ntf_push NUMBER, ntf_in_app NUMBER, ntf_email NUMBER, rating DECIMAL, pending_cashout DECIMAL, paypal NUMBER)", NULL, NULL, NULL);
    sqlite3_exec(db, "CREATE TABLE USER_CASHOUT(user_id TEXT UNIQUE PRIMARY KEY, req_timestamp DATETIME, amount TEXT)", NULL, NULL, NULL);
    //NEWS DEMAND
	sqlite3_exec(db, "CREATE TABLE NEWSDEMANDLIST(req_id NUMBER UNIQUE PRIMARY KEY, title TEXT, cost TEXT, description TEXT, end_timestamp DATETIME, start_timestamp DATETIME, lat NUMERIC, lng NUMERIC, media_id INTEGER, radius NUMBER,  isread INTEGER, status INTEGER, distance NUMERIC, location_type INTEGER)", NULL, NULL, NULL);
    //UPLOAD DATA
    sqlite3_exec(db, "CREATE TABLE UPLOAD_DATA(NEWS_ID INTEGER UNIQUE PRIMARY KEY, NEWS_ID_SERVER INTEGER, NEWSDEMAND_ID INTEGER, TITLE TEXT, DESCRIPTION TEXT, LAT NUMERIC, LNG NUMERIC, MEDIA_ID TEXT, SELECTED_IMGS TEXT, SELECTED_ROWS TEXT, ISNEWSDEMAND INTEGER, IMAGES TEXT, TAGS TEXT, ANONYMOUS INTEGER, CONTACTED INTEGER, CREDITED INTEGER, NEWSVALUE INTEGER, PRICE NUMBER, STATUS INTEGER, UPLOAD_COUNT INTEGER)", NULL, NULL, NULL);
    //MEDIA LIST
    sqlite3_exec(db, "CREATE TABLE MEDIA_LIST(id TEXT UNIQUE PRIMARY KEY, country_id INTEGER, description TEXT, media_icon TEXT, media_type INTEGER, name TEXTZ)", NULL, NULL, NULL);
    sqlite3_exec(db, "CREATE TABLE SELECTED_MEDIA(media_id NUMBER UNIQUE PRIMARY KEY, status INTEGER)", NULL, NULL, NULL);
    //COUNTRIES LIST
    sqlite3_exec(db, "CREATE TABLE COUNTRIES_LIST(c_id NUMBER UNIQUE PRIMARY KEY, lang_id INTEGER, abbr TEXT, c_name TEXT)", NULL, NULL, NULL);
    sqlite3_exec(db, "CREATE TABLE SELECTED_COUNTRIES(c_id NUMBER UNIQUE PRIMARY KEY, status INTEGER)", NULL, NULL, NULL);
    //TIMELINE
    sqlite3_exec(db, "CREATE TABLE TIMELINE(news_id NUMBER UNIQUE PRIMARY KEY, news_title TEXT, news_text TEXT, lat NUMERIC, lng NUMERIC, news_timestamp DATETIME, media_list TEXT, anonymous INTEGER, type_id INTEGER, cost TEXT)", NULL, NULL, NULL);
    sqlite3_exec(db, "CREATE TABLE TIMELINE_IMAGE(news_id NUMBER UNIQUE PRIMARY KEY, large_image TEXT, medium_image TEXT, small_image TEXT, wmarked_image TEXT, wmarked_image_mid TEXT, original TEXT)", NULL, NULL, NULL);
    sqlite3_exec(db, "CREATE TABLE TIMELINE_NOTIFICATIONS(id NUMBER UNIQUE PRIMARY KEY, nid NUMBER, user_id NUMBER, notif_timestamp DATETIME, type_id NUMBER, mid NUMBER, title TEXT, msg TEXT, is_read NUMBER)", NULL, NULL, NULL);
    //INFO TEXTS
    sqlite3_exec(db, "CREATE TABLE INTO_TEXTS(text_id TEXT UNIQUE PRIMARY KEY, content TEXT, lang_id TEXT, title TEXT, edit_timestamp DATETIME)", NULL, NULL, NULL);

    
    
    
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	[defaults setInteger:0 forKey:@"FirstTimeLaunch"];
}

-(void)UpgradeDB
{
    
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    
	sqlite3_stmt *statement = nil ;
    self.isEmptyDB = NO;
	NSString *path = [self GetDatabasePath];
    /*if (![fileManager fileExistsAtPath:path isDirectory:NO] || [[[NSUserDefaults standardUserDefaults] objectForKey:@"emptyDB"] boolValue]){
        NSError *error;
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"brazuka" ofType:@"sqlite"];
        if ([fileManager fileExistsAtPath:path isDirectory:NO] ) {
            [fileManager removeItemAtPath:path error:&error];
        }
        [fileManager copyItemAtPath:resourcePath toPath:path error:&error];
    }*/
	int dbVersion = 0;
	if (sqlite3_open([path UTF8String],&db) == SQLITE_OK)
		if ((sqlite3_prepare_v2(db, [@"PRAGMA user_version" UTF8String], -1, &statement, NULL)) == SQLITE_OK)
			while(sqlite3_step(statement) == SQLITE_ROW)
				dbVersion = sqlite3_column_int(statement, 0);
	sqlite3_finalize(statement);
	
	switch (dbVersion)
	{
		case 0:
			[self CreateEmptyDB];
        default:
            break;
    }
	sqlite3_exec(db, "PRAGMA user_version=1", NULL, NULL, NULL);
	//sqlite3_close(db);
    
}

#pragma mark - query functions

- (sqlite3_stmt *)prepare:(NSString *)sql
{
	if (sql==nil)
		return 0;
    NSString *tSQL = sql;
	const char *utfsql = [tSQL UTF8String];
	sqlite3_stmt *statement;
    
	if (sqlite3_prepare_v2(db,utfsql,-1,&statement,NULL) == SQLITE_OK) {
		return statement;
	} else {
		NSLog(@"STATEMENT:%@ \nError while creating add statement.'%s'", sql,sqlite3_errmsg(db));
		return 0;
	}
}

- (id)getColumnForSQL:(NSString *)sql {
	
	sqlite3_stmt *statement;
	NSMutableArray *thisArray = [NSMutableArray array];
	id result = nil;
	if ((statement = [self prepare:sql])) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			
			if (sqlite3_column_type(statement, 0) == SQLITE_TEXT) {
				result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,0)];
			} else if (sqlite3_column_type(statement,0) == SQLITE_INTEGER) {
				result = [NSNumber numberWithInt:(int)sqlite3_column_int(statement,0)];
			} else if (sqlite3_column_type(statement,0) == SQLITE_FLOAT) {
				result = [NSNumber numberWithDouble:(double)sqlite3_column_double(statement,0)];
			} else {
				result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,0)];
			}
			[thisArray addObject:result];
		}
	}
	sqlite3_finalize(statement);
	return thisArray;
}

- (NSMutableArray *)getAllForSQL:(NSString *)sql
{
	sqlite3_stmt *statement;
	id result;
	NSMutableArray *thisArray = [NSMutableArray array];
	statement = [self prepare:sql];
	if (statement) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			NSMutableDictionary *thisDict = [NSMutableDictionary dictionaryWithCapacity:4];
			for (int i = 0 ; i < sqlite3_column_count(statement) ; i++) {
				if (sqlite3_column_decltype(statement,i) != NULL &&
					strcasecmp(sqlite3_column_decltype(statement,i),"Boolean") == 0) {
					result = [NSNumber numberWithBool:(BOOL)sqlite3_column_int(statement,i)];
				} else if (sqlite3_column_type(statement, i) == SQLITE_TEXT) {
					result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,i)] ;
				} else if (sqlite3_column_type(statement,i) == SQLITE_INTEGER) {
					result = [NSNumber numberWithInt:(int)sqlite3_column_int(statement,i)];
				} else if (sqlite3_column_type(statement,i) == SQLITE_FLOAT) {
					result = [NSNumber numberWithFloat:(float)sqlite3_column_double(statement,i)];
				} else {
					const unsigned char *tempresult = sqlite3_column_text(statement, i);
					if(tempresult==NULL)
						result=@"";
					else
						result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,i)];
				}
				if (result) {
					[thisDict setObject:result
								 forKey:[NSString stringWithUTF8String:sqlite3_column_name(statement,i)]];
				}
			}
			[thisArray addObject:thisDict];
		}
	}
	sqlite3_finalize(statement);
    return thisArray;
}

- (NSMutableDictionary *)getRowForSQL:(NSString *)sql {
	sqlite3_stmt *statement;
	id result;
	NSMutableDictionary *thisDict = [NSMutableDictionary dictionaryWithCapacity:4];
	statement = [self prepare:sql];
	if (statement) {
		if (sqlite3_step(statement) == SQLITE_ROW) {
			for (int i = 0 ; i < sqlite3_column_count(statement) ; i++) {
				if (sqlite3_column_type(statement, i) == SQLITE_TEXT) {
					result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,i)];
				} else if (sqlite3_column_type(statement,i) == SQLITE_INTEGER) {
					result = [NSNumber numberWithInt:(int)sqlite3_column_int(statement,i)];
				} else if (sqlite3_column_type(statement,i) == SQLITE_FLOAT) {
					result = [NSNumber numberWithFloat:(float)sqlite3_column_double(statement,i)];
				} else {
					const unsigned char *tempresult = sqlite3_column_text(statement, i);
					if(tempresult==NULL)
						result=@"";
					else
						result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,i)];
				}
				if (result) {
					[thisDict setObject:result
								 forKey:[NSString stringWithUTF8String:sqlite3_column_name(statement,i)]];
				}
			}
		}
	}
	sqlite3_finalize(statement);
	return thisDict;
}

- (id)getColForSQL:(NSString *)sql {
	
	sqlite3_stmt *statement;
	id result = nil;
	if ((statement = [self prepare:sql])) {
		if (sqlite3_step(statement) == SQLITE_ROW) {
			
			if (sqlite3_column_type(statement, 0) == SQLITE_TEXT) {
				result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,0)];
			} else if (sqlite3_column_type(statement,0) == SQLITE_INTEGER) {
				result = [NSNumber numberWithInt:(int)sqlite3_column_int(statement,0)];
			} else if (sqlite3_column_type(statement,0) == SQLITE_FLOAT) {
				result = [NSNumber numberWithDouble:(double)sqlite3_column_double(statement,0)];
			} else {
				result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,0)];
			}
		}
	}
	sqlite3_finalize(statement);
	return result;
}

- (int)getCountWhere:(NSString *)where forTable:(NSString *)table {
    
	int tableCount = 0;
	NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE %@",
					 table,where];
	sqlite3_stmt *statement;
    
	if ((statement = [self prepare:sql])) {
		if (sqlite3_step(statement) == SQLITE_ROW) {
			tableCount = sqlite3_column_int(statement,0);
		}
	}
	sqlite3_finalize(statement);
	return tableCount;
    
}

- (int)getMax:(NSString *)key Where:(NSString *)where forTable:(NSString *)table {
	
	int tableMax = 0;
	NSString *sql = [NSString stringWithFormat:@"SELECT MAX(%@) FROM %@ WHERE %@",
					 key,table,where];
	sqlite3_stmt *statement;
	if ((statement = [self prepare:sql])) {
		if (sqlite3_step(statement) == SQLITE_ROW) {
			tableMax = sqlite3_column_int(statement,0);
		}
	}
	sqlite3_finalize(statement);
	return tableMax;
	
}

- (int)getSum:(NSString *)key Where:(NSString *)where forTable:(NSString *)table {
	
	int tableSum = 0;
	NSString *sql = [NSString stringWithFormat:@"SELECT SUM(%@) FROM %@ WHERE %@",
					 key,table,where];
	sqlite3_stmt *statement;
	if ((statement = [self prepare:sql])) {
		if (sqlite3_step(statement) == SQLITE_ROW) {
			tableSum = sqlite3_column_int(statement,0);
		}
	}
	sqlite3_finalize(statement);
	return tableSum;
	
}

- (void)insertArray:(NSArray *)dbData forTable:(NSString *)table {
    
	sqlite3_exec(db, "BEGIN", 0, 0, 0);
	
	NSMutableString *sql = [NSMutableString stringWithCapacity:16];
	[sql appendFormat:@"INSERT INTO %@ (",table];
	
	for (int i = 0 ; i < [dbData count] ; i++) {
		[sql appendFormat:@"%@",[[dbData objectAtIndex:i] objectForKey:@"key"]];
		if (i + 1 < [dbData count]) {
			[sql appendFormat:@", "];
		}
	}
	[sql appendFormat:@") VALUES("];
	for (int i = 0 ; i < [dbData count] ; i++) {
		if ([[[dbData objectAtIndex:i] objectForKey:@"value"] intValue]) {
			[sql appendFormat:@"%d",[[[dbData objectAtIndex:i] objectForKey:@"value"] intValue]];
		} else {
			[sql appendFormat:@"'%@'",[[dbData objectAtIndex:i] objectForKey:@"value"]];
		}
		if (i + 1 < [dbData count]) {
			[sql appendFormat:@", "];
		}
	}
	[sql appendFormat:@")"];
	[self runDynamicSQL:sql forTable:table];
	
	sqlite3_exec(db, "COMMIT", 0, 0, 0);
}

-(BOOL)insertDictionary:(NSDictionary *)dbData forTable:(NSString *)table {
    
    if ([[self getRowForSQL:[NSString stringWithFormat:@"SELECT * FROM %@ LIMIT 1",table]]count]<[dbData count]) {
        [self checkTableforColumns:dbData forTable:table];
    }
    
	return [self insertDictionaryWithoutColumnCheck:dbData forTable:table];
}


-(BOOL)insertDictionaryWithoutColumnCheck:(NSDictionary *)dbData forTable:(NSString *)table {
    NSString *tPKname = [self returnPKforTableNamed:table];
    for (NSString *tStr in [dbData allKeys]) {
        if ([[tPKname lowercaseString] isEqualToString:[tStr lowercaseString]]) {
            tPKname = tStr;
            break;
        }
    }
    NSString *tPKval = [dbData objectForKey:tPKname];
    int checkCNT = [self getCountWhere:[NSString stringWithFormat:@"%@ = '%@'", tPKname, tPKval] forTable:table];
    if (checkCNT == 0){
        
        NSMutableString *sql = [NSMutableString stringWithCapacity:16];
        [sql appendFormat:@"INSERT INTO %@ (",table];
        
        NSArray *dataKeys = [dbData allKeys];
        for (int i = 0 ; i < [dataKeys count] ; i++)
        {
            [sql appendFormat:@"%@",[dataKeys objectAtIndex:i]];
            if (i + 1 < [dbData count])
            {
                [sql appendFormat:@", "];
            }
        }
        
        [sql appendFormat:@") VALUES("];
        for (int i = 0 ; i < [dataKeys count] ; i++)
        {
            if([[dbData objectForKey:[dataKeys objectAtIndex:i]] isKindOfClass:[NSString class]]){ // TODO dodati u komunikaciju
                [sql appendFormat:@"'%@'",[[[dbData objectForKey:[dataKeys objectAtIndex:i]] stringByReplacingOccurrencesOfString:@"'" withString:@"''"] stringByReplacingOccurrencesOfString:@"%" withString:@"%25"]];
            }
            else
            {
                NSString *col_name=[[NSString stringWithFormat:@"%@", [dataKeys objectAtIndex:i]] uppercaseString];
#pragma mark - Percent to integer
                // postotak kao decimalni broj u cijeli!
                if ([col_name isEqualToString:@"DAYCODE_WEIGHT"] || [col_name isEqualToString:@"VISIT_PERC"])
                {
                    float value = [[dbData objectForKey:[dataKeys objectAtIndex:i]] floatValue];
                    if (value<=1)
                        value=truncf(value*100);
                    [sql appendFormat:@"'%f'", value];
                }
                else
                    [sql appendFormat:@"'%@'",[dbData objectForKey:[dataKeys objectAtIndex:i]]];
            }
            if (i + 1 < [dbData count])
            {
                [sql appendFormat:@", "];
            }
        }
        [sql appendFormat:@")"];
        sql=(NSMutableString*)[sql stringByReplacingOccurrencesOfString:@"<null>" withString:@""];
        return [self runDynamicSQL:sql forTable:table];
	}else{
        return [self updateDictionary:dbData forTable:table where:[NSString stringWithFormat:@"%@ = '%@'", tPKname, tPKval]];
    }
    return YES;
}

- (void)updateArray:(NSArray *)dbData forTable:(NSString *)table {
	[self updateArray:dbData forTable:table where:NULL];
}

- (void)updateArray:(NSArray *)dbData forTable:(NSString *)table where:(NSString *)where {
	
	sqlite3_exec(db, "BEGIN", 0, 0, 0);
	
	NSMutableString *sql = [NSMutableString stringWithCapacity:16];
	[sql appendFormat:@"UPDATE %@ SET ",table];
	
	for (int i = 0 ; i < [dbData count] ; i++) {
		if ([[[dbData objectAtIndex:i] objectForKey:@"value"] intValue]) {
			[sql appendFormat:@"%@=%@",
			 [[dbData objectAtIndex:i] objectForKey:@"key"],
			 [[dbData objectAtIndex:i] objectForKey:@"value"]];
		} else {
			[sql appendFormat:@"%@='%@'",
			 [[dbData objectAtIndex:i] objectForKey:@"key"],
			 [[dbData objectAtIndex:i] objectForKey:@"value"]];
		}
		if (i + 1 < [dbData count]) {
			[sql appendFormat:@", "];
		}
	}
	if (where != NULL) {
		[sql appendFormat:@" WHERE %@",where];
	} else {
		[sql appendFormat:@" WHERE 1"];
	}
	[self runDynamicSQL:sql forTable:table];
	
	sqlite3_exec(db, "COMMIT", 0, 0, 0);
}

- (BOOL)updateDictionary:(NSDictionary *)dbData forTable:(NSString *)table {
	return [self updateDictionary:dbData forTable:table where:NULL];
}

- (BOOL)updateDictionary:(NSDictionary *)dbData forTable:(NSString *)table where:(NSString *)where {
	
    //	if(sqlite3_exec(dbh, "BEGIN", 0, 0, 0)!=SQLITE_OK) return false;
    sqlite3_exec(db, "BEGIN", 0, 0, 0);
	NSMutableString *sql = [NSMutableString stringWithCapacity:16];
	[sql appendFormat:@"UPDATE %@ SET ",table];
    [self checkDBforTable:table];
    [self checkTableforColumns:dbData forTable:table];
    
	NSArray *dataKeys = [dbData allKeys];
	for (int i = 0 ; i < [dataKeys count] ; i++) { // TODO Dodati u komunikaciju
        {
            NSString *tStr;
            BOOL isString = NO;
            if ([dbData objectForKey:[dataKeys objectAtIndex:i]])
            {
                if ([[dbData objectForKey:[dataKeys objectAtIndex:i]] isKindOfClass:[NSString class]])
                {
                    tStr = [dbData objectForKey:[dataKeys objectAtIndex:i]];
                    tStr = [tStr stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                    tStr = [tStr stringByReplacingOccurrencesOfString:@"%" withString:@"%25"];
                    isString = YES;
                }
            }
            if (isString) {
                [sql appendFormat:@"%@='%@'", [dataKeys objectAtIndex:i], tStr];
            } else {
                [sql appendFormat:@"%@='%@'", [dataKeys objectAtIndex:i], [dbData objectForKey:[dataKeys objectAtIndex:i]]];
            }
			
		}		// end TODO Dodati u komunikaciju
		if (i + 1 < [dbData count]) {
			[sql appendFormat:@", "];
		}
	}
	if (where != NULL) {
		[sql appendFormat:@" WHERE %@",where];
	}
	sql=(NSMutableString*)[sql stringByReplacingOccurrencesOfString:@"<null>" withString:@""];
	sql=(NSMutableString*)[sql stringByReplacingOccurrencesOfString:@"\\u0027" withString:@"''"];
	if(![self runDynamicSQL:sql forTable:table])
        return false;
	if(sqlite3_exec(db, "COMMIT", 0, 0, 0)!=SQLITE_OK)
        return false;
    
    return true;
}

- (void)updateSQL:(NSString *)sql forTable:(NSString *)table {
	[self runDynamicSQL:sql forTable:table];
}

- (void)deleteWhere:(NSString *)where forTable:(NSString *)table {
    
	NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@",
					 table,where];
	[self runDynamicSQL:sql forTable:table];
}

- (void)clearTable:(NSString*)table{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@",
                     table];
    [self runDynamicSQL:sql forTable:table];
}

// INSERT/UPDATE/DELETE Subroutines

- (BOOL)runDynamicSQL:(NSString *)sql forTable:(NSString *)table {
    
	int result = 0;
	//NSAssert1(self.dynamic == 1,@"Tried to use a dynamic function on a static database",NULL);
    sql = [sql stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	sqlite3_stmt *statement = [self prepare:sql];
	if (statement != 0) {
		result = sqlite3_step(statement);
    }
	sqlite3_finalize(statement);
	if (result) {
		return YES;
	} else {
		return NO;
	}
}

-(NSString*)encodedString:(const unsigned char *)ch{
	NSString *retStr;
	if(ch == nil)
		retStr = @"";
	else
		retStr = [NSString stringWithCString:(char*)ch encoding:NSUTF8StringEncoding];
	return retStr;
}
-(NSMutableDictionary*)getAllValuesFor:(NSString*)str
{
	sqlite3_stmt *statement = [self prepare:str];
	NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithCapacity:0];
	if (statement)
	{
		while (sqlite3_step(statement) == SQLITE_ROW)
		{
			NSString *strData = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            //result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,i)];
			NSString *strKey = [NSString stringWithFormat:@"%s",sqlite3_column_text(statement, 1)];
			[dict setObject:strData forKey:strKey];
		}
	}
	sqlite3_finalize(statement);
	
	return dict;
}

-(NSString*)getRowCountforTable:(NSString*)tablename
{
	sqlite3_stmt *statement;
	NSString *sql=[NSString stringWithFormat:@"select count(*) from %@",tablename];
	int count = 0;
	if ((statement = [self prepare:sql]))
	{
		while (sqlite3_step(statement) == SQLITE_ROW)
		{
			count = sqlite3_column_int(statement, 0);
		}
	}
	sqlite3_finalize(statement);
	return [NSString stringWithFormat:@"%d",count];
}

- (void)close {
	if (db) {
		sqlite3_close(db);
	}
}
-(void)execute:(NSString*)sql
{
	sqlite3_stmt *statement;
    int count;
	if ((statement = [self prepare:sql]))
	{
		while (sqlite3_step(statement) == SQLITE_ROW)
		{
			count = sqlite3_column_int(statement, 0);
		}
	}
}

- (void)checkDBforTable:(NSString*)table{
    int tblExists = [self getCountWhere:[NSString stringWithFormat:@"tbl_name = '%@'",table] forTable:@"sqlite_master"];
    if (tblExists==0) {
        NSMutableString *sql = [NSMutableString stringWithFormat:@"CREATE TABLE %@ (inactive NUMERIC)", [table lowercaseString]];
        [self execute:sql];
    }
}

- (void)checkTableforColumns:(NSDictionary *)dbData forTable:(NSString*)table{
    NSMutableArray *tArr = [self getAllForSQL:[NSString stringWithFormat:@"PRAGMA TABLE_INFO(%@)",table]];
    
    for (NSString *colName in [dbData allKeys]){
        BOOL existingCol = FALSE;
        for (NSDictionary *tDict in tArr) {
            if ([[[tDict valueForKey:@"name"] lowercaseString] isEqualToString:[colName lowercaseString]]) {
                existingCol = YES;
            }
        }
        if (!existingCol) {
            NSString *valueType = [NSString stringWithFormat:@""];
            if ([[dbData valueForKey:colName] isKindOfClass:[NSNumber class]]||([[dbData valueForKey:colName]isEqual:@""])) {
                valueType = @"NUMERIC";
            }else
                valueType =@"TEXT";
            NSMutableString *sql = [NSMutableString stringWithFormat:@"ALTER TABLE %@ ADD %@ %@", [table lowercaseString],[colName lowercaseString],valueType];
            [self execute:sql];
        }
    }
    
}

- (NSString*)returnPKforTableNamed:(NSString*)str{
    NSString *tSQL = [NSString stringWithFormat:@"PRAGMA table_info(%@)",str];
    NSArray *tArr = [self getAllForSQL:tSQL];
    NSString *retStr = @"";
    for (NSDictionary *tDict in tArr) {
        if ([[tDict objectForKey:@"pk"] integerValue] == 1) {
            retStr = [tDict objectForKey:@"name"];
            break;
        }
    }
    return retStr;
}

@end
