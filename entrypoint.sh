#! /bin/bash
# 2023-06-18 20:30

# Create sha sums or exit if command fails
#set -euf
if [ "$DEBUG_MODE" = "yes" ]
then
  set -x
fi

printf "\n📦 Creating sums=[%s], dir=[%s], name=[%s], path=[%s], runner=[%s] ...\n" "$INPUT_TYPE" "$INPUT_DIRECTORY" "$INPUT_FILENAME" "$INPUT_PATH" "$RUNNER_OS"

if [ "$INPUT_DIRECTORY" != "." ] 
then
  cd $INPUT_DIRECTORY
fi

if [ "$INPUT_TYPE" = "sha1" ] || [ "$INPUT_TYPE" = "sha256" ] || [ "$INPUT_TYPE" = "sha512" ] || [ "$INPUT_TYPE" = "md5" ] 
then
  if [ "$RUNNER_OS" = "Windows" ]
  then
    EXCLUSIONS=" -x!"
    EXCLUSIONS+="$INPUT_FILENAME"
    if [ -n "$INPUT_EXCLUSIONS" ] || [ -n "$INPUT_RECURSIVE_EXCLUSIONS" ]
    then 
      for EXCLUSION in $INPUT_EXCLUSIONS
      do
        EXCLUSIONS+=" -x!"
        EXCLUSIONS+="$EXCLUSION"
      done
      for EXCLUSION in $INPUT_RECURSIVE_EXCLUSIONS
      do
        EXCLUSIONS+=" -xr!"
        EXCLUSIONS+="$EXCLUSION"
      done
    fi
    # 7z h -scrcSHA256 -xr!LICENSE -x!_sha_sums_tmp_ * >_sha_sums_tmp_
    # 7z h -scrc$INPUT_TYPE $INPUT_PATH $EXCLUSIONS >_sha_sums_tmp_ || { printf "\n⛔ Unable to create %s file.\n" "$INPUT_TYPE"; exit 1;  }
    # work on windows but not in GH CI # 7z h -scrc$INPUT_TYPE -ba $INPUT_PATH $EXCLUSIONS | awk "OFS=\"\\t\" {printf (\"%s  %s\n\", $1, $3)}" | grep -v "\\ $" > $INPUT_FILENAME
    # 7z h -scrc"$INPUT_TYPE" -ba $INPUT_PATH $EXCLUSIONS | awk "{printf (\"%s  %s\n\", $1, $3)}" | grep -v "\\  $" | grep -v "\\ $" | grep -v "\\$" > $INPUT_FILENAME || { printf "\n⛔ Unable to create %s file.\n" "$INPUT_TYPE"; exit 1;  }
    # 7z h -scrc"$INPUT_TYPE" -ba $INPUT_PATH $EXCLUSIONS > $INPUT_FILENAME.tmp || { printf "\n⛔ Unable to create %s file.\n" "$INPUT_TYPE"; exit 1;  }
    7z h -scrc"$INPUT_TYPE" -ba $INPUT_PATH $EXCLUSIONS | grep -v "\\[ ]$" | awk "{printf (\"%s  %s\n\", \$1, \$3)}" > "$INPUT_FILENAME" || { printf "\n⛔ Unable to create %s file.\n" "$INPUT_TYPE"; exit 1;  }
  elif [ "$RUNNER_OS" = "macOS" ]
  then
    EXCLUSIONS=" -not -name $INPUT_FILENAME"
    if [ -n "$INPUT_EXCLUSIONS" ]
    then
      for EXCLUSION in $INPUT_EXCLUSIONS
      do
        EXCLUSIONS+=" -not -name "
        EXCLUSIONS+="$EXCLUSION"
      done
    fi
    # work on windows but not in GH CI # 7z h -scrc$INPUT_TYPE -ba $INPUT_PATH $EXCLUSIONS | awk "OFS=\"\\t\" {printf (\"%s  %s\n\", $1, $3)}" | grep -v "\\ $" > $INPUT_FILENAME
    # INPUT_TYPE_L=${INPUT_TYPE,,}
    find $INPUT_PATH -type f $EXCLUSIONS -exec shasum -a ${INPUT_TYPE#???} {} \; > $INPUT_FILENAME || { printf "\n⛔ Unable to create %s file.\n" "$INPUT_TYPE"; exit 1;  }
  else
    EXCLUSIONS=" -not -name $INPUT_FILENAME"
    if [ -n "$INPUT_EXCLUSIONS" ]
    then
      for EXCLUSION in $INPUT_EXCLUSIONS
      do
        EXCLUSIONS+=" -not -name "
        EXCLUSIONS+="$EXCLUSION"
      done
    fi
    # 7z h -scrc$INPUT_TYPE -ba $INPUT_PATH $EXCLUSIONS | awk "OFS=\"\\t\" {printf (\"%s  %s\n\", $1, $3)}" | grep -v "\\ $" > $INPUT_FILENAME
    # INPUT_TYPE_L=${INPUT_TYPE,,}
    find $INPUT_PATH -type f $EXCLUSIONS -exec "$INPUT_TYPE"sum {} \; > $INPUT_FILENAME || { printf "\n⛔ Unable to create %s file.\n" "$INPUT_TYPE"; exit 1;  }
  fi
else
  printf "\n⛔ Invalid SHA type.\n"; exit 1;
fi

if [ "$DEBUG_MODE" = "yes" ]
then
  cat $INPUT_FILENAME
fi
printf "\n✔ Successfully created sums=[%s], dir=[%s], name=[%s], path=[%s], runner=[%s] ...\n" "$INPUT_TYPE" "$INPUT_DIRECTORY" "$INPUT_FILENAME" "$INPUT_PATH" "$RUNNER_OS"
echo "SHA_SUMS=$INPUT_FILENAME" >> $GITHUB_ENV
