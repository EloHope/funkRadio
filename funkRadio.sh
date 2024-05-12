#!/bin/bash

# funkRadio

# developed for Linux bash shell.

# Please make sure that you have installed the following packages:
# - vlc (includes cvlc)
# - wget
# - mpg123
# - ffmpeg (version 4.4 or higher includes speechnorm filter, but
# funkRadio runs OK even without that particular filter)
# - yt-dlp (instead of  youtube-dl)
# - curl
# - shuf (in most distributions, you can get it by installing 'coreutils')
# - bc (for calculations)


# Install ffmpeg 4.4 on Ubuntu with ppa:
# https://ubuntuhandbook.org/index.php/2021/05/install-ffmpeg-4-4-ppa-ubuntu-20-04-21-04/
# Install ffmpeg 4.4 on Debian, Ubuntu and other distributions:
# https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu


# =================================
 
# FUNCTIONS: DOWNLOADING NEWS BROADCASTS AND NORMALIZING BROADCAST SOUND VOLUME IN SOME CASES

# First we present functions that will be used in the main part of the script.
# The bits of code for making music playlists, downloading news broadcasts 
# and listening to funkRadio will follow later.

# =================================

speech_norm_test () {
# Testing if speechnorm filter is available. It is available in ffmpeg version 4.4. and higher.
speechtest="$(ffmpeg -v quiet -filters | grep -i speechnorm)" > /dev/null 2>&1
if [[ "$speechtest" == *"speechnorm"* ]]
then 
	speechresult="Yes"
else 
	speechresult="No" 
fi
}

abcradnatnews () {
trap '' 2  # Disable Ctrl + C for this function.
# ABC Radio National seems not to provide news podcasts. 
# That is why we record their next news broadcast for 6 minutes. 
# (On the hour + estimated Internet delay).
echo "Timer set for recording ABC news. Select additional broadcasts or listen to funkRadio."
( now_is=$(date +%H); next_hour=$(date -d "$now_is + 1 hour" +'%H:%M:%S'); now_in_seconds=$(date +'%H:%M:%S'); SEC1=$(date +%s -d "${now_in_seconds}"); SEC2=$(date +%s -d "${next_hour}"); DIFFSEC=$(( SEC2 - SEC1 + 15 )); sleep "$DIFFSEC" ) &
# sleep "$DIFFSEC" ) &
# for testing: sleep 30 ) &
until wait;do :;done # Because of trapping Ctrl + C; see https://superuser.com/questions/1719758/bash-script-to-catch-ctrlc-at-higher-level-without-interrupting-the-foreground
now=$(date +%F_%H-%M)
cvlc -q http://live-radio01.mediahubaustralia.com/2RNW/mp3/ --sout file/mp3:/home/$USER/funkRadio/Talk/ABCradnatnews1_"$now" --run-time=360 vlc://quit > /dev/null 2>&1
if [[ $speechresult = "Yes" ]]
then
	# ffmpeg speechnorm normalization: default value is speechnorm=p=0.95.
	ffmpeg -i /home/$USER/funkRadio/Talk/ABCradnatnews1_"$now" -filter:a speechnorm=p=0.95 /home/$USER/funkRadio/Talk/ABCradnatnews_"$now".mp3 > /dev/null 2>&1
else
	ffmpeg -i /home/$USER/funkRadio/Talk/ABCradnatnews1_"$now" -af 'volume=2.1' /home/$USER/funkRadio/Talk/ABCradnatnews_"$now".mp3 > /dev/null 2>&1
fi
rm /home/$USER/funkRadio/Talk/ABCradnatnews1_"$now"
echo "ABCradnatnews"_"$now" >> ~/funkRadio/Archive/funkRadiolog.txt
}


