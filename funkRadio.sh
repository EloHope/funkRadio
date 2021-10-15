#!/bin/bash

# funkRadio

# developed for Linux bash shell.

# Please make sure that you have installed the following packages:
# vlc (includes cvlc)
# wget
# mpg123
# ffmpeg (includes volumedetect)
# youtube-dl
# curl
# mp3gain (How to install mp3gain to Debian: https://www.how2shout.com/linux/how-to-install-snap-snap-store-on-debian-11-bullseye-linux/)



# FUNCTIONS: NORMALIZING BROADCAST SOUND VOLUME, DOWNLOADING NEWS BROADCASTS =================================

# First we present functions that will be used in the main part of the script.
# The bits of code for making music playlists, downloading news broadcasts 
# and listening to funkRadio will follow later.

normalize () {
# This function boosts the sound volumes of selected news broadcasts.
# Intermediate results will be located in the /tmp directory:
touch /tmp/temporalis1.txt
touch /tmp/temporalis2.txt
echo "" > /tmp/temporalis1.txt
echo "" > /tmp/temporalis2.txt
# Measuring the original sound volume:
ffmpeg -i $1 -af volumedetect -f null -y nul &> /tmp/temporalis1.txt
# The maximum boost available without distorting sound:
grep "max_volume" /tmp/temporalis1.txt > /tmp/temporalis2.txt
# Obtaining the dB level with which sound will be enhanced
max_available="$(awk -F " " '{print $(NF-1)}' /tmp/temporalis2.txt)"
max_available_rounded="$(echo "$max_available" | awk -F "." '{print $(NF-1)}')"
mar_direction=$(( -1 * max_available_rounded ))
max_available_final="$(echo $mar_direction | awk -F "."  '{print $1}')"
if (( max_available_final > 1 ))
then
    # We don't want to give a boost of more than 6 dB anyway:
    if (( max_available_final > 6 )); then max_available_final=6; fi
    # Sometimes you may be interested in obtaining the bitrate of the broadcast; we do not make use of it here.
    # bitrate=$(ffprobe -v error -show_entries format=bit_rate -of default=noprint_wrappers=1:nokey=1 $1)
    # When using the full script the filename of the news broadcast will be in the variable "$1":
    mp3gain -g -p "${max_available_final}" $1 > /dev/null 2>&1
    base_of_file="$(basename $1)"
    echo "Normalized: ${max_available_final} dB" "$base_of_file" >> ~/funkRadio/Archive/funkRadiolog.txt
fi
}

abcradnatnews () {
# ABC Radio National does not seem to provide news podcasts. 
# That is why we record their next news broadcast - 6 minutes on the hour 
# (more exactly hour + 30 sec for supposed Internet delay).
now_is=$(date +%H); next_hour=$(date -d "$now_is + 1 hour" +'%H:%M:%S'); now_in_seconds=$(date +'%H:%M:%S'); SEC1=$(date +%s -d "${now_in_seconds}"); SEC2=$(date +%s -d "${next_hour}"); DIFFSEC=$(( SEC2 - SEC1 + 30 )); sleep "$DIFFSEC" # for testing just use "sleep 15"
echo "Timer set for recording ABC news. Select additional broadcasts or listen to funkRadio."
now=$(date +%F_%H-%M)
cvlc -q http://live-radio01.mediahubaustralia.com/2RNW/mp3/ --sout file/mp3:/home/$USER/funkRadio/Talk/ABCradnatnews_"$now".mp3 --run-time=360 vlc://quit > /dev/null 2>&1
wait
normalize /home/$USER/funkRadio/Talk/ABCradnatnews_"$now".mp3
echo "ABCradnatnews"_"$now" >> ~/funkRadio/Archive/funkRadiolog.txt
}


abcpm () {
# News magazine available on weekdays after about 7 pm Sydney time.
now=$(date +%F_%H-%M)
wget -q -O ~/funkRadio/Talk/ABCpm_"$now".mp3 $(curl -s https://www.abc.net.au/radio/programs/pm/feed/8863592/podcast.xml | grep -o 'https*://[^"]*mp3' | head -1) > /dev/null 2>&1
echo "ABCpm"_"$now" >> ~/funkRadio/Archive/funkRadiolog.txt
}

bbc4today () {
# A selected part of Today programme of BBC Radio 4. Often about economic news.
now=$(date +%F_%H-%M)
wget -q -O ~/funkRadio/Talk/BBC4today_"$now".mp3 $(curl -s https://podcasts.files.bbci.co.uk/p02nrtvg.rss | grep -o 'https*://[^"]*mp3' | head -1) > /dev/null 2>&1
echo "BBC4today"_"$now" >> ~/funkRadio/Archive/funkRadiolog.txt
}

bbcnews () {
# BBC World Service News - a 5 minute overview of topical events.
echo "Downloading BBC World Service News. Select additional broadcasts or listen to funkRadio."
now=$(date +%F_%H-%M)
addr=$(wget -q -O - https://www.bbc.co.uk/programmes/p002vsmz/episodes/player | grep https://www.bbc.co.uk/sounds/play | grep -o -P '(?<=href=").*(?=")' | head -1) > /dev/null 2>&1
youtube-dl -q --no-warnings -o ~/funkRadio/Talk/BBCnews_"$now" "${addr}" > /dev/null 2>&1
ffmpeg -nostats -loglevel 0 -i ~/funkRadio/Talk/BBCnews_"$now" -acodec libmp3lame -ac 2 -ab 128k -ar 48000 ~/funkRadio/Talk/BBCnews_"$now".mp3 > /dev/null 2>&1
# Old normalization: ffmpeg -i ~/funkRadio/Talk/BBCnews1_"$now".mp3 -af 'volume=2.8' ~/funkRadio/Talk/BBCnews_"$now".mp3 > /dev/null 2>&1
wait
normalize ~/funkRadio/Talk/BBCnews_"$now".mp3
rm ~/funkRadio/Talk/BBCnews_"$now"
}

deutschlandfunk () {
# News from German public radio.
echo "Downloading news from German public radio. Select additional broadcasts or listen to funkRadio."
now=$(date +%F_%H-%M)
wget -q -O ~/funkRadio/Talk/Deutschlandfunk1_"$now".mp3 http://ondemand-mp3.dradio.de/file/dradio/nachrichten/nachrichten.mp3 > /dev/null 2>&1
ffmpeg -ss 3.9 -i ~/funkRadio/Talk/Deutschlandfunk1_"$now".mp3  ~/funkRadio/Talk/Deutschlandfunk_"$now".mp3 > /dev/null 2>&1
# ffmpeg -i ~/funkRadio/Talk/Deutschlandfunk2_"$now".mp3 -af 'volume=1.5' ~/funkRadio/Talk/Deutschlandfunk_"$now".mp3 > /dev/null 2>&1
wait
normalize ~/funkRadio/Talk/Deutschlandfunk_"$now".mp3
rm ~/funkRadio/Talk/Deutschlandfunk1_"$now".mp3
echo "Deutschlandfunk"_"$now" >> ~/funkRadio/Archive/funkRadiolog.txt
# address available at https://de1.api.radio-browser.info/pls/url/9bce1899-bc6e-11e9-acb2-52543be04c81
}

npr () {
# News from U.S. public radio NPR.
echo "Downloading news from NPP. Select additional broadcasts or listen to funkRadio."
now=$(date +%F_%H-%M)
cvlc "http://pd.npr.org/anon.npr-mp3/npr/news/newscast.mp3" --sout file/mp3:/home/"$USER"/funkRadio/Talk/Npr_"$now".mp3 --run-time=300 --stop-time=300 vlc://quit  > /dev/null 2>&1
echo "Npr"_"$now" >> ~/funkRadio/Archive/funkRadiolog.txt
}

sverigesradio () {
# News from Swedish public radio.
echo "Downloading news from Swedish public radio. Select additional broadcasts or listen to funkRadio."
now=$(date +%F_%H-%M)
rimpsu="$(wget -q -O - https://api.sr.se/api/rss/pod/3795 | grep enclosure | head -1)" > /dev/null 2>&1
osoite="$(echo "$rimpsu" | grep -oP '(?<=url=").*(?=" length)')" > /dev/null 2>&1
wget -q -O ~/funkRadio/Talk/Sverigesradio_"$now".mp3 "${osoite}" > /dev/null 2>&1
echo "Sverigesradio"_"$now" >> ~/funkRadio/Archive/funkRadiolog.txt
}

ylepsavo () {
# Local news from Savo region presented by Finnish public broadcaster YLE.
echo "Dowloading news from Savo region in Eastern Finland. Select additional broadcasts or listen to funkRadio."
now=$(date +%F_%H-%M)
wget -q -O ~/funkRadio/Talk/Ylepsavo1_"$now".mp3 $(curl -s https://feeds.yle.fi/areena/v1/series/1-4479312.rss? | grep -o 'https*://[^"]*mp3' | head -1) > /dev/null 2>&1
ffmpeg -ss 3.5 -i ~/funkRadio/Talk/Ylepsavo1_"$now".mp3  ~/funkRadio/Talk/Ylepsavo_"$now".mp3  > /dev/null 2>&1
touch ~/funkRadio/Talk/Ylepsavo_"$now".mp3 # Correcting timestamp.
rm ~/funkRadio/Talk/Ylepsavo1_"$now".mp3
echo "YLE_Savo"_"$now" >> ~/funkRadio/Archive/funkRadiolog.txt
}

yleppohjanmaa () {
# Local news from Pohjanmaa region presented by Finnish public broadcaster YLE.
echo "Dowloading news from Pohjanmaa region in Northern Finland.. Select additional broadcasts or listen to funkRadio."
now=$(date +%F_%H-%M)
wget -q -O ~/funkRadio/Talk/Yleppohjanmaa1_"$now".mp3 $(curl -s https://feeds.yle.fi/areena/v1/series/1-4479456.rss? | grep -o 'https*://[^"]*mp3' | head -1) > /dev/null 2>&1
ffmpeg -ss 3.5 -i ~/funkRadio/Talk/Yleppohjanmaa1_"$now".mp3  ~/funkRadio/Talk/Yleppohjanmaa_"$now".mp3  > /dev/null 2>&1
touch ~/funkRadio/Talk/Yleppohjanmaa_"$now".mp3 # Correcting timestamp.
rm ~/funkRadio/Talk/Yleppohjanmaa1_"$now".mp3
echo "YLE_Pohjanmaa"_"$now" >> ~/funkRadio/Archive/funkRadiolog.txt
}

yleradiosuomi () {
# News from the Finnish public broadcaster YLE.
now=$(date +%F_%H-%M)
wget -q -O ~/funkRadio/Talk/YLE_Radio_Suomi1_"$now".mp3 $(curl -s https://feeds.yle.fi/areena/v1/series/1-1440981.rss? | grep -o 'https*://[^"]*mp3' | head -1) > /dev/null 2>&1
ffmpeg -ss 3.5 -i ~/funkRadio/Talk/YLE_Radio_Suomi1_"$now".mp3 ~/funkRadio/Talk/YLE_Radio_Suomi_"$now".mp3  > /dev/null 2>&1
touch ~/funkRadio/Talk/YLE_Radio_Suomi_"$now".mp3 # Correcting timestamp.
rm ~/funkRadio/Talk/YLE_Radio_Suomi1_"$now".mp3
echo "YLE_Radio_Finland"_"$now" >> ~/funkRadio/Archive/funkRadiolog.txt
}


# MORE FUNCTIONS: SELECT MUSIC DIRECTORY, MAKE PLAYLISTS, PLAY NEWS BROADCASTS & MUSIC =================================

# First, let us select directory which, or its subdirectories contain mp3 files
# that your may want to include in your music playlist.


select_music_directory () {
# Go to the home directory:
cd ~
# Then, type a number to select the corresponding directory:
clear
PS3="Please type number corresponding to directory that contains mp3 music files."
select d in */
do 
  test -n "$d" && break
  echo ">>> Invalid Selection"
done
fav=$PWD/"$d"

IFS= read -re -i "$fav" -p 'Please accept (Enter) or modify (type) the following: ' fav
lastchar=${fav: -1}
if [[ $lastchar != / ]]
then
  fav="$fav"/
fi
echo "Music playlist will be based on "$fav" and its subdirectories."
}

set_song_duration_limit () {
# This function will be launched, if you decide (later along the script)
# that you want to include only songs that are shorter 
# than a set limit. That limit will be set by this function.

echo "Please give maximum duration of songs in minutes."
read max_dur
if [ "$max_dur" -eq "$max_dur" ] 2>/dev/null # Testing if "$max_dur" is a number.
then
  max_dur_sec=$(( 60 * $max_dur ))
else
  echo "Not a number!"
  wait 3
  duration_to_be_limited="No"
fi
}

make_playlist () {

if [[ "$fav" = "" ]]
then
  select_music_directory
else
  echo: "Playlist will be based on the directory $fav. Press 'Enter' if that is OK. Press another key if not."
  read music_dir_decision
  if [[ "$music_dir_decision" != "" ]]
  then
    select_music_directory
  fi
fi

echo "If you want to include songs regardless of duration, press 'Enter'. Press some other key to include only short songs."
read song_dur_decision
if [[ "$song_dur_decision" != "" ]]
then
  duration_to_be_limited="Yes"
  set_song_duration_limit
else
max_dur=""
fi
  

# Next we set keywords that to used in building the playlist: 
# names of music directories, artists etc. identifying our favorite music files.

cd $(dirname "$0") # Go to the directory containing this script.

  number_of_searched_words=0
  search_decision=just_to_get_started
  until [ "${search_decision}" = "start" ]
  do
      echo "Type a keyword (music directory name, artist name etc.) to set up the playlist. Typing keyword 'start' will build the playlist."
      read search_decision
      if [ "${search_decision}" != "start" ]
      then
          searched_words[$number_of_searched_words]="${search_decision}"
          ((number_of_searched_words++))
      fi
  done

  echo "Number of words searched for playlist:" "$number_of_searched_words"
  keywords_for_playlist="$(printf "%s" "${searched_words[@]}")"
  echo "Playlist is based on the following keywords: ${keywords_for_playlist}"
  Playlist="${keywords_for_playlist}.m3u"

  if [ -e "${Playlist}" ]; then echo "" > "${Playlist}"; fi

  for i in "${searched_words[@]}"
  do
    music_descriptor="${i}"
    IFS=$'\n'
    for song in $(find "${fav}" -type f -name "*.mp3" -print | grep -i "${music_descriptor}")
    do
        if [ "$duration_to_be_limited" = "Yes" ]
        then
            song_duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${song}")
            # if (( ${song_duration%.*} <= echo "$max_dur_sec" ))
            if (( ${song_duration%.*} <= "$max_dur_sec" ))
            then
                echo "${song}" >> "${Playlist}"
            fi
        else
          echo "${song}" >> "${Playlist}"
        fi
    done
  done

  if [ -s "${Playlist}" ]
  then
    if [ "$duration_to_be_limited" = "Yes" ]
    then
        filename=$(basename "${Playlist}")
        fname="${filename%.*}"
        mv "${Playlist}" "${fname}_${max_dur}min.m3u"
        Playlist="${fname}_${max_dur}min.m3u"
    fi
    Playlist_lines=$(wc -l "${Playlist}" | awk '{ print $1 }')
    echo "Playlist ${Playlist} has $Playlist_lines lines."
    control_panel
  else
    clear
    echo "${Playlist} is empty."
    make_playlist
  fi
  
}

# The function 'listen_to_the_radio' plays first a random piece of music from the playlist
# and then the oldest news broadcast in the ~/funkRadio/Talk/ directory.
# With Ctrl+C you can switch between music and news and back again.

listen_to_the_radio () {
  cd $(dirname "$0") # Go to the directory containing this script.
  clear
  random_song="$(shuf -n 1 "${Playlist}")"
  random_song_basename=$(basename "${random_song}")
  echo "Now playing ${random_song_basename}"
  echo "${random_song_basename}" >> ~/funkRadio/Archive/funkRadiolog.txt
  mpg123 -C "${random_song}"

  cd /home/$USER/funkRadio/Talk/
  news_broadcast=$(find "/home/$USER/funkRadio/Talk/" -type f -printf '%T+ %f\n' | sort | head -n 1 | cut -d" " -f2)
  if [[ "${news_broadcast}" != "" ]]
  then
    clear
    echo "Now playing ${news_broadcast}"
    mpg123 -C "${news_broadcast}"
    # If you want to archive news broadcasts:
    # mv "${news_broadcast}" /home/"$USER"/funkRadio/Archive/
    # Comment the following out if news broadcasts are archived.
    rm "${news_broadcast}"
    sleep 1
    listen_to_the_radio
  else
    echo "No news broadcasts downloaded yet."
    listen_to_the_radio
  fi
}


# THE CONTROL PANEL OF FUNKRADIO: SELECT BROADCASTS TO BE DOWNLOADED =================================
# AND PLAY FUNKRADIO OR TURN IT OFF =================================

control_panel () {

while true
do
clear
if [ -s "${Playlist}" ]
then
  echo "Music playlist is ${Playlist} - it has $Playlist_lines songs."
else
  echo "Music playlist ${Playlist} is empty. No music will be played."
fi
cat <<- end
1 Get news broadcasts in English and turn the funkRadio on. (Recommended.)
2 ABCnews - will record 6 minutes of ABC Radio National news on the next hour.
3 BBCnews - 5 minute world news from the BBC World Service.
4 NPR - 5 minute news from the U.S. public broadcasting service.
5 Deutschlandfunk - news from the German public broadcasting service in German.
6 Sverigesradio - news from the Swedish public broadcasting service in Swedish.
7 Yleradiosuomi - news from the Finnish public broadcasting service in Finnish.
8 Ylepsavo - regional news from the Northern Savo region in Finnish.
9 Ylepohjanmaa - regional news from the Northern Pohjanmaa region in Finnish.
10 BBC4today - a part of the Today programme of BBC Radio 4.
11 ABCpm - news magazine from the ABC News.
12 Make a new music playlist on the basis of your own keywords.
13 Listen to the funkRadio - listen your favorite songs alternating with news.
14 Turn off funkRadio - quit the script.
end

  echo "Type one of the listed numbers to do what you want."
  read selected_number

  case "$selected_number" in
  "1")
      echo "Playing music while downloading broadcasts"
      ( npr ) &
      ( bbcnews ) &
      ( abcpm ) &
      ( bbc4today ) &
      listen_to_the_radio
      ;;
  "2")
      echo "Setting up timer for the next news from ABC Radio National. Wait a sec before your next move."
      ( abcradnatnews ) &
      ;;
  "3")
      echo "Downloading the latest world news from the BBC. Wait a sec before your next move."
      ( bbcnews ) &
      ;;
  "4")
      echo "News from the U.S. public radio network NPR. Wait a sec before your next move."
      ( npr ) &
      ;;
  "5")
      echo "News from the German public radio Deutschlandfunk. Wait a sec before your next move."
      ( deutschlandfunk ) &
      ;;
  "6")
      echo "News from the Swedisch public broadcaster Sverigesradio. Wait a sec before your next move."
      ( sverigesradio ) &
      ;;
  "7")
      echo "News from the Finnish public broadcaster Yleisradio. Wait a sec before your next move."
      ( yleradiosuomi ) &
      ;;
  "8")
      echo "Regional YLE news from the Northern Savo region. Wait a sec before your next move."
      ( ylepsavo ) &
      ;;
  "9")
      echo "Regional YLE news from the Northern Pohjanmaa region. Wait a sec before your next move."
      ( yleppohjanmaa ) &
      ;;
      
  "10")
      echo "Downloading a part of the Today programme of BBC Radio 4. Wait a sec before your next move."
      ( bbc4today ) &
      ;;
  "11")
      echo "Downloading the news magazine PM from ABC. Available on weekdays. Wait a sec before your next move."
      ( abcpm ) &
      ;;
  "12")
      echo "Next we shall make a new music playlist."
      make_playlist
      ;;
  "13")
      echo "Listen to the funkRadio."
      listen_to_the_radio
      ;;
  "14")
      echo "funkRadio was turned off."
      exit
      ;;
  *) echo "Invalid option."
      ;;
  esac
