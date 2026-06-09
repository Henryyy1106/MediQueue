#!/bin/bash
# MediQueue - stop the local stack (Tomcat + isolated MySQL).
MQ_HOME="$HOME/mediqueue"
SOCK="$MQ_HOME/mysql.sock"
BREW="$(brew --prefix 2>/dev/null || echo /opt/homebrew)"
CATBASE="$BREW/opt/tomcat/libexec"
MYSQLADMIN="$BREW/opt/mysql/bin/mysqladmin"
export JAVA_HOME="$(/usr/libexec/java_home)"

echo "==> Stopping Tomcat"
"$CATBASE/bin/catalina.sh" stop >/dev/null 2>&1
sleep 3
pkill -f catalina 2>/dev/null

echo "==> Stopping MySQL"
"$MYSQLADMIN" --socket="$SOCK" -u root -proot shutdown 2>/dev/null && echo "    MySQL stopped" || echo "    MySQL was not running"

echo "==> Done."
