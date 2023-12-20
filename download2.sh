#!/usr/bin/env bash

# Copyright (c) Meta Platforms, Inc. and affiliates.
# This software may be used and distributed according to the terms of the Llama 2 Community License Agreement.

set -e

read -p "Enter the URL from email: " PRESIGNED_URL
echo ""
# Set MODEL_SIZE directly to download only the 7B-chat model
MODEL_SIZE="7B-chat"
TARGET_FOLDER="."             # where all files should end up
mkdir -p ${TARGET_FOLDER}

echo "Downloading LICENSE and Acceptable Usage Policy"
wget --continue ${PRESIGNED_URL/'*'/"LICENSE"} -O ${TARGET_FOLDER}"/LICENSE"
wget --continue ${PRESIGNED_URL/'*'/"USE_POLICY.md"} -O ${TARGET_FOLDER}"/USE_POLICY.md"

echo "Downloading tokenizer"
wget --continue ${PRESIGNED_URL/'*'/"tokenizer.model"} -O ${TARGET_FOLDER}"/tokenizer.model"
wget --continue ${PRESIGNED_URL/'*'/"tokenizer_checklist.chk"} -O ${TARGET_FOLDER}"/tokenizer_checklist.chk"
CPU_ARCH=$(uname -m)
  if [ "$CPU_ARCH" = "arm64" ]; then
    (cd ${TARGET_FOLDER} && md5 tokenizer_checklist.chk)
  else
    (cd ${TARGET_FOLDER} && md5sum -c tokenizer_checklist.chk)
  fi

# Only download the 7B-chat model
SHARD=0
MODEL_PATH="llama-2-7b-chat"

echo "Downloading ${MODEL_PATH}"
mkdir -p ${TARGET_FOLDER}"/${MODEL_PATH}"

for s in $(seq -f "0%g" 0 ${SHARD})
do
    wget --continue ${PRESIGNED_URL/'*'/"${MODEL_PATH}/consolidated.${s}.pth"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/consolidated.${s}.pth"
done

wget --continue ${PRESIGNED_URL/'*'/"${MODEL_PATH}/params.json"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/params.json"
wget --continue ${PRESIGNED_URL/'*'/"${MODEL_PATH}/checklist.chk"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/checklist.chk"
echo "Checking checksums"
if [ "$CPU_ARCH" = "arm64" ]; then
  (cd ${TARGET_FOLDER}"/${MODEL_PATH}" && md5 checklist.chk)
else
  (cd ${TARGET_FOLDER}"/${MODEL_PATH}" && md5sum -c checklist.chk)
fi

