前言      
为实现用户打开H5链接时拿到用户微信ID，根据微信提供的接口，我们封装了微信登录的操作，开发者可快速简易地实现微信登录。
参考文档
http://mp.weixin.qq.com/wiki/17/c0f37d5704f0b64713d5d2c37b468d75.html
微信公众平台沙箱测试环境，本地开发测试用
https://mp.weixin.qq.com/debug/cgi-bin/sandbox?t=sandbox/login
 
根据微信提供的接口，授权登录分三种，对我们而言我们只需要关注前两种。
1、以snsapi_base为scope发起的网页授权，是用来获取进入页面的用户的openid的，并且是静默授权并自动跳转到回调页的。用户感知的就是直接进入了回调页（往往是业务页面）
2、以snsapi_userinfo为scope发起的网页授权，是用来获取用户的基本信息的。但这种授权需要用户手动同意，并且由于用户同意过，所以无须关注，就可在授权后获取该用户的基本信息。
我们把这两种授权方式分装为两种，base和advance，详细下文会提到。
说明
本文讲述的获取用户微信的ID，并不涉及平台的登录、获取Session用户、拼图账号和微信账号的绑定等问题，如果你是要解决此问题，本文不是最终解决方案，请酌情参考。
前提准备
1、WAP的服务端口改成80（必须）
1、网页授权需要配置授权域名，请在公众账号后台，接口权限列表中，“网页授权获取用户基本信息”接口，修改“OAuth2.0网页授权”域名
2、修改JS接口安全域名
使用用法
base授权（用户无感知）
 
引导用户跳转到到以下地址
 
String weChatAuthLoginUrl ="https://open.weixin.qq.com/connect/oauth2/authorize?appid="+appid+ "&redirect_uri="+URLEncoder.encode(wapUrl+"/wap/wechat/login?xsredirect="+URLEncoder.encode(businessUrl,"UTF-8")+"&ran=" + RandomUtil.getRandom(4),"UTF-8")+"&response_type=code&scope=snsapi_base&state=base#wechat_redirect";
 
其中wapUrl是wap站的地址，在本地或测试环境就是wap的内网ip，在线上就是线上域名
businessUrl是业务回调地址，用户微信授权完成后回跳转到本地址，例如
String wapUrl = "http://10.200.0.103";
String businessUrl = wapUrl+"/indexNew/productList/48";
 
advance授权
引导用户跳转到以下地址
 
String weChatAuthLoginUrl = "https://open.weixin.qq.com/connect/oauth2/authorize?appid="+appid+"&redirect_uri="+URLEncoder.encode(wapUrl+"/wap/wechat/login?xsredirect="+URLEncoder.encode(businessUrl,"UTF-8")+"&ran=" + RandomUtil.getRandom(4),"UTF-8")+"&response_type=code&scope=snsapi_userinfo&state=advance#wechat_redirect";
 
其中wapUrl是wap站的地址，在本地或测试环境就是wap的内网ip，在线上就是线上域名
businessUrl是业务回调地址，用户微信授权完成后回跳转到本地址，例如
String wapUrl = "http://10.200.0.103";
String businessUrl = wapUrl+"/indexNew/productList/48";
 
 
获取当前已授权的微信用户信息
WeixinUser weixinUser = getRequest().getSession().getAttribute(Constant.WEIXIN_USER)
 
That's all
这就完了
欢迎修正、完善和扩展。
