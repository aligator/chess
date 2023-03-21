#!/bin/env sh

mkdir -p out/web
godot --display-driver headless --export-release Web
cat <<EOT >> out/html/Caddyfile
:2022

file_server

header Cross-Origin-Embedder-Policy "require-corp"
header Cross-Origin-Opener-Policy "same-origin"
EOT
