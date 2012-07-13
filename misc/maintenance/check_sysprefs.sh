#!/bin/sh
echo "This script will compare your systempreferences with what is expected"
echo "If you see only '#No tests run!' below, your systempreferences are OK."
echo "Otherwise, you'll get SQL comment to insert missing systempreferences"
echo "===== Test result ====="
perl `dirname $0`/../../t/db_dependent/check_sysprefs.t --showsql
