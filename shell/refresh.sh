#!/bin/bash

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <refresh_frequency> <script> <args...>"
  exit 1
fi

refresh_freq=$1
script=$2
shift 2 # remove first two arguments

output_file=$(mktemp) # create a temporary file to spool the output

while true; do
  # Run the script and redirect the output to the spool file
  sh $script "$@" > "$output_file" 2>&1

  # Clear the screen and display the spooled output
  clear
  cat "$output_file"

  # Wait for the refresh frequency
  sleep "$refresh_freq"
done

# Remove the temporary file on exit
trap "rm -f $output_file" EXIT

