# 掌(上)绿(站)

适配[轻小说机翻机器人](https://books.fishhawk.top/)的，完全面向阅读的第三方客户端, 内置了 epub 解析
<del>名字绝对不是 neta 掌阅
<div style="display: flex; justify-content: center; flex-wrap: wrap;">
    <img src="./.github/img/0.jpg" alt="Image 3" style="margin: 5px; width: 130px; height: auto;">
    <img src="./.github/img/1.jpg" alt="Image 1" style="margin: 5px; width: 130px; height: auto;">
    <img src="./.github/img/2.jpg" alt="Image 2" style="margin: 5px; width: 130px; height: auto;">
    <img src="./.github/img/3.jpg" alt="Image 3" style="margin: 5px; width: 130px; height: auto;">
</div>

# ⬇️ 下载

[蓝奏云](https://wwrn.lanzouv.com/b00uyfaz9a)(密码: apd9, 更新进度不一定同步)

[Release](https://github.com/Prixii/auto_novel_reader_flutter/releases)


# 📦 如何运行

**代码生成**

本项目使用了代码生成，运行之前需要 build
```
$ flutter pub get
$ dart run build_runner build
```

**证书**

对于 `debug` 模式不需要证书，但是 `release` 需要

# ⚒️ 主要技术

几乎完全使用 `BLoC` 进行状态管理，通过 WebView 对 epub 文件进行渲染 

# ❤️ 贡献
由于仓主很忙，更新频率不会太高

欢迎有能人士提交 Pr 喵😘

如果有对于 app 的建议或发现了 Bug，也请提出 issue

# ❔ 已知问题与更新计划

**⚠️ 已知问题**

- 在「收藏」页面中，如果将当前收藏夹删除，会导致渲染错误
  > 切出「收藏」页面重新进入即可
- 弱网/无网状态下可能会出现一直加载的情况
  >可以尝试切换页面或重启应用
- 阅读 epub 文件的时候，滚动条和进度指示会出现抽搐
  >目前的 epub 渲染方案在长文本的情况下，面临着流畅度和进度定位二选一的困境，epub 渲染方式后会解决
- epub 封面不正确
  > 由于 epub 文件本身并没有严格的规范，导致封面的定位可能有误，后期会更新设置封面功能

**✈️ 在途更新计划**

- 弃用 WebView，并支持将流式本转换成分页阅读
- 下载 web 小说内容，以支持离线阅读
- 点击 Tag 搜索
- 升级本地 epub 系统
- 通过自动添加正则, 屏蔽指定 Tag 小说


**😭 以下内容因为 Api 不支持，暂时无法实现**

- 在小说详情之外的地方，显示上次阅读的章节

