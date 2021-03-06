SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ROOT_DIR=$SCRIPT_DIR/..
CLIENT_DIR=$ROOT_DIR/packages/client
DB_DIR=$ROOT_DIR/packages/server/data

fail () {
  echo $'\n\n*** Error:' $1 $'***\n\n'
  exit 1
}

killwait() {
    while kill -0 "$1"; do
        sleep 0.5
    done
}

cd $ROOT_DIR

MONGODB_PID="$(lsof -iTCP:27017 -sTCP:LISTEN -n -Pt)"

if [ ! -z $MONGODB_PID ] ; then
  echo "MongoDB was not terminated properly last time, killing it... Try to restart the script"
  kill -9 $MONGODB_PID
  exit 1
fi

mongod --dbpath $DB_DIR || fail "Failed to launch DB server" &

lerna bootstrap
lerna run tsc

npx jest

cd $CLIENT_DIR
npm run clean-build || fail "Failed to clean Client" &