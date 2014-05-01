#!/bin/bash

#Terminates the session leader Sipserver which should terminate the children
# The pidfile name is specified as a server parameter in the configuration
# file

PID_FILE=/var/run/sipserver.pid

kill `cat $PID_FILE`

