//
//  MimikkoPackageHelper.swift
//  DKImagePickerController
//
//  Created by 沙庭宇 on 2022/6/22.
//

import Foundation

@objcMembers
public class MimikkoPackageHelper: NSObject {
    /// 默认角色压缩包名
    static public let BUILTIN_MODEL = "miruku2-default"
    /// 默认角色的code
    private let BUILTIN_MODEL_CODE  = "clothes_miruku2_default"
    /// 默认角色hash值
    private let BUILTIN_MODEL_HASH  = "5980b70ccae71e998c7f6711c26ad1e8"
    /// 默认AI包名
    static public let BUILTIN_AI    = "miruku2-lv1-cn"
    /// 默认AI的Code
    private let BUILTIN_AI_CODE     = "voice_miruku2_chinese_lv1"
    /// 默认AI的Hash
    private let BUILTIN_AI_HASH     = "e1fff77a570933e3b5a3563854493479"
    
    private let fileManager = MimikkoFileManager()
    
    public func setupStageBuiltinPackages(modelCode: String = MimikkoPackageHelper.BUILTIN_MODEL, aiCode: String = MimikkoPackageHelper.BUILTIN_AI) {
        // 确认角色模型是否已保存到数据库
        if fileManager.findPackage(code: modelCode) == nil {
            // 未保存，则解压后保存
            if let _path = self.getZipPath(model: MimikkoPackageHelper.BUILTIN_MODEL) {
                fileManager.savePackageData(code: modelCode, stageHash: BUILTIN_MODEL_HASH, atPath: _path)
            }
        }
        // 确认AI模型是否已保存到数据库
        if fileManager.findPackage(code: aiCode) == nil {
            // 未保存，则解压后保存
            if let _path = self.getZipPath(model: MimikkoPackageHelper.BUILTIN_MODEL) {
                fileManager.savePackageData(code: aiCode, stageHash: BUILTIN_MODEL_HASH, atPath: _path)
            }
        }
    }
    
    // MARK: ==== Tools ====
    /// 压缩包地址
    private func getZipPath(model name: String) -> String? {
        var path: String?
        if name == MimikkoPackageHelper.BUILTIN_MODEL {
            // 如果是默认角色，则从Bundle中查找
            path = Bundle.main.bundleURL.appendingPathComponent("\(name)_builtin.zip").path
        } else {
            // 否则重本地已下载的目录中查找
            path = ""
        }
        return path
    }
    
}
