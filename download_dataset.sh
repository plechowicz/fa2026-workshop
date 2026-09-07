#!/usr/bin/env bash
set -euo pipefail

DATASET_DIR="datasets/ssw"
BASE_URL="https://zenodo.org/records/7079380/files"

mkdir -p "$DATASET_DIR"

download() {
  local url="$1"
  local dest="${DATASET_DIR}/$2"

  if [ -f "${dest}" ]; then
    echo "Already have ${dest}, skipping."
    return 0
  fi

  echo "Downloading ${dest}..."
  curl -Lf -C - --retry 5 --retry-delay 10 --retry-all-errors \
    -o "${dest}.part" "${url}"
  mv "${dest}.part" "${dest}"
}

download_and_extract_zip() {
  local url="$1"
  local zip_name="$2"
  local dest="${DATASET_DIR}/${zip_name}"
  local audio_dir="${DATASET_DIR}/data"

  # if dir created and contains any flac files inside, skip
  if [ -d "${audio_dir}" ] && ompgen -G "${audio_dir}/*.flac" > /dev/null; then
    echo "Already have ${audio_dir}, skipping."
    return 0
  fi

  mkdir -p "${audio_dir}"

  if [ ! -f "${dest}" ]; then
    echo "Downloading ${dest}..." 
    curl -Lf -# -C - --retry 5 --retry-delay 10 --retry-all-errors -o "${dest}.part" "${url}"
    mv "${dest}.part" "${dest}"
  fi

  echo "Extracting ${dest}..."
  unzip -n "${dest}" -d "${audio_dir}"
  rm -f "${dest}"
}

download "${BASE_URL}/annotations.csv" "annotations.csv"
download "${BASE_URL}/species.csv" "species.csv"
download "${BASE_URL}/recording_location.txt" "recording_location.txt"
download "${BASE_URL}/description.pdf" "description.pdf"

download_and_extract_zip \
  "${BASE_URL}/soundscape_data.zip" \
  "soundscape_data.zip"

echo "Done. Files are in ${DATASET_DIR}"