abcpm () {
# News magazine available on weekdays after about 7 pm Sydney time.
now=$(date +%F_%H-%M)
wget -q -O ~/funkRadio/Talk/ABCpm1_"$now".mp3 $(curl -s https://www.abc.net.au/radio/programs/pm/feed/8863592/podcast.xml | grep -o 'https*://[^"]*mp3' | head -1) > /dev/null 2>&1
wait
ffmpeg -i ~/funkRadio/Talk/ABCpm1_"$now".mp3 ~/funkRadio/Talk/ABCpm_"$now".mp3 > /dev/null 2>&1
rm ~/funkRadio/Talk/ABCpm1_"$now".mp3
echo "ABCpm"_"$now" >> ~/funkRadio/Archive/funkRadiolog.txt
}


bbc4news_briefing () {
# A concise daily briefing available at about 7 am London time.
echo "Downloading BBC Radio 4 News Briefing. Select additional broadcasts or listen to funkRadio."
now=$(date +%F_%H-%M)
addr=$(wget -q -O - https://www.bbc.co.uk/programmes/b007rhyn/episodes/player | grep https://www.bbc.co.uk/sounds/play | grep -o -P '(?<=href=").*(?=")' | head -1) > /dev/null 2>&1
yt-dlp -x --audio-format mp3 -o ~/funkRadio/Talk/bbc4news_briefing_"$now" "${addr}" > /dev/null 2>&1
ffmpeg -nostats -loglevel 0 -i ~/funkRadio/Talk/bbc4news_briefing_"$now" -acodec libmp3lame -ac 2 -ab 128k -ar 48000 ~/funkRadio/Talk/bbc4news_briefing_"$now".mp3 > /dev/null 2>&1
rm ~/funkRadio/Talk/bbc4news_briefing_"$now"
}

bbcnews () {
# BBC World Service News - a 5 minute overview of topical events.
echo "Downloading BBC World Service News. Select additional broadcasts or listen to funkRadio."
now=$(date +%F_%H-%M)
addr=$(wget -q -O - https://www.bbc.co.uk/programmes/p002vsmz/episodes/player | grep https://www.bbc.co.uk/sounds/play | grep -o -P '(?<=href=").*(?=")' | head -1) > /dev/null 2>&1
yt-dlp -x --audio-format mp3 -o ~/funkRadio/Talk/BBCnews_"$now" "${addr}" > /dev/null 2>&1
ffmpeg -nostats -loglevel 0 -i ~/funkRadio/Talk/BBCnews_"$now" -acodec libmp3lame -ac 2 -ab 128k -ar 48000 ~/funkRadio/Talk/BBCnews1_"$now".mp3 > /dev/null 2>&1
if [[ $speechresult = "Yes" ]]
then
	# ffmpeg speechnorm normalization: default value is speechnorm=p=0.95.
	ffmpeg -i ~/funkRadio/Talk/BBCnews1_"$now".mp3 -filter:a speechnorm=p=0.93 ~/funkRadio/Talk/BBCnews_"$now".mp3 > /dev/null 2>&1
else
	ffmpeg -i ~/funkRadio/Talk/BBCnews1_"$now".mp3 -af 'volume=2.8' ~/funkRadio/Talk/BBCnews_"$now".mp3 > /dev/null 2>&1
fi
rm ~/funkRadio/Talk/BBCnews_"$now"
rm ~/funkRadio/Talk/BBCnews1_"$now".mp3
}

deutschlandfunk () {
# News from the German public radio.
echo "Downloading news from German public radio. Select additional broadcasts or listen to funkRadio."
now=$(date +%F_%H-%M)
wget -q -O ~/funkRadio/Talk/Deutschlandfunk1_"$now" http://ondemand-mp3.dradio.de/file/dradio/nachrichten/nachrichten.mp3 > /dev/null 2>&1
# Removing loud station identifications from the beginning and the end of the file.
news_de_duration_original=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 ~/funkRadio/Talk/Deutschlandfunk1_"$now")
news_de_duration_trimmed=$(echo "$news_de_duration_original - 9.0 - 3.9" | bc -l | awk '{ printf("%.1f\n",$1) '})
news_de_duration_trimmed=${news_de_duration_trimmed//,/.} # Replace comma with dot. Debian-based systems may need this.
ffmpeg -ss 3.9 -i ~/funkRadio/Talk/Deutschlandfunk1_"$now" -t ${news_de_duration_trimmed} ~/funkRadio/Talk/Deutschlandfunk2_"$now".mp3 > /dev/null 2>&1
if [[ $speechresult = "Yes" ]]
then
	# ffmpeg speechnorm normalization: default value is speechnorm=p=0.95.
	ffmpeg -i ~/funkRadio/Talk/Deutschlandfunk2_"$now".mp3 -filter:a speechnorm=p=0.90 ~/funkRadio/Talk/Deutschlandfunk_"$now".mp3 > /dev/null 2>&1
else
	ffmpeg -i ~/funkRadio/Talk/Deutschlandfunk2_"$now".mp3 -af 'volume=1.4' ~/funkRadio/Talk/Deutschlandfunk_"$now".mp3 > /dev/null 2>&1
fi
rm ~/funkRadio/Talk/Deutschlandfunk1_"$now"
rm ~/funkRadio/Talk/Deutschlandfunk2_"$now".mp3
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
addr_in_haystack="$(curl -s -r 2000-3000 https://feeds.yle.fi/areena/v1/series/1-4479312.rss? )" > /dev/null 2>&1; addr2="$(echo "${addr_in_haystack}" | grep -o 'url=.*" type' | head -1)" > /dev/null 2>&1; addr2="${addr2//\" type}"; addr2="${addr2//\url=\"}"; wget -q -O ~/funkRadio/Talk/Ylepsavo1_"$now".mp3 "$addr2" > /dev/null 2>&1
# Removing a too loud station identification from the beginning of the file.
ffmpeg -ss 3.5 -i ~/funkRadio/Talk/Ylepsavo1_"$now".mp3 ~/funkRadio/Talk/Ylepsavo_"$now".mp3  > /dev/null 2>&1
# touch ~/funkRadio/Talk/Ylepsavo_"$now".mp3 # Correcting timestamp.
rm ~/funkRadio/Talk/Ylepsavo1_"$now".mp3
echo "YLE_Savo"_"$now" >> ~/funkRadio/Archive/funkRadiolog.txt
}

yleppohjanmaa () {
# Local news from Pohjanmaa region presented by Finnish public broadcaster YLE.
echo "Dowloading news from Pohjanmaa region in Northern Finland.. Select additional broadcasts or listen to funkRadio."
now=$(date +%F_%H-%M)
addr_in_haystack="$(curl -s -r 2000-3000 https://feeds.yle.fi/areena/v1/series/1-4479456.rss?)" > /dev/null 2>&1; addr2="$(echo "${addr_in_haystack}" | grep -o 'url=.*" type' | head -1)" > /dev/null 2>&1; addr2="${addr2//\" type}"; addr2="${addr2//\url=\"}"; wget -q -O ~/funkRadio/Talk/Yleppohjanmaa1_"$now".mp3 "$addr2" > /dev/null 2>&1
# Removing a too loud station identification from the beginning of the file.
ffmpeg -ss 3.5 -i ~/funkRadio/Talk/Yleppohjanmaa1_"$now".mp3 ~/funkRadio/Talk/Yleppohjanmaa_"$now".mp3  > /dev/null 2>&1
# touch ~/funkRadio/Talk/Yleppohjanmaa_"$now".mp3 # Correcting timestamp.
rm ~/funkRadio/Talk/Yleppohjanmaa1_"$now".mp3
echo "YLE_Pohjanmaa"_"$now" >> ~/funkRadio/Archive/funkRadiolog.txt
}

yleradiosuomi () {
# News from the Finnish public broadcaster YLE.
now=$(date +%F_%H-%M)
addr_in_haystack="$(curl -s -r 2000-3000 https://feeds.yle.fi/areena/v1/series/1-1440981.rss?)" > /dev/null 2>&1; addr2="$(echo "${addr_in_haystack}" | grep -o 'url=.*" type' | head -1)" > /dev/null 2>&1; addr2="${addr2//\" type}"; addr2="${addr2//\url=\"}"; wget -q -O ~/funkRadio/Talk/YLEradiosuomi1_"$now".mp3 "$addr2" > /dev/null 2>&1
ffmpeg -ss 3.5 -i ~/funkRadio/Talk/YLEradiosuomi1_"$now".mp3 ~/funkRadio/Talk/YLEradiosuomi_"$now".mp3 > /dev/null 2>&1
# touch ~/funkRadio/Talk/YLE_Radio_Suomi_"$now".mp3 # Correcting timestamp.
rm ~/funkRadio/Talk/YLEradiosuomi1_"$now".mp3
echo "YLE_Radio_Finland"_"$now" >> ~/funkRadio/Archive/funkRadiolog.txt
}

# =================================
# PLAY NEWS BROADCASTS & MUSIC

# The function 'listen_to_the_radio' plays first a random piece of music from the playlist
# and then a news broadcast in the ~/funkRadio/Talk/ directory.
# With Ctrl+C you can t betweeen music and news. Ctrl+Z stops the program.

listen_to_the_radio () {
  cd $(dirname "$0") # Go to the directory containing this script.
	if [ "$timer_on" = "Yes" ]
	then 
		val1=$(date --date=$timer_limit +%s)
		val2=$(date +%s)
		if [ $val1 -gt $val2 ]
		then 
			:
		else
			echo "Stopped after time limit $timer_limit_readable was exceeded."
			exit 0
		fi
	fi
  
  # clear
  if [[ "$skip_music_decision" = "No" ]]
  then
		random_song="$(shuf -n 1 "${Playlist}")"
		random_song_basename=$(basename "${random_song}")
		echo "Now playing ${random_song_basename}"
		echo "${random_song}" >> ~/funkRadio/Archive/funkRadiolog.txt
		mpg123 -C "${random_song}" # With '-vC' mpg123 controls might actually work, but with additional screen output
	else
	  if [ -e "$HOME/funkRadio/ocean_wave.mp3" ]
	  then
			mpg123 -C "$HOME/funkRadio/ocean_wave.mp3"
		else
		  sleep 2
		fi
  fi
  
  declare -a array_of_news_broadcasts
  for news in $(find /home/$USER/funkRadio/Talk/ -maxdepth 1 -name "*.mp3")
  do
    array_of_news_broadcasts=("${array_of_news_broadcasts[@]}" "${news}")
  done

  if [ ${#array_of_news_broadcasts[@]} -eq 0 ]
  then
    if [[ "$skip_music_decision" = "Yes" ]]
		then
		  byebye=$(date +'%A %H:%M')
			echo "No downloaded broadcast or music playlist was available. Stopped at $byebye."
			exit 0
		else
    listen_to_the_radio
    fi
  else
  sleep 1
  # first_news_broadcast="$(find /home/$USER/funkRadio/Talk/ -type f -printf '%T+ %f\n' | sort | head -n 1 | cut -d" " -f2)"
  a_news_broadcast="${array_of_news_broadcasts[0]}"
  mpg123 -C "${a_news_broadcast}" # With '-vC' mpg123 controls might actually work, but with additional screen output
  # If you want to archive news broadcasts for later inspection:
    # mv "${a_news_broadcast}" /home/"$USER"/funkRadio/Archive/
    # Comment the following out if news broadcasts are archived.
    rm "${a_news_broadcast}"
    sleep 1
    listen_to_the_radio  
  fi
}

# =================================
# THE CONTROL PANEL OF FUNKRADIO: SELECT BROADCASTS TO BE DOWNLOADED,
# PLAY FUNKRADIO, OR TURN IT OFF
# =================================

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
if [ "$timer_on" = "Yes" ]; then echo "Time limit is set at $timer_limit_readable."; fi
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
10 BBC Radio 4 News Briefing - A 13 minute news summary available at about 7 am London time.
11 ABCpm - news magazine from the ABC News.
12 Listen to the funkRadio - listen your favorite songs alternating with news.
13 Turn funkRadio off - quit the script.
end

  echo "Type one of the listed numbers to do what you want."
  read selected_number

  case "$selected_number" in
  "1")
      echo "Playing music while downloading broadcasts"
			( bbc4news_briefing ) &
      ( npr ) &
      ( bbcnews ) &
      ( abcpm ) &
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
      echo "Downloading BBC Radio 4 News Briefing. Wait a sec before your next move."
      ( bbc4news_briefing ) &
      ;;
  "11")
      echo "Downloading the news magazine PM from ABC. Available on weekdays. Wait a sec before your next move."
      ( abcpm ) &
      ;;
  "12")
      echo "Listen to the funkRadio."
      listen_to_the_radio
      ;;
  "13")
      echo "funkRadio was turned off."
      exit
      ;;
  *) echo "Invalid option."
      ;;
  esac
