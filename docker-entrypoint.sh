#!/bin/sh -e

case $1 in

  web)
    bundle exec puma -C config/puma.rb
  ;;

  *)
    exec "$@"
  ;;

esac

exit 0