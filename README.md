# nat 穿透引擎

## 目前最新版本1.004，请确定您运行后的版本显示的是1.004

### 更新概要  
**1.004**  

 1. 修复web response content-length过大带来的tomcat网络断开  

## 什么是nat

nat是由java实现的网络穿透器
包含了
**基础的代理功能**
 - socks5代理
 - http代理
 - 端口转发
 **内网穿透**
**基于jee（web引擎）服务器的nat**
可以与
 - 基础的代理功能
 - 内网穿透功能
 自由组合使用，以达到基于jee功能的网络穿透，代理等功能


##使用
服务端
 - 服务端xcode.bat  
 - server.txt  

客户端
 - 客户端xcode.bat  
 - client.txt  

 git提供的client.txt配置文件是一个经过测试可用的配置，与本人提供的测试服务器对接。  
 启动客户端，浏览器打开代理功能，代理IP 127.0.0.1  端口 26390  
 注意此测试服务器性能网络不是很好，请不要疯狂试用~~~~~~~~~   
 
###配置文件
所有的配置文件，注释都是以;开头，不包含空格，2如：    
;这是注释，;前面不能有空格  
;配置文件每一个配置占用一行  
####服务端server.txt  
;发送任务列表，必须在第一个，必须（作用看后面）
6998    
;请求处理任务，必须在第二个，必须（作用看后面）
6999    
;端口号，不限制数量  
26383    
26384    

;socks5代理模式  
socks5,26385,test,test1  
;端口代理模式  端口，目标ip，目标端口  
proxy,26382, cq.lsiding.com, 80  
;http代理模式  端口，目标ip，目标端口，只支持get，post，CONNECT模式  
;get,post两种模式，访问端口，将会被直接做端口转发，会修改HOST，等头部信息  
;如果get 或者post 的路径是全局路径（http://xxxx.com/xxx.xxx）那表示使用普通代理  
;host会被xxxx.com代替  
;CONNECT隧道代理模式，解析CONNECT，并做打开链接通道，做端口数据转发，目标和目标端口由CONNECT指定
httpproxy,26381, cq.lsiding.com, 80  

####客户端client.txt   
;nat穿透主服务器  
;如果要使用WEB适配模式完成穿透任务，这里可以填127.0.0.1   
;6998,6999可以改成26387，26388（对应下面的web适配器端口）  
106.14.118.59  
;获取nat穿透主服务器收到的任务，在主服务器下面一行，必须  
6998  
;处理nat穿透主服务器收到的任务，在主服务器下面2行，必须  
6999  
;目标ip，目标端口，nat穿透主服务器收到的链接请求端口  
127.0.0.1,3389,26383  
;http穿透模式  
http,cq.lsiding.com,80,26384  
;web适配器,本地端口，适配的目标web服务器，web服务器端口，web服务器接受的链接  
;密码，处理的目标位置,web-body最大数（Content-Length），需要根据目标web服务器的设置参数  
web,26386,www.lsiding.com,8100,/test/web_proxy.html,123,47.97.194.7:3389,102400   
web,26387,www.lsiding.com,8100,/test/web_proxy.html,123,SEND,102400   
web,26388,www.lsiding.com,8100,/test/web_proxy.html,123,HAND,102400   
web,26389,www.lsiding.com,8100,/test/web_proxy.html,123,JOBGET:26383,102400  
web,26390,www.lsiding.com,8100,/test/web_proxy.html,123,HTTP_PROXY,102400  
web,26391,www.lsiding.com,8100,/test/web_proxy.html,123,SOCKS5_PROXY,102400  