done
}


# =================================
# THE MAIN PART OF THE SCRIPT - USER INTERACTIONS START HERE
# =================================

clear
cd $(dirname "$0") # Go to the directory containing this script.
echo "Press 'Enter' to launch funkRadio. Press other keys to quit."
read launch_decision
if [ "$launch_decision" != "" ]
then
    exit
else
    fav=""
    number_of_broadcasts=$(find ~/funkRadio/Talk/ -type f -name "*.mp3" | wc -l)
    if [ "$number_of_broadcasts" -gt 0 ]
    then
        echo "$number_of_broadcasts broadcasts available; press 'Enter' to remove them. Press other keys + 'Enter' to keep them for listening."
        read remove_decision
        if [ "$remove_decision" = "" ]
        then
            find ~/funkRadio/Talk/ -type f -name "*.mp3" -exec rm {} \;
            # Taking this opportunity to delete blank lines from funkRadiolog.txt:
            sed -i '/^[[:space:]]*$/d' ~/funkRadio/Archive/funkRadiolog.txt
        else
            echo "$number_of_broadcasts broadcasts available."
        fi
    fi
fi

speech_norm_test

# Select this option if you only want hear news, not music.
echo "If you only want hear news, not music, please press 'Enter'. Otherwise, press other keys and Enter."
read skip_decision
if [[ "$skip_decision" = "" ]]
then
	skip_music_decision="Yes"
