#!/bin/bash
#chkconfig: 12345 80 90
#description:
#by liyixing

#!/bin/bash
#chkconfig: 12345 80 90
#description:
#by liyixing
#倒计时时间

countDownTime=1
path=/usr/local/nat

#倒计时
function countDown()
{
	max=$1
	echo ""
	
	for((i=$max;i>=0;i--))
	do
        	echo -ne "\b\b$i";
	        sleep 1;
	done

}


#停止
function stop(){
	echo "开始停止"
	cd ${path}
	countDown $countDownTime


	#解析出进程
	pid=$(ps -ef | grep "lsiding-xcode-0.0.1-SNAPSHOT-jar-with-dependencies.jar" | grep -v 'grep' | awk '{print $2}')
	echo "当前路径是：${path}"
	if [ -n "$pid" ];then
		#这里判断进程是否存在
		echo "当前进程ID是：${pid}"
		kill -9 ${pid}
		sleep 1
	fi
}


#重启
function start(){
	echo "启动"
	cd ${path}
	"$JAVA_HOME"/bin/java -Xmx256m -Dfile.encoding=utf-8 -cp lsiding-xcode-0.0.1-SNAPSHOT-jar-with-dependencies.jar com.lsiding.xcode.XClassLoader com.lsiding.nat.server.Server main > server.log.txt &
	countDown $countDownTime
	echo ""
	echo "启动完成"
}


if [ -f /etc/init.d/functions ]; then
        . /etc/init.d/functions
elif [ -f /etc/rc.d/init.d/functions ]; then
        . /etc/rc.d/init.d/functions
else
        echo -e "/service: functions库不存在，无法继续."
        exit -1
fi

RETVAL=$?
JAVA_HOME=/usr/local/jdk/jdk1.8.0_31
export JAVA_HOME=/usr/local/jdk/jdk1.8.0_31

case "$1" in
start)
        start
        ;;
stop)
        stop
        ;;
restart)
	stop
	start
	;;
*)
        echo $"执行: $0，参数：{start|stop|restart}"
        exit 1
        ;;
esac

exit $RETVAL