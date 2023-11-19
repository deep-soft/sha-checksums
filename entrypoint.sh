#! /bin/bash
# 2023-11-19 08:00

# Create sha sums or exit if command fails
#set -eu
set -f
if [ "$DEBUG_MODE" = "yes" ]
then
  set -x
fi

StartTime="$(date -u +%s)"
CrtDate=$(date "+%F^%H:%M:%S")
echo "Start: " $CrtDate

# change path separator to /
INPUT_DIRECTORY=$(echo $INPUT_DIRECTORY | tr '\\' /)
printf "\n📦 Creating sums=[%s], dir=[%s], name=[%s], path=[%s], runner=[%s] ...\n" "$INPUT_TYPE" "$INPUT_DIRECTORY" "$INPUT_FILENAME" "$INPUT_PATH" "$RUNNER_OS"

if [ "$INPUT_DIRECTORY" != "." ] 
then
  cd $INPUT_DIRECTORY
fi

if [ "$INPUT_TYPE" = "sha1" ] || [ "$INPUT_TYPE" = "sha256" ] || [ "$INPUT_TYPE" = "sha512" ] || [ "$INPUT_TYPE" = "md5" ] 
then
  EXCLUSIONS=""
  if [ "$IGNORE_GIT" = "true" ]
  then
    EXCLUSIONS+=" -path ./.git/* -prune -o -path .git/* -prune -o "
  fi
  EXCLUSIONS+=" -not -name $INPUT_FILENAME"
  if [ -n "$INPUT_EXCLUSIONS" ]
  then
    for EXCLUSION in $INPUT_EXCLUSIONS
    do
      EXCLUSIONS+=" -not -name $EXCLUSION"
    done
  fi
  
  # work on windows but not in GH CI # 7z h -scrc$INPUT_TYPE -ba $INPUT_PATH $EXCLUSIONS | awk "OFS=\"\\t\" {printf (\"%s  %s\n\", $1, $3)}" | grep -v "\\ $" > $INPUT_FILENAME
  # work in windows 7z h -scrc$INPUT_TYPE -ba $INPUT_PATH $EXCLUSIONS | awk "OFS=\"\\t\" {printf (\"%s  %s\n\", $1, $3)}" | grep -v "\\ $" > $INPUT_FILENAME    
  # lowercase not working in macOS INPUT_TYPE_L=${INPUT_TYPE,,}
  
  if [ "$RUNNER_OS" = "macOS" ]
  then
    find $INPUT_PATH $EXCLUSIONS -type f -exec shasum -a ${INPUT_TYPE#???} {} \; > $INPUT_FILENAME || { printf "\n⛔ Unable to create %s file.\n" "$INPUT_TYPE"; exit 1;  }
  else
    find $INPUT_PATH $EXCLUSIONS -type f -exec "$INPUT_TYPE"sum {} \; > $INPUT_FILENAME || { printf "\n⛔ Unable to create %s file.\n" "$INPUT_TYPE"; exit 1;  }
  fi
  ARCHIVE_SIZE=$(find . -name $INPUT_FILENAME -printf '(%s bytes) = (%k KB)')
else
  printf "\n⛔ Invalid SHA type.\n"; exit 1;
fi

if [ "$DEBUG_MODE" = "yes" ]
then
  cat $INPUT_FILENAME
fi

FinishTime="$(date -u +%s)"
CrtDate=$(date "+%F^%H:%M:%S")
echo "Finish: " $CrtDate

ElapsedTime=$(( FinishTime - StartTime ))
echo "Elapsed: $ElapsedTime"

printf "\n✔ Successfully created sums=[%s], dir=[%s], name=[%s], path=[%s], size=[%s], runner=[%s] duration=[%ssec]...\n" "$INPUT_TYPE" "$INPUT_DIRECTORY" "$INPUT_FILENAME" "$INPUT_PATH" "$ARCHIVE_SIZE" "$RUNNER_OS" "$ElapsedTime"
if [[ $INPUT_FILENAME =~ ^/ ]]; then
  echo "$INPUT_SUMS_NAME=$INPUT_FILENAME" >> $GITHUB_ENV
else
  echo "$INPUT_SUMS_NAME=$INPUT_DIRECTORY/$INPUT_FILENAME" >> $GITHUB_ENV
fi