else
	skip_music_decision="No"
	
	echo "If you want a timer to switch off funkRadio, please give a time limit in minutes. Otherwise, press 'Enter'."
	read timer
	if [ "$timer" -eq "$timer" ] 2>/dev/null # Testing if "$timer" is a number.
	then
		timer_now=$(date --iso-8601=seconds) 
		timer_limit=$(date -d "$timer_now + ${timer} minutes" --iso-8601=seconds)
		timer_limit_readable="$(date -d "$timer_limit" +'%T')"
		timer_on="Yes"
	else
		echo "Not a number. No time limit to listening!."
		timer_on="No"
	fi
fi



clear
cd $(dirname "$0") # Go to the directory containing this script.

if [[ "$skip_music_decision" = "No" ]]
then
	declare -a array_of_playlists
	for plist in $(find . -maxdepth 1 -name "*.m3u")
	do
		array_of_playlists=("${array_of_playlists[@]}" "$plist")
	done

	if [ ${#array_of_playlists[@]} -eq 0 ]
	then
		echo "No playlists of the format m3u available in directory ~/funkRadio."
		exit
  else
		clear
		echo "${#array_of_playlists[@]} playlists are available."
		PS3='Type a number to select playlist.'
		select Playlist in "${array_of_playlists[@]}"
		do
			if [[ $REPLY == "0" ]]
			then
					:
			else
					break
			fi
		done
		echo "The chosen playlist was" "$REPLY" "${Playlist}"
		Playlist_lines=$(wc -l "${Playlist}" | awk '{ print $1 }')
		echo "Music playlist is ${Playlist} - it has $Playlist_lines songs."
		control_panel
	fi
fi
control_panel

# Script location: ~/funkRadio/funkRadio.sh
