//
//  MimikkoDBManager.m
//  SwiftTestDemo
//
//  Created by 沙庭宇 on 2022/6/23.
//

#import "MimikkoDBManager.h"
#import <MimikkoResources_iOS/MimikkoResources_iOS-Swift.h>
#import <sqlite3.h>

@implementation MimikkoDBManager {
    sqlite3 *_db;
}

/// 更新数据库中的包信息
- (void)updatePackageData:(MimikkoPackageModel *)packageModel {
    [self openSqlDataBase];
    [self deletePackageData:packageModel.code];
    [self insertPackageData:packageModel];
    [self closedDB];
}

/// 查询包信息
- (MimikkoPackageModel * _Nullable)selectPackageData: (NSString *)code {
    [self openSqlDataBase];
    MimikkoPackageModel * packageModel = [self queryPackageModel:code];
    [self closedDB];
    return packageModel;
}


/// 更新数据库中的角色文件信息
- (void)updateStageFilesData:(NSArray<MimikkoStageFileModel *> *)fileModelList withPackage: (NSString *)code {
    [self openSqlDataBase];
    [self deleteStageFileData:code];
    [self insertStageFileData:fileModelList];
    [self closedDB];
}

/// 查询角色文件信息
- (NSArray<MimikkoStageFileModel *> *)selectStageFileData: (NSString *)package {
    [self openSqlDataBase];
    NSArray<MimikkoStageFileModel *> * fileModelList = [self queryStageFileModel:package];
    [self closedDB];
    return fileModelList;
}



// 打开数据库
- (void)openSqlDataBase {
    if (_db != NULL) { return; }
    NSString *docPath  = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [docPath stringByAppendingPathComponent:@"package.sqlite"];
    const char *cFileName = fileName.UTF8String;
    
    int result = sqlite3_open(cFileName, &_db);
    
    if (result != SQLITE_OK) {
        NSLog(@")打开数据库失败");
    }
    [self createPackageTable];
    [self createEntityTable];
}

- (void)closedDB {
    if (_db != NULL) {
        sqlite3_close_v2(_db);
        _db = NULL;
    }
}

- (void)createPackageTable {
    const char *sql = "CREATE TABLE IF NOT EXISTS t_package (id integer PRIMARY KEY AUTOINCREMENT,code text NOT NULL,room text NOT NULL,meta text NOT NULL,hash text NOT NULL,version integer NOT NULL);";
    char *errMsg = NULL;
    
    int result = sqlite3_exec(_db, sql, NULL, NULL, &errMsg);
    if (result != SQLITE_OK) {
        NSLog(@"创建表失败");
        printf("创表失败---%s----%s---%d",errMsg,__FILE__,__LINE__);
    }
}

- (void)createEntityTable {
    const char *sql = "CREATE TABLE IF NOT EXISTS t_entity (id integer PRIMARY KEY AUTOINCREMENT,package text NOT NULL,path text NOT NULL,encryption integer NOT NULL);";
    char *errMsg = NULL;
    
    int result = sqlite3_exec(_db, sql, NULL, NULL, &errMsg);
    if (result != SQLITE_OK) {
        NSLog(@"创建文件实体表失败");
        printf("创表失败---%s----%s---%d",errMsg,__FILE__,__LINE__);
    }
}

// 插入包数据
- (void)insertPackageData: (MimikkoPackageModel *)model {
    NSString *code    = model.code;
    NSString *room    = model.room;
    NSString *meta    = model.meta;
    NSString *hash    = model.stageHash;
    NSInteger version = model.version;
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO t_package (code,room,meta,hash,version) VALUES ('%@','%@','%@','%@',%ld);",code, room, meta, hash, (long)version];
    
    char *errMsg = NULL;
    int result = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &errMsg);
    
    if (result != SQLITE_OK) {
        NSLog(@"插入包数据失败 - %s",errMsg);
    }
}

