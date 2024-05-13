# FunkRadio: Your Personalized International News and Music Station

FunkRadio is a Linux bash script that brings together up-to-date international news and your favorite music. It's a laid-back way to keep yourself informed about world events while enjoying music you really prefer.

Please note that InfRadio is a script that goes on playing music and up-to-date news indefinitely: https://github.com/EloHope/infRadio

## Setup

The `funkRadio.sh` script has been tested in Arch Linux, Debian, and Ubuntu environments. It should work on other Linux distributions as long as the following packages are installed:

- vlc (includes cvlc)
- wget
- mpg123
- ffmpeg (includes speechnorm filter)
- yt-dlp (replacing youtube-dl)
- curl
- shuf
- bc (for calculations)

After installing these packages, create new directories in your home directory:

```bash
mkdir -p ~/funkRadio ~/funkRadio/Archive ~/funkRadio/Talk
```

Download or copy the `funkRadio.sh` script into the `~/funkRadio` directory and make it executable:

```bash
chmod u+x  ~/funkRadio/funkRadio.sh
```

Then, create log files:

```bash
touch ~/funkRadio/Archive/funkRadiolog.txt
touch ~/funkRadio/Archive/musicRadiolog.txt

```

If you have a music playlist in the m3u format, place a copy of it in the `~/funkRadio/` directory. The playlist should be a simple list of files. Playlists created by VLC are not suitable for this purpose.

Here is a script to make playlists on the basis of directories, album or artist names, or song duration: https://github.com/EloHope/make_playlist/tree/main

## Running FunkRadio

Launch FunkRadio by typing:

```bash
~/funkRadio/funkRadio.sh
```

First, the FunkRadio control panel will be displayed.

## FunkRadio Control Panel

The control panel presents a number of options for downloading the latest news broadcasts from various international sources. Select broadcast by typing a number and Enter. You can download several broadcasts in this way.

Start listening by typing '12' + Enter.

When listening, you can toggle between music and news by typing 'Ctrl + C'.

To turn off the radio, type 'CTRL + Z'.

## Additional Information

For other ways to work with podcasts on the command line, check out these scripts:

- [Bashpodder](https://github.com/ellencubed/bashpodder)
- [Bcaster](https://github.com/MiguSchweiz/bcaster/blob/master/bcaster)
- [Podsh](https://github.com/oyvindstegard/podsh/blob/master/podsh)

## About the Script

The `funkRadio.sh` script is designed to run on a Linux system using the Bash shell. It defines several functions to download news broadcasts, play music and news, and provide an interactive control panel. The script uses the `ffmpeg` package's `speechnorm` filter (if available) to normalize sound volume in audio files of selected broadcasters.