**说明一下任务发送，任务处理**  
内网穿透是基于任务概念完成的，当有目前链接到穿透服务器的端口112233   
我们称为这个行为为任务，编号是112233  
穿透服务器与穿透客户端的交互逻辑  
![输入图片说明](https://lsiding-common.oss-cn-shanghai.aliyuncs.com/nat/3.png "在这里输入图片标题")   


```seq
CLIENT->SERVER(6998):我要处理26383,26384任务
SERVER(6998)-->CLIENT:还没有任务过来，测试下网络状态
USERCASE1->SERVER(112233):我链接啦
SERVER(6998)->CLIENT:呆子，有人请求处理一个112233的任务
CLIENT->SERVER(6999):队长别开枪，我是来处理112233任务的
USERCASE1->SERVER(112233):爱我吗？
SERVER(6999)->CLIENT:吊毛问:爱我吗？
CLIENT->SERVER(6999):回复他:老纸不爱！
SERVER(112233)->USERCASE1:老纸不爱！
```


### 1. 基础代理功能 
针对基础代理，可以百度一下，相关资料，这些都是基础功能不需要很多描述
- [x] socks5代理
- [x] http代理
- [x] 端口转发

### 2. 内网穿透

让我们用例子来说明内网穿透

假设你公司有一台电脑CA（开启了远程服务器）,你有一台可以使用的服务器SA。  
你在家中电脑CB，想要链接到电脑CA，但是CA是属于公司内网内的网络节点，家中无法访问。  
那么可以通过nat提供的功能访问到CA。  
CA开启nat客户端  
SA开启nat服务端  

![输入图片说明](https://lsiding-common.oss-cn-shanghai.aliyuncs.com/nat/1.png "在这里输入图片标题")


```seq
CA->SA: 你好,我要接受来自你1234端口的数据
SA-->CA: 没有收到请求，测试下网络状态吧
CB->SA: 我链接你的1234端口
SA->CA: 有人链接到我的1234端口
CA->SA: 请把1234交给我处理吧
CB->SA: 123
SA->CA: 丫发了个123过来
CA->SA: 那帮我给丫回复个456吧
SA->CB: 456
```

### 3. 基于web（JEE）引擎的nat穿透
此功能主要针对，当你的服务器只允许开放一个端口给公网，比如80，而且，这个80端口，是有比如tomcat提供服务的。   
**注意，如果你的tomcat的前面还有一个反向代理转发到实际的tomcat，nat穿透引擎目前还不支持。**    
**注意，此功能受到web引擎的限制，数据超长会自动抛弃数据，出现比如远程操作几秒后会卡住。**  
**如果不想被截断，请设置足够大的maxPostSize。**
**下个版本将会修复反向代理的情况**    
**目前测试，tomcat request body 超过达到10MB会断开SOCKET**   
上面的例子就会变成  
CA开启nat客户端（含web适配器 CAA）  
SA把nat引擎提供的servlet(也可以自己实现)加入到web.xml  
CB开启web适配器（CBB）  


![输入图片说明](https://lsiding-common.oss-cn-shanghai.aliyuncs.com/nat/2.png "在这里输入图片标题")

```seq
CA->CAA: 我要接受来自你1234端口的数据
CAA-SAWEB: http适配（我要接受来自你1234端口的数据）
SAWEB-->CAA: 回复HTTP BODY（没有收到请求，测试下网络状态吧）
CAA-->CA: http适配（没有收到请求，测试下网络状态吧）
CB->CBB: 你好，我链接你的4567端口
CBB->SAWEB: http适配（你好，我链接你的1234（适配器的4567转化成1234）端口）
SAWEB->CAA: 回复HTTP BODY（有人链接到我的1234端口）
CAA->CA: HTTP适配（有人链接到我的1234端口）
CA->CAA: 请把1234交给我处理吧
CAA->SAWEB: HTTP适配（请把1234交给我处理吧）
CB->CBB: 123
CBB->SAWEB: HTTP适配（123）
SAWEB->CAA: 回复HTTP BODY（丫发了个123过来）
CAA->CA: HTTP适配（丫发了个123过来）
CA->CAA: 那帮我给丫回复个456吧
CAA->SAWEB: HTTP适配（那帮我给丫回复个456吧）
SAWEB->CBB: 回复HTTP BODY（456）
CBB->CB: HTTP适配（456）
```

servlet自己实现需要完成以下基本功能
```java
package com.lsiding.nat.server.web;

import java.io.IOException;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.lsiding.xcode.XClassLoader;

public class WebProxyMain extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private String sKey = null;

	public void init(ServletConfig config) throws ServletException {
		sKey = config.getInitParameter("sKey");

		try {
			Object SOCKS5_PROXY = XClassLoader.getStaticValue(
					"com.lsiding.nat.server.web.WebProxy", "SOCKS5_PROXY");
			XClassLoader.runMethod(SOCKS5_PROXY, "setUsername",
					config.getInitParameter("s5usernmae"));
			XClassLoader.runMethod(SOCKS5_PROXY, "setPassword",
					config.getInitParameter("s5password"));
			XClassLoader.setStaticValue("com.lsiding.nat.server.web.WebProxy",
					"maxContentLength", Integer.valueOf(config
							.getInitParameter("maxContentLength")));
		} catch (Exception e) {
		}
	}

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public WebProxyMain() {
		super();
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		Object webProxy;
		try {
			webProxy = XClassLoader.runMethod(
					"com.lsiding.nat.server.web.WebProxy", "getInstance", sKey);
			XClassLoader.runMethod(webProxy, "hand", request, response);
		} catch (Exception e) {
		}
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}

}

```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns="http://java.sun.com/xml/ns/javaee"
	xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd"
	version="3.0">
	<!-- 挂载nat的servlet -->
	<servlet>
		<servlet-name>webProxyMain</servlet-name>
		<servlet-class>com.lsiding.nat.server.web.WebProxyMain</servlet-class>

		<!-- 这几个参数必须 -->
		<!-- skey需要和web适配器中的密码对应起来 -->
		<init-param>
			<param-name>sKey</param-name>
			<param-value>123</param-value>
		</init-param>
		
		<init-param>
			<param-name>s5usernmae</param-name>
			<param-value>test</param-value>
		</init-param>
		
		<init-param>
			<param-name>s5password</param-name>
			<param-value>test1</param-value>
		</init-param>
		
		<!-- 最大body，由web引擎参数决定 -->
		<init-param>
			<param-name>maxContentLength</param-name>
			<param-value>102400</param-value>
		</init-param>

		<load-on-startup>1</load-on-startup>
	</servlet>

	<servlet-mapping>
		<servlet-name>webProxyMain</servlet-name>
		<url-pattern>/web_proxy.html</url-pattern>
	</servlet-mapping>
</web-app>
```

### 为什么不开源？
代码写的这么差，怎么好意思开源呢~~~~~~~~~~~~

### 支援一波
由螺丝钉网络提供  
如果你觉得这个产品有点意思，可以捐赠一下  
支付宝：459387495@qq.com  
商业合作，获取源码授权等，联系QQ：459387495  