#!/bin/bash

cd "$(dirname "$0")"

source "./env.sh"

uv run bin/launcher.py