// 插入角色文件数据
- (void)insertStageFileData: (NSArray<MimikkoStageFileModel *> *)modelList {
    
    NSString *sql = @"INSERT INTO t_entity (package,path,encryption) VALUES (?,?,?);";
    sqlite3_stmt * _stmt;
    sqlite3_prepare_v2(_db, sql.UTF8String, (int)strlen(sql.UTF8String), &_stmt, NULL);
    
    for (MimikkoStageFileModel * model in modelList) {
        NSString *package    = model.package;
        NSString *path       = model.path;
        NSInteger encryption = model.encryption;
        int index = 1;
        sqlite3_bind_text(_stmt, index++, package.UTF8String, (int)strlen(package.UTF8String), NULL);
        sqlite3_bind_text(_stmt, index++, path.UTF8String, (int)strlen(path.UTF8String), NULL);
        sqlite3_bind_int(_stmt, index++, (int)encryption);
        
        sqlite3_step(_stmt);
        sqlite3_reset(_stmt);
    }
    
    int result = sqlite3_finalize(_stmt);

    if (result != SQLITE_OK) {
        NSLog(@"插入角色文件数据失败");
    }
}

// 插入文件实体数据
- (void)insertEntityData: (MimikkoStageFileModel *)entityModel {
    for (int i = 0; i < 20; i++) {
        NSString *package    = entityModel.package;
        NSString *path       = entityModel.path;
        NSInteger encryption = entityModel.encryption;
        
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO t_package (package,path,encryption) VALUES ('%@','%@',%ld);",package, path, (long)encryption];
        
        char *errMsg = NULL;
        int result   = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &errMsg);
        
        if (result != SQLITE_OK) {
            NSLog(@"插入文件实体数据失败 - %s",errMsg);
        }
    }
}

// 删除包数据
- (void)deletePackageData: (NSString *)code {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM t_package WHERE code='%@'",code];
    
    char *errMsg = NULL;
    int result = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &errMsg);
    
    if (result != SQLITE_OK) {
        NSLog(@"删除包数据失败 - %s",errMsg);
    }
}

// 删除包数据
- (void)deleteStageFileData: (NSString *)package {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM t_entity WHERE package='%@';",package];
    
    char *errMsg = NULL;
    int result = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &errMsg);
    
    if (result != SQLITE_OK) {
        NSLog(@"删除角色文件数据失败 - %s",errMsg);
    }
}

- (MimikkoPackageModel *)queryPackageModel:(NSString *)code {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM t_package WHERE code='%@';", code];
    sqlite3_stmt *stmt = NULL;
    MimikkoPackageModel *packageModel;
    
    if (sqlite3_prepare_v2(_db, sql.UTF8String, (int)strlen(sql.UTF8String), &stmt, NULL) == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
//            int ID           = sqlite3_column_int(stmt, 0);
            const char *code = (const char*)sqlite3_column_text(stmt, 1);
            const char *room = (const char*)sqlite3_column_text(stmt, 2);
            const char *meta = (const char*)sqlite3_column_text(stmt, 3);
            const char *hash = (const char*)sqlite3_column_text(stmt, 4);
            int version      = sqlite3_column_int(stmt, 5);
//            printf("%d %s %s %s %s %d\n",ID,code,room, meta, hash, version);
            packageModel = [[MimikkoPackageModel alloc] init];
            packageModel.code       = [NSString stringWithUTF8String:code];
            packageModel.room       = [NSString stringWithUTF8String:room];
            packageModel.meta       = [NSString stringWithUTF8String:meta];
            packageModel.stageHash  = [NSString stringWithUTF8String:hash];
            packageModel.version    = version;
        }
    } else {
        NSLog(@"查询语句有问题");
    }
    return packageModel;
}

- (NSArray<MimikkoStageFileModel *> *)queryStageFileModel:(NSString *)package {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM t_entity WHERE package='%@';", package];
    sqlite3_stmt *stmt = NULL;
    NSMutableArray<MimikkoStageFileModel *> *fileModelList = [NSMutableArray new];
    if (sqlite3_prepare_v2(_db, sql.UTF8String, (int)strlen(sql.UTF8String), &stmt, NULL) == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
//            int ID              = sqlite3_column_int(stmt, 0);
            const char *package = (const char*)sqlite3_column_text(stmt, 1);
            const char *path    = (const char*)sqlite3_column_text(stmt, 2);
            int encryption      = sqlite3_column_int(stmt, 5);
//            printf("%d %s %s %d\n",ID, package, path, encryption);
            MimikkoStageFileModel *fileModel = [[MimikkoStageFileModel alloc] init];
            fileModel.package       = [NSString stringWithUTF8String:package];
            fileModel.path          = [NSString stringWithUTF8String:path];
            fileModel.encryption    = encryption;
            [fileModelList addObject:fileModel];
        }
    } else {
        NSLog(@"查询语句有问题");
    }
    return fileModelList.copy;
}

@end
