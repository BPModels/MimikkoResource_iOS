//
//  MimikkoFileManager.swift
//  SwiftTestDemo
//
//  Created by 沙庭宇 on 2022/6/23.
//

import Foundation
import SSZipArchive
import ObjectMapper

class MimikkoFileManager: NSObject {
    
    /// 解压后的地址
    private var unzipPath: String? = {
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? NSHomeDirectory()
        path += "/\(UUID().uuidString)"
        let url = URL(fileURLWithPath: path)
        
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            return nil
        }
        return url.path
    }()
    
    /// 根据Code查找压缩包的信息
    /// - Parameter code: 压缩包code
    func findPackage(code: String) -> MimikkoPackageModel? {
        let dbManager = MimikkoDBManager()
        let model = dbManager.selectPackageData(code)
        return model
    }
    
    /// 解压包，并保存到数据库
    /// - Parameters:
    ///   - code: 包名
    ///   - stageHash: hash值
    ///   - version: 版本
    ///   - atPath: 压缩包地址
    func savePackageData(code: String, stageHash: String, version: Int = 1, atPath: String) {
        // 1、解压
        guard let unzipPath = unzipPath else {
            return
        }
        let result = self.unzip(atPath: atPath, toPath: unzipPath)
        var fileModelList = [MimikkoStageFileModel]()
        if result {
            print("解压完成")
        // 2、更新文件地址信息
            let filePath  = unzipPath + "/fileMap.json"
            self.readArrayJson(at: filePath, objList: &fileModelList)
            // 更新对应的path地址
            for (index, model) in fileModelList.enumerated() {
                fileModelList[index].path    = "\(unzipPath)/\(model.path ?? "")"
                fileModelList[index].package = code
            }
        } else {
            print("解压失败")
        }
        // 3、保存到数据库
        let packageModel = MimikkoPackageModel()
        packageModel.code       = code
        packageModel.room       = unzipPath
        packageModel.meta       = "\(unzipPath)/meta.json"
        packageModel.stageHash  = stageHash
        packageModel.version    = version
        
        let dbManager = MimikkoDBManager()
        dbManager.updatePackageData(packageModel)
        dbManager.updateStageFilesData(fileModelList, withPackage: code)
        
        // 4、删除解压后的文件夹
//        do {
//            try FileManager.default.removeItem(atPath: unzipPath)
//        } catch let error {
//            print("删除文件失败：\(error)")
//        }
        // 5、测试
        let filesPathList = self.getFiles(at: unzipPath)
        print("被删除后的目录下文件列表：\(filesPathList)")
    }
    
    // TODO: ==== Tools ====
    
    /// 解压文件
    /// - Parameters:
    ///   - atPath: 压缩文件地址
    ///   - toPath: 解压后文件存放地址
    ///   - block: 解压完成后回调
    private func unzip(atPath: String, toPath: String) -> Bool {
        var result = false
        let semaphore = DispatchSemaphore(value: 1)
        SSZipArchive.unzipFile(atPath: atPath, toDestination: toPath) { fileName, fileInfo, currentIndex, totalIndex in
            print("\(currentIndex)/\(totalIndex)")
        } completionHandler: { _atPath, _result, _error in
            result = _result
            semaphore.signal()
        }
        semaphore.wait()
        return result
    }
    
    /// 获取目录下所有文件
    /// - Parameter at: 所有文件地址列表
    private func getFiles(at path: String) -> [String] {
        let enumerator  = FileManager.default.enumerator(atPath: path)
        let files       = enumerator?.allObjects as? [String] ?? []
        return files
    }
    
    /// 读取JSON文件中的数据列表
    /// - Parameters:
    ///   - path: 文件地址
    ///   - objList: 接收的对象
    private func readArrayJson<T:BaseMappable>(at path: String, objList: inout [T]) {
        let url = URL(fileURLWithPath: path)
        do {
            let data      = try Data(contentsOf: url, options: Data.ReadingOptions.alwaysMapped)
            let arrayJson = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [[String:Any]] ?? []
            let list      = Mapper<T>(context: nil, shouldIncludeNilValues: true).mapArray(JSONArray: arrayJson)
            objList       = list
        } catch let error {
            print("read json error: \(error)")
        }
    }
}
