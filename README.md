![](https://tva1.sinaimg.cn/large/007S8ZIlly1geqmdc0g5yj30r007gt96.jpg)

[![CocoaPods](https://img.shields.io/badge/pod-1.0.0-blue)](https://cocoapods.org/pods/GPVideoClipper)&nbsp;
[![CocoaPods](https://img.shields.io/badge/plaform-iOS9.0+-brightgreen)](https://github.com/Bestmer/GPVideoClipper)&nbsp;
[![License](https://img.shields.io/bad8ge/License-MIT-red)](https://github.com/Bestmer/GPVideoClipper)&nbsp;
 
**iOS long video clip tool, similar to WeChat moments select and edit videos larger than 15s from albums, and support saving as a local album.**

##### Related Articles：
##### [GPVideoClipper裁剪原理](https://www.jianshu.com/p/8c8dfd041f94)
# Contents

* [Preview](#Preview)
* [Feature](#Feature)
* [Installation](#Installation)
* [Usage](#Usage)
* [Swift Version](#SwiftVersion)

# <span id="Preview">Preview</span>
![](https://tva1.sinaimg.cn/large/007S8ZIlly1geqyw8w1n4g30a00hmb2b.gif)

# <span id="Feature">Feature</span>

- Support custom UI.
- Simple to use, only need to pass in the URL of the video.
- Small size, low memory.

# <span id="Installation">Installation</span>

## CocoaPods

1. Specify it in your Podfile:：
```
pod 'GPVideoClipper'
```
2. then `pod install` or `pod update`。
3. import `<GPVideoClipper.h>`。

if you can't search this repository，try update CocoaPods version or 

1.`pod cache clean --all`

2.`rm -rf ~/Library/Caches/CocoaPods` 

3.`pod repo update`



## Manuel

Download GPVideoClipper and drag all files to your project. 

# <span id="Usage">Usage</span>

Init `GPVideoClipperController` and set videoURL,in callback handle new video info .

```
GPVideoClipperController *controller = GPVideoClipperController.new;
controller.videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
[controller setCallback:^(NSURL * _Nonnull videoURL, PHAsset * _Nonnull videoAsset, UIImage * _Nonnull coverImage) {
    // handle videoURL，videoAsset，coverImage
}];
[self.navigationController pushViewController:controller animated:NO];
```
# <span id="SwiftVersion">Swift Version</span>
Swift version comming soon.

---

![](https://tva1.sinaimg.cn/large/007S8ZIlly1geqmdc0g5yj30r007gt96.jpg)

[![CocoaPods](https://img.shields.io/badge/pod-1.0.0-blue)](https://cocoapods.org/pods/GPVideoClipper)&nbsp;
[![CocoaPods](https://img.shields.io/badge/plaform-iOS9.0+-brightgreen)](https://github.com/Bestmer/GPVideoClipper)&nbsp;
[![License](https://img.shields.io/badge/License-MIT-red)](https://github.com/Bestmer/GPVideoClipper)&nbsp;

## 中文版本

**iOS长视频裁剪工具,类似于微信朋友圈从手机相册选择大于15s的视频后进行裁剪,支持另存为至本地相册。**

##### 相关文章：
##### [GPVideoClipper裁剪原理](https://www.jianshu.com/p/8c8dfd041f94)
# 目录

* [预览](#预览)
* [特性](#特性)
* [安装](#安装)
* [用法](#用法)
* [Swift版本](#Swift版本)


# 预览

![](https://tva1.sinaimg.cn/large/007S8ZIlly1geqyw8w1n4g30a00hmb2b.gif)

# 特性

- 支持自定义UI。
- 使用简单，仅需要传入视频的URL。
- 体积小巧，不占用内存空间。


# 安装

## CocoaPods

1. 在 Podfile 中添加：
```
pod 'GPVideoClipper'
```
2. 执行 `pod install` 或 `pod update`。
3. 导入 `<GPVideoClipper.h>`。

如果搜不到这个库，试着更新CocoaPods版本或者执行下面的操作：

1.`pod cache clean --all`

2.`rm -rf ~/Library/Caches/CocoaPods` 

3.`pod repo update`

## 手动导入

下载 GPVideoClipper 文件夹所有内容并拖入你的工程中即可.


# 用法

初始化`GPVideoClipperController`并且赋值videoURL，
在回调中处理新的视频信息。

```
GPVideoClipperController *controller = GPVideoClipperController.new;
controller.videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
[controller setCallback:^(NSURL * _Nonnull videoURL, PHAsset * _Nonnull videoAsset, UIImage * _Nonnull coverImage) {
    // 处理裁剪后的videoURL，videoAsset，视频封面
}];
[self.navigationController pushViewController:controller animated:NO];
```
# Swift版本

Swift版本即将更新，敬请期待。
