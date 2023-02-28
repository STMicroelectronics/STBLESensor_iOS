
@*******************************

科大讯飞iOS平台语音SDK Demo使用说明

@*******************************

一 demo功能介绍


@"语音听写",
	语音听写使用示例, 包含无界面和带界面，音频流识别和上传联系人，词表功能。
	business/isr/

@"语义理解",
	不带界面的语义理解使用示例
	business/nlp/

@"语法识别",
	针对abnf语法的语音识别使用示例
	business/asr/

@"语音合成",
	不带界面的语音合成使用示例
	business/tts/

@"语音唤醒"
    不带界面的语音唤醒使用示例
    business/ivw/

@"语音评测"
    不带界面的语音评测使用示例
    business/ise/

@"其他";
	其他功能本示例仅提供提醒功能。

二 目录结构说明

   doc目录放置demo和SDK的开发文档；

   Definition.h放置appid的头文件定义，在登陆时需要传入appid；

   demo目录为App启动入口，包含了demo的登陆配置代码，log日志设置代码和主界面实现；

   business目录放置各业务的调用示例；

   tools为解析各种识别结果的工具类；

   storyBoard防止demo的界面；

   bnf为放置abnf语法和abnf语法文件；
 
   Frameworks为sdk依赖的库文件。
   

