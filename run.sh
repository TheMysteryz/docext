#!/bin/bash

run_start() {
  docker run --rm \
    --gpus "device=1" \
    -p 6000:8000 \
    -p 7860:7860 \
    nanonets-docext
}

run_build() {
  if [ "$2" = "--no-cache" ]; then
    docker build --no-cache -t nanonets-docext .
  else
    docker build -t nanonets-docext .
  fi
}

run_stop() {
  docker stop $(docker ps -q --filter ancestor=nanonets-docext)
}

show_help() {
  echo "Usage: run.sh [command] [options]"
  echo "Commands:"
  echo "  start              - Start the Docker container"
  echo "  build [--no-cache] - Build the Docker image (optionally without cache)"
  echo "  stop               - Stop the Docker container"
  echo "  help               - Show this help message"
}

case "$1" in
  start)
    run_start
    ;;
  build)
    run_build "$@"
    ;;
  stop)
    run_stop
    ;;
  help|*)
    show_help
    ;;
esac