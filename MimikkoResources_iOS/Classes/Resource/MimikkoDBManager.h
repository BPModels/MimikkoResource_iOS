//
//  MimikkoDBManager.h
//  SwiftTestDemo
//
//  Created by 沙庭宇 on 2022/6/23.
//

#import <Foundation/Foundation.h>
@class MimikkoPackageModel;
@class MimikkoStageFileModel;

NS_ASSUME_NONNULL_BEGIN

@interface MimikkoDBManager : NSObject

/// 更新数据库中的包信息
- (void)updatePackageData:(MimikkoPackageModel *)packageModel;

/// 更新数据库中的角色文件信息
- (void)updateStageFilesData:(NSArray<MimikkoStageFileModel *> *)fileModelList withPackage: (NSString *)code;

/// 查询包信息
- ( MimikkoPackageModel * _Nullable )selectPackageData: (NSString *)code;

/// 查询角色文件信息
- (NSArray<MimikkoStageFileModel *> *)selectStageFileData: (NSString *)package;
@end

NS_ASSUME_NONNULL_END
