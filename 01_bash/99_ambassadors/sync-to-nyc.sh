#!/usr/bin/env bash

# while IFS='' read -r projectname || [[ -n "$projectname" ]]; do

while read projectname; do

  if [[ "$projectname" = PHILIPS*_p* ]]; then
    brandtest="phil"
  elif [[ "$projectname" = BOOKING*_p* ]]; then
    brandtest="book"
  else
    brandtest="false"
  fi

  projectyear=$(echo "$projectname" | sed 's/^.*_p//;s/[0-9]\{5\}$//')

  echo "Syncing $projectname"
  # echo $brandtest
  # echo $projectyear

# # # # # # # # # # # #
# SYNC TO NYC OFFICE  #
# # # # # # # # # # # #

  # rsync -azvh /ODIN/_WORK/"$projectname" /Volumes/FREYA/VFX/WORK/

  if [[ $brandtest == "phil" ]]; then
     rsync -azvh /AMBASSADORS_SHARED/PROJECTS/PHILIPS/"$projectname" /Volumes/FREYA/PROJECTS/BRANDS/PHILIPS/
  elif [[ $brandtest == "book" ]]; then
     rsync -azvh /AMBASSADORS_SHARED/PROJECTS/"$projectname" /Volumes/FREYA/PROJECTS/BRANDS/BOOKING/
  else
     rsync -azvh /AMBASSADORS_SHARED/PROJECTS/"$projectname" /Volumes/FREYA/PROJECTS/BRANDS/AGENCIES/
  fi

# # # # # # # # # # # #
# SYNC TO AMS OFFICE  #
# # # # # # # # # # # #

if [[ $brandtest == "phil" ]]; then
   rsync -azvh /Volumes/FREYA/PROJECTS/BRANDS/PHILIPS/"$projectname" /AMBASSADORS_SHARED/PROJECTS/PHILIPS/
elif [[ $brandtest == "book" ]]; then
   rsync -azvh /Volumes/FREYA/PROJECTS/BRANDS/BOOKING/"$projectname" /AMBASSADORS_SHARED/PROJECTS/
else
   rsync -azvh /Volumes/FREYA/PROJECTS/BRANDS/AGENCIES/"$projectname" /AMBASSADORS_SHARED/PROJECTS/
fi

if [[ "$projectyear" != 18 ]]; then
  if [[ -d /Volumes/FREYA/FINALS/p"$projectyear"/"$projectname" ]] && [[ -d /ODIN/LIBRARY/pFINALS/p"$projectyear"/"$projectname" ]]; then
    rsync -azvh /Volumes/FREYA/FINALS/p"$projectyear"/"$projectname" /ODIN/LIBRARY/pFINALS/p"$projectyear"/
  fi
else
  if [[ -d /Volumes/FREYA/FINALS/p"$projectyear"/"$projectname" ]] && [[ -d /ODIN/LIBRARY/pFINALS/"$projectname" ]]; then
    rsync -azvh /Volumes/FREYA/FINALS/p"$projectyear"/"$projectname" /ODIN/LIBRARY/pFINALS/
  fi
fi
done < /AMBASSADORS_SHARED/STUDIO/sync-to-nyc.txt