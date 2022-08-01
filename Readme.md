# funkRadio - world news and your favorite music

Listening to radio is a relaxing way to keep yourself up to date with world events. However, broadcast radio cannot take into account individual music preferences. So sooner or later we turn the radio off. 

This project presents a Linux bash shell script that combines up-to-date international news and your favorite music.

The script is called funkRadio. It downloads and plays news broadcasts from reputable radio stations. Music comes by the courtesy of your own mp3 files.

## Setting up the funkRadio service

The funkRadio.sh script has been tested in Arch Linux, Debian and Ubuntu environments. Other Linux distributions are probably OK as long as they include these packages:

- vlc (includes cvlc)
- wget
- mpg123
- ffmpeg (version 4.4 or higher includes speechnorm filter, but
funkRadio runs OK even without that particular filter))
- youtube-dl
- curl
- shuf
- bc (for calculations)

Please check that you have these packages and install if necessary.

Then, please create new directories in your home directory
by typing on the terminal:

	mkdir ~/funkRadio ~/funkRadio/Archive ~/funkRadio/Talk 

Then download or copy the script funkRadio.sh and place it in the folder ~funk/Radio. Activate the script with the command 

	chmod u+x  ~/funkRadio/funkRadio.sh

Then, create a log file:

	touch ~/funkRadio/Archive/funkRadiolog.txt

Also copy the sound file called ocean_wave.mp3 to the ~/funkRadio/ directory. This ten-second file precedes the first news broadcast when you listen to funkRadio. It is also played between the broadcasts if you have selected not to play music during your listening session. If you do not want to have ocean_wave.mp3 file in your system, it will be replaced by two seconds of silence.

If you already have a music playlist of the m3u format, please place a copy of it in the folder ~/funkRadio/. In this case you will not need to make a playlist when you launch funkRadio for the first time. However, please note that the playlist should be only a list of files, such as

/home/your_username/Musiikki/Reggae/Misty in Roots/Roots Controller/How Long Jah.mp3
/home/your_username/Musiikki/Reggae/Misty in Roots/Roots Controller/Dance Hall Babylon.mp3
/home/your_username/Musiikki/Reggae/Misty in Roots/Roots Controller/True Rasta.mp3
/home/your_username/Musiikki/Reggae/Misty in Roots/Roots Controller/New Day.mp3
/home/your_username/Musiikki/Reggae/Misty in Roots/Roots Controller/Ghetto Of The City (Live).mp3
/home/your_username/Musiikki/Reggae/Misty in Roots/Roots Controller/Cover Up.mp3
/home/your_username/Musiikki/Reggae/Misty in Roots/Live At Town and Country Club London 1991.mp3

This is because we use the 'mpg123' music player, and it does not accept playlists created with e.g., VLC.



## Lauching funkRadio and making a music playlist

If there is no music playlist available, please check in which directory you have your mp3 files (usually ~/Music). It is OK if your mp3 files are in subdirectories. 

funkRadio is launched by typing on the terminal

	~/funkRadio/funkRadio.sh

Just to make sure that you want to launch the program, you are asked to press 'Enter'.

Then you are presented with an option to skip music altogether and only listen to news broadcasts. If you do not want to listen to music in this session, press 'Enter' in reply. Otherwise, press other keys and then 'Enter'.

You can set a time limit after which funkRadio is turned off. Give the time limit in minutes and press 'Enter'. When the time limit is reached, any ongoing piece of news or music is played in full, and only after that funkRadio is turned off. This option is convenient if, for instance, you want to use funkRadio as an aid to go to sleep.

If there is no music playlist in the directory ~/funkRadio/, the script helps you to create one. First, it will ask you to select a directory that contains mp3 files. (The mp3 files can be in subdirectories as well.)

The script helps you to select an appropriate directory by listing folders with an assigned number. You can select a directory by typing the number associated with it. And then, of course, press 'Enter' once again.

Perhaps you want to include only relatively short songs? You can set a time limit for song duration if you choose that option. Set the limit in minutes.

The last stage in preparing the playlist is to type one keyword at a time for listing those mp3 files that will be included in the playlist. You can add keywords one by one after you press Enter.

The making of the playlist is started when you type 'start' (and 'Enter') instead of another keyword.

When the playlist is ready, your terminal will show you the funkRadio control panel.


## funkRadio Control Panel

The control panel presents a number of actions and associated numbers used to select those actions.

You can select a station from which the latest news broadcast will be downloaded. Try option '1' - it downloads some news broadcasts in English.

After having selected stations, you can start a listening session by selecting option '13 Listen to the funkRadio'.

While listening, you can toggle  between music and news by typing 'Ctrl + C'. 

You can turn the radio off by typing 'CTRL + Z'. The command sends the program to the background.
Or you can select the last option on the control panel.

### Additional information

You may be interested to know that the 'ocean_wave.mp3' file has been generated by using the following formula:

	sox -n "$HOME/funkRadio/ocean_wave.mp3" synth brownnoise synth pinknoise mix synth 0 0 0 10 10 40 trapezium amod 0.1 30 fade h 0 16 3

To use the formula, please install 'sox' first. The file has been further edited with Audacity. The formula was copied from https://askubuntu.com/questions/789465/generate-white-noise-to-calm-a-baby

Below are some links demonstrating other ways to to work with podcasts on command line.

A script for downloading podcasts:
https://github.com/ellencubed/bashpodder

Another script for downloading podcasts:
https://github.com/MiguSchweiz/bcaster/blob/master/bcaster

A highly polished script for downloading podcasts:
https://github.com/oyvindstegard/podsh/blob/master/podsh
#######
