//
//  MimikkoStageFileModel.swift
//  SwiftTestDemo
//
//  Created by 沙庭宇 on 2022/6/23.
//

import ObjectMapper

/// 角色数据文件信息模型
@objc
public class MimikkoStageFileModel: NSObject, Mappable {
    @objc public var package: String?
    @objc public var path: String?
    @objc public var encryption = false
    
    override public init() {}
    required public init?(map: Map) {}
    public func mapping(map: Map) {
        package     <- map["pkg"]
        path        <- map["path"]
        encryption  <- map["encryption"]
    }
}

/// 角色压缩包信息
@objc
public class MimikkoPackageModel: NSObject, Mappable {
    @objc public var code: String      = ""
    @objc public var room: String      = ""
    @objc public var meta: String      = ""
    @objc public var stageHash: String = ""
    @objc public var version: Int      = -1
    
    override public init() {}
    required public init?(map: Map) {}
    public func mapping(map: Map) {
        code        <- map["code"]
        room        <- map["room"]
        meta        <- map["meta"]
        stageHash   <- map["hash"]
        version     <- map["version"]
    }
}
