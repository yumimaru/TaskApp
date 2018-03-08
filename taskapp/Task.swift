//
//  Task.swift
//  taskapp
//
//  Created by yumi on 2018/03/05.
//  Copyright © 2018年 yumimaru. All rights reserved.
//

import RealmSwift


//@objc dynamic修飾子は今回使用するデータベースのライブラリであるRealmがKVO(Key Value Observing)という仕組みを利用しているため必要
//プライマリーキーとはデータベースでそれぞれのデータを一意に識別するためのID
//KVOとはプロパティの変更を監視するための仕組み
class Task: Object {
  // 管理用 ID。プライマリーキー
  @objc dynamic var id = 0
  
  //課題用；カテゴリー
  @objc dynamic var category = ""
  
  // タイトル
  @objc dynamic var title = ""
  
  // 内容
  @objc dynamic var contents = ""
  
  /// 日時
  @objc dynamic var date = Date()
  
  /**
   id をプライマリーキーとして設定
   */
  override static func primaryKey() -> String? {
    return "id"
  }
}
