# Slow App iOS
## 简介
慢社交App

---

## 整体架构
项目框架使用 [RxSwift](https://github.com/ReactiveX/RxSwift) 框架搭建。
网络模块使用 [Alamofire](https://github.com/Alamofire/Alamofire) + [RxMoya模块](https://github.com/Moya/Moya/tree/master/Sources/RxMoya) + [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) 配合Protocol搭建。
整体设计模式使用MVC模式，部分功能界面复杂或与UI绑定明显的将使用MVVM设计。

### 目录格式

```
| ___ SlowTime
| | ___ AppDelegate.swift
| | ___ Network(网络模块相关)
| | | ___ NetworkManager.swift(配置所有 App 内请求默认参数和网络状态判断)
| | | ___ Request.swift(网络请求接口)
| | | ___ Network+Moya+SwiftyJSON.swift(满足函数式编程 Extension，数据请求解析统一在这处理)
| | ___ Helpers
| | | ___ Config.swift(App 内公共参数，方法)
| | | ___ RegexHelpre.swift(正则表达式语法糖)
| | ___ Protocol
| | | ___ Parseable.swift(自定义操作符和初始化方法使用 SwiftyJSON 映射 JSON 到对象)
| | ___ Libraries(使用的三方框架, 多文件使用 Carthage 管理，单文件拖入项目中维护)
| | | ___ R.generated.swift(R.library)
| | ___ Extension(系统框架功能扩展)
| | ___ Controllers
| | ___ Views
| | ___ Model
| | ___ Resource(全局资源)
```

### 三方库使用
项目使用 [**Carthage**](https://github.com/Carthage/Carthage) 管理使用三方框架。

建议: **网络，图片加载，缓存等基础组件库可以使用，跟 UI 相关尽量只做参考不要引入项目导致不便于维护与更新。**

### 网络模块设计
最初只使用了 `Alamofire` 处理所有的网络请求， 自定义操作符 `<-` 使用 `SwiftyJSON` 做 JSON的解析和映射。
在项目加入 `RxSwift` 后为了便于符合**函数式编程**和**AOP**思想引入 `Moya`，使用 `RxMoya` 模块搭建网络服务，配合 `Moya` 的插件机制可以更好的统一处理请求事件，方便测试和更换组件。

### 编程风格
推荐使用 **AOP** 与 **函数式** 进行编程，使用 `Extension` 对原有功能进行扩展。

---

## 脚本使用
- conversion.py（）

```
$ cd SlowTime/
$ python conversion.py
```