done
}


# THE MAIN PART OF THE SCRIPT - USER INTERACTIONS START HERE =================================


clear
cd $(dirname "$0") # Go to the directory containing this script.
echo "Press Enter to launch funkRadio. Press other keys to quit."
read launch_decision
if [ "$launch_decision" != "" ]
then
    exit
else
    fav=""
    number_of_broadcasts=$(find ~/funkRadio/Talk/ -type f -name "*.mp3" | wc -l)
    if [ "$number_of_broadcasts" -gt 0 ]
    then
        echo "$number_of_broadcasts broadcasts available. Press Enter to archive them. Press another key to keep them for listening."
        read archive_decision
        if [ "$archive_decision" = "" ]
        then
            find ~/funkRadio/Talk/ -type f -name "*.mp3" -exec mv {} ~/funkRadio/Archive/ \;
            echo "Items were moved to the Archive directory."
        else
            echo "$number_of_broadcasts broadcasts available."
        fi
    fi
fi

clear
cd $(dirname "$0") # Go to the directory containing this script.
declare -a array_of_playlists
for plist in $(find . -maxdepth 1 -name "*.m3u")
do
  array_of_playlists=("${array_of_playlists[@]}" "$plist")
done

if [ ${#array_of_playlists[@]} -eq 0 ]
then
  make_playlist
else
  clear
  echo "${#array_of_playlists[@]} playlists are available."
  PS3='Type a number to select playlist. Type 0 to make a new playlist.'
  select Playlist in "${array_of_playlists[@]}"
  do
    if [[ $REPLY == "0" ]]
    then
        make_playlist
    else
        break
    fi
  done
  echo "The chosen playlist was" "$REPLY" "${Playlist}"
  Playlist_lines=$(wc -l "${Playlist}" | awk '{ print $1 }')
  echo "Music playlist is ${Playlist} - it has $Playlist_lines songs."
  control_panel
fi

# ~/funkRadio/funkRadio.sh
