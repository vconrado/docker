#!/bin/bash

echo "EOWS: Listening ..."
$EOWS_INSTALL_DIR/bin/eows_app_server --base-dir=$EOWS_INSTALL_DIR &

bash
