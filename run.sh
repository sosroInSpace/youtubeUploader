#!/bin/bash

while IFS= read -r word <&3; do

  echo "$word"
  echo "HERE"

  imgfile="/tmp/image.png"
  soundfile="/tmp/sound.mp3"
  videofile="/tmp/video.mov"
  ${word// /%20}

  rm -f "$imgfile"
  rm -f "$soundfile"
  rm -f "$videofile"

  # Generate image.
  if ! convert -size 2560x1440 xc:yellow -pointsize 120 -family "Verdana" -fill black -draw "text 64,128 'How to pronounce:

\"$word\"'" "$imgfile"; then
    echo "ERROR: Could not create image $word"
    echo "$word" >> failed.txt
    continue
  fi

  echo "HERE2"

  # Get the sound file.
  soundfile="/tmp/sound.mp3"
  if ! curl -s --fail "https://d1qx7pbj0dvboc.cloudfront.net/$word.mp3" > "$soundfile"; then
    echo "ERROR: Could not get sound $word"
    echo "$word" >> failed.txt
    continue
  fi

  echo "HERE3"

  # Generate the video. 
  if ! ffmpeg -loop 1 -i "$imgfile" -stream_loop 42 -i "$soundfile" -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p -shortest "$videofile" </dev/null; then
    echo "ERROR: Could not create video for $word"
    echo "$word" >> failed.txt
    continue
  fi

  echo "HERE4"

  # Upload to youtube.
  python upload_video.py --file="$videofile"\
  --title="How to pronounce $word"\
  --description="How to pronounce $word.\\n\\nA free online pronunciation dictionary.\\n\\n$word pronunciation.\\n\\nEnglish and American Spelling with naturally recorded voice.\\n\\nCredit:\\nhttps://howjsay.com\\nhttps://howjsay.com/how-to-pronounce-$word"\
  --keywords="pronunciation,dictionary,learn,talk,pronounce,words,$word,speak,english"\
  --category="27"\
  --privacyStatus="public"

  echo "DONE: $word"
  echo "$word" >> successful.txt

done 3<./words.txt  # FILE MUST END WITH NEWLINE.
