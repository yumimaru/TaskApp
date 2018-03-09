//
//  ViewController.swift
//  taskapp
//
//  Created by yumi on 2018/02/28.
//  Copyright © 2018年 yumimaru. All rights reserved.
//

import UIKit
import RealmSwift

//UITableViewDataSource, UITableViewDelegateはプロトコル
//継承クラス(ここではUIViewController)のあとに、,区切りで続けて記述
//UITableViewDelegateはTableViewのユーザ操作に関する約束。タップ時の動作など。
//UITableViewDataSourceはTableViewの表示内容に関する約束。下記func tableView(から始まるデリゲートメソッド2つが必須
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searhBarData: UISearchBar!
  
  //var taskArray: Results<Task>?
  
  // Realmインスタンスを取得する
  let realm = try! Realm()
  
  // DB内のタスクが格納されるリスト。
  // 日付近い順\順でソート：降順
  // 以降内容をアップデートするとリスト内は自動的に更新される。
  var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
  
  override func viewDidLoad() {
    super.viewDidLoad()
   // let realm = try! Realm() //クラス変数出持っているので不要
   // taskArray = realm.objects(Task.self) //最初は値が入っているので不要
    searhBarData.delegate = self
    //Outletで接続したtableViewのdelegateとdataSourceにselfを指定
    //selfとはViewControllerのこと。delegateは委譲
    //ViewControllerはtableViewの代わりに表示データ、挙動を実装するということ
    tableView.dataSource = self
    tableView.delegate = self
  }
  
  //検索ボタンが押されると呼び出されるメソッド
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    //キーボードを閉じる。
    searhBarData.endEditing(true)
    
  }
  
  
  //テキスト変更時の呼び出しメソッド
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
    if searchText.isEmpty {
      //検索文字列が空の場合はすべてを表示する。
      taskArray = realm.objects(Task.self).sorted(byKeyPath: "date")
      
    } else {
      //検索文字列を含むデータを検索結果配列に追加する。
      taskArray = realm
        .objects(Task.self)
        .filter("category BEGINSWITH %@", searchText)
      
    }
    
    //テーブルを再読み込みする。
    tableView.reloadData()
  }
  
  



override func didReceiveMemoryWarning() {
  super.didReceiveMemoryWarning()
  // Dispose of any resources that can be recreated.
}

//UITableViewDataSourceプロトコルで指定されたデリゲートメソッド。セルを何列並べるかを返す
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  return taskArray.count // staskArray.count列のテーブルになる
}

//プロトコルUITableViewDataSourceで指定されたデリゲートメソッド。セルにどんな内容を表示するかを返す
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  // 再利用可能な cell を得る
  let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
  
  // Cellに値を設定する.
  let task = taskArray[indexPath.row]
  cell.textLabel?.text = "\(task.title) [\(task.category)]" //「タイトル [カテゴリ]」のような表示になる
  //または、cell.textLabel?.text = task.title + " " + task.category
  
  let formatter = DateFormatter()
  formatter.dateFormat = "yyyy-MM-dd HH:mm"
  
  let dateString:String = formatter.string(from: task.date)
  cell.detailTextLabel?.text = dateString
  
  return cell
}

// MARK: UITableViewDelegateプロトコルのメソッド
// 各セルを選択した時に実行されるメソッド
//tableView(_:didSelectRowAt:)メソッドはセルをタップした時に呼ばれるメソッド
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  //segueのIDを指定して遷移させるperformSegue(withIdentifier:sender)メソッドの呼び出し
  performSegue(withIdentifier: "cellSegue",sender: nil)
}

// セルが削除が可能なことを伝えるメソッド
//tableView(_:editingStyleForRowAt:)メソッドはセルが削除が可能かどうか、並び替えが可能かどうかなどどのように編集ができるかを返すメソッド。taskappでは削除を可能にするため、.deleteを返す。
func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
  return .delete
}

// Delete ボタンが押された時に呼ばれるメソッド
//tableView(_:commit:forRowAt:)メソッドはセルが削除されるときに呼ばれるメソッド。
func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
  if editingStyle == .delete {
    // データベースから削除する  //
    try! realm.write {
      self.realm.delete(self.taskArray[indexPath.row])
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }
}


// segue で画面遷移するに呼ばれる
override func prepare(for segue: UIStoryboardSegue, sender: Any?){
  let inputViewController:InputViewController = segue.destination as! InputViewController
  
  if segue.identifier == "cellSegue" {
    let indexPath = self.tableView.indexPathForSelectedRow
    inputViewController.task = taskArray[indexPath!.row]
  } else {
    let task = Task()
    task.date = Date()
    
    let taskArray = realm.objects(Task.self)
    if taskArray.count != 0 {
      //taskArray.max(ofProperty: "id")ですでに存在しているタスクのidのうち最大のものを取得
      //1を足すことで他のIDと重ならない値を指定
      task.id = taskArray.max(ofProperty: "id")! + 1
    }
    
    inputViewController.task = task
  }
}

// 入力画面から戻ってきた時に TableView を更新させる
//タスク作成/編集画面で新規作成/編集したタスクの情報をTableViewに反映
override func viewWillAppear(_ animated: Bool) {
  super.viewWillAppear(animated)
  //UITableViewクラスのreloadDataメソッドを呼ぶ
  tableView.reloadData()
}




}

