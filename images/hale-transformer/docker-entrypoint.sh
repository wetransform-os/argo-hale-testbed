#!/bin/bash

#
# Script that serves as wrapper for hale CLI for the transformation in Argo.
#


# Check if required environment variables are set
if [[ -z "${HT_PROJECT_URL}" ]]; then
    echo "Error: ${HT_PROJECT_URL} is not set."
    exit 1
fi
if [[ -z "${HT_SOURCE_URL}" ]]; then
    echo "Error: ${HT_SOURCE_URL} is not set."
    exit 1
fi

# Initialize optional settings

HT_SOURCE_INCLUDE="${HT_SOURCE_INCLUDE:-**.gml}"

HT_TARGET_PRESET="${HT_TARGET_PRESET:-default}"

HT_TARGET_FILE="${HT_TARGET_FILE:-/tmp/target.gml}"

HT_REPORTS_FILE="${HT_REPORTS_FILE:-/tmp/reports.log}"

HT_STATS_FILE="${HT_STATS_FILE:-/tmp/stats.json}"


# Download source file (to prepare extraction - we always expect a Zip)
curl -L $HT_SOURCE_URL > "${DATA_DIR}/source.zip"
rc=$?; if [ $rc -ne 0 ]; then echo "ERROR: Error downloading source file"; exit $rc; fi

# Extract source file

# check file mime type
# source_mime=$(file -b --mime-type $source_loc)
# echo "Mime-type for source file: $source_mime"

# extract if ZIP file
# if [ "$source_mime" == "application/zip" ]; then
  echo "Source file is a ZIP file - extracting..."
  mkdir "${DATA_DIR}/source-zip" || true
  unzip "${DATA_DIR}/source.zip" -d "${DATA_DIR}/source-zip"

  # count extracted files
  archive_file_count=$(ls -1 "${DATA_DIR}/source-zip/" | wc -l)

  if [ $archive_file_count -eq 1 ]; then
    # single file -> use as new source
    extracted_file=$(ls -1 "${DATA_DIR}/source-zip/")
    source_loc="${DATA_DIR}/source-zip/$extracted_file"
    SOURCE_ARGS="-source $source_loc"
  else
    # multiple files
    # use extracted folder as new source
    source_loc="${DATA_DIR}/source-zip"
    SOURCE_ARGS="-source $source_loc -include \"$HT_SOURCE_INCLUDE\""
  fi

  echo "Local source is ${source_loc}"
# fi


# Run transformation
# Transformation arguments see http://help.halestudio.org/latest/topic/eu.esdihumboldt.hale.doc.user/html/tasks/transform_cli.html?cp=0_6_6
exec /hale/bin/hale \
  transform \
  -project "$HT_PROJECT_URL" \
  $SOURCE_ARGS \
  -target "$HT_TARGET_FILE" \
  -preset "$HT_TARGET_PRESET" \
  -reportsOut "$HT_REPORTS_FILE" \
  -statisticsOut "$HT_STATS_FILE" \
  -successEvaluation /success.groovy \
  -stacktrace
