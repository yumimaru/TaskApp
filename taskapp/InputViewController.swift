//
//  InputViewController.swift
//  taskapp
//
//  Created by yumi on 2018/03/01.
//  Copyright © 2018年 yumimaru. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {
  
  @IBOutlet weak var titleTextField: UITextField!
  @IBOutlet weak var contentsTextView: UITextView!
  @IBOutlet weak var datePicker: UIDatePicker!
  @IBOutlet weak var categoryTextField: UITextField!
  
  //ViewController.swiftのtaskを定義
  var task: Task!
  
  let realm = try! Realm()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
    //タップを判断するにはUITapGestureRecognizerクラスを利用
    //UITapGestureRecognizerクラスの初期化時にタップされたときにどのクラスのどのメソッドが呼ばれるかを指定//
    //今回はself(=InputViewController自身)のdismissKeyboard()メソッドを指定
    //viewプロパティが背景に該当するので、addGestureRecognizer(_:)メソッドを使ってviewにUITapGestureRecognizerを登録
    //背景をタップした時にdismissKeyboard()メソッドが呼ばれるようになる
    let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
    self.view.addGestureRecognizer(tapGesture)
    
    titleTextField.text = task.title
    //課題用
    categoryTextField.text = task.category
    contentsTextView.text = task.contents
    datePicker.date = task.date
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  override func viewWillDisappear(_ animated: Bool) {
    try! realm.write {
      self.task.title = self.titleTextField.text!
      self.task.category = self.categoryTextField.text!
      self.task.contents = self.contentsTextView.text
      self.task.date = self.datePicker.date
      self.realm.add(self.task, update: true)
    }
    
    setNotification(task: task)
    
    super.viewWillDisappear(animated)
  }
  
  
  // タスクのローカル通知を登録する
  func setNotification(task: Task) {
    let content = UNMutableNotificationContent()
    // タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
    if task.title == "" {
      content.title = "(タイトルなし)"
    } else {
      content.title = task.title
    }
    if task.contents == "" {
      content.body = "(内容なし)"
    } else {
      content.body = task.contents
    }
    content.sound = UNNotificationSound.default()
    
    // ローカル通知が発動するtrigger（日付マッチ）を作成
    let calendar = Calendar.current
    let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
    let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
    
    // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
    let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
    
    // ローカル通知を登録
    let center = UNUserNotificationCenter.current()
    center.add(request) { (error) in
      print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
    }
    
    // 未通知のローカル通知一覧をログ出力
    center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
      for request in requests {
        print("/---------------")
        print(request)
        print("---------------/")
      }
    }
  }
  
  @objc func dismissKeyboard(){
    // endEditing(true)を呼び出してキーボードを閉じる
    view.endEditing(true)
    
  }
  
  
}
