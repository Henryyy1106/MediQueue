#!/bin/bash
# MediQueue - start the full local stack (isolated MySQL + Tomcat + Claude key).
# Safe to run repeatedly; it only starts what isn't already running.
set -e

# ---- config ----
MQ_HOME="$HOME/mediqueue"
DATADIR="$MQ_HOME/db"
SOCK="$MQ_HOME/mysql.sock"
PIDFILE="$MQ_HOME/mysql.pid"
ERRLOG="$MQ_HOME/mysql.err"
PORT=3307
KEYFILE="$HOME/.mediqueue_key"
# Homebrew prefix: /opt/homebrew on Apple Silicon, /usr/local on Intel Macs.
BREW="$(brew --prefix 2>/dev/null || echo /opt/homebrew)"
MYSQLD="$BREW/opt/mysql/bin/mysqld"
MYSQL="$BREW/opt/mysql/bin/mysql"
MYSQLADMIN="$BREW/opt/mysql/bin/mysqladmin"
CATBASE="$BREW/opt/tomcat/libexec"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCHEMA="$PROJECT_DIR/sql/mediqueue_schema.sql"
WAR="$PROJECT_DIR/target/mediqueue.war"
DB_URL="jdbc:mysql://localhost:$PORT/mediqueue?useSSL=false&serverTimezone=Asia/Kuala_Lumpur&allowPublicKeyRetrieval=true"

export JAVA_HOME="$(/usr/libexec/java_home)"
export JAVA_TOOL_OPTIONS="-Dmediqueue.db.url=$DB_URL"

echo "==> MediQueue stack starting..."

# ---- 1. MySQL ----
mkdir -p "$MQ_HOME"
if [ ! -d "$DATADIR/mysql" ]; then
  echo "==> Initializing fresh MySQL datadir at $DATADIR"
  "$MYSQLD" --initialize-insecure --datadir="$DATADIR" --basedir="$BREW/opt/mysql"
  NEED_BOOTSTRAP=1
fi

if "$MYSQLADMIN" --socket="$SOCK" -u root -proot ping >/dev/null 2>&1; then
  echo "==> MySQL already running on $SOCK"
else
  echo "==> Starting MySQL on port $PORT"
  "$MYSQLD" --datadir="$DATADIR" --basedir="$BREW/opt/mysql" \
    --port=$PORT --socket="$SOCK" --mysqlx=0 \
    --pid-file="$PIDFILE" --log-error="$ERRLOG" >/dev/null 2>&1 &
  # wait until it answers
  for i in $(seq 1 30); do
    "$MYSQLADMIN" --socket="$SOCK" -u root ping >/dev/null 2>&1 && break
    "$MYSQLADMIN" --socket="$SOCK" -u root -proot ping >/dev/null 2>&1 && break
    sleep 1
  done
fi

# On a freshly initialized datadir, set the root password.
if [ "${NEED_BOOTSTRAP:-0}" = "1" ]; then
  echo "==> Bootstrapping: set root password"
  "$MYSQL" --socket="$SOCK" -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';"
fi
# Load schema ONLY if the mediqueue DB / tables aren't there yet.
# (The clinic seed INSERTs are not idempotent, so never reload into an existing DB.)
if ! "$MYSQL" --socket="$SOCK" -u root -proot -e "USE mediqueue; SELECT 1 FROM users LIMIT 1;" >/dev/null 2>&1; then
  echo "==> Loading schema (first time)"
  "$MYSQL" --socket="$SOCK" -u root -proot < "$SCHEMA"
fi

# ---- 2. Build WAR if missing ----
if [ ! -f "$WAR" ]; then
  echo "==> Building WAR (mvn package)"
  ( cd "$PROJECT_DIR" && mvn -q package -DskipTests )
fi

# ---- 3. Tomcat ----
echo "==> Deploying WAR + starting Tomcat"
rm -rf "$CATBASE/webapps/mediqueue" "$CATBASE/webapps/mediqueue.war"
cp "$WAR" "$CATBASE/webapps/mediqueue.war"

CLAUDE_KEY=""
[ -s "$KEYFILE" ] && CLAUDE_KEY="$(cat "$KEYFILE")"
if [ -z "$CLAUDE_KEY" ]; then
  echo "    (no Claude key at $KEYFILE - AI features run in fallback mode)"
fi

CLAUDE_API_KEY="$CLAUDE_KEY" JAVA_HOME="$JAVA_HOME" JAVA_TOOL_OPTIONS="$JAVA_TOOL_OPTIONS" \
  "$CATBASE/bin/catalina.sh" start >/dev/null

echo ""
echo "==> MediQueue is starting at: http://localhost:8080/mediqueue/"
echo "    Logins: patient@mediqueue.my / patient123   |   admin@mediqueue.my / admin123"
echo "    (give it ~10s, then run ./stop.sh to shut everything down)"
