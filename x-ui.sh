#!/bin/bash

case "$1" in
  start)
    echo "Starting x-ui..."
    systemctl start x-ui
    ;;
  stop)
    echo "Stopping x-ui..."
    systemctl stop x-ui
    ;;
  restart)
    echo "Restarting x-ui..."
    systemctl restart x-ui
    ;;
  status)
    echo "Checking x-ui status..."
    systemctl status x-ui
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status}"
    exit 1
    ;;
esac

exit 0
