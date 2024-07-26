#!/bin/bash

SERVER=appserver.live.06a698d7-5dd3-4165-a76a-75b68b54ae99.drush.in;
LOGIN=live.06a698d7-5dd3-4165-a76a-75b68b54ae99;
PORT=2222;
FILEPATH=/files/cobrands;

if [ ! -f "/Users/$USER/.ssh/id_rsa" ]; then
    echo "ERROR! $USER SSH KEY Missing"
    echo "SFTP requires SSH access to Pantheon Server"
    echo ""
    exit;

fi

if [ -f "ftp.txt" ]; then
    echo "ERROR! ftp.txt file exists."
    echo "This process can not run in parallel"
    echo "If the process failed, remove the ftp.txt file"
    echo ""
    exit;
fi

if [ ! -d "OneColor" ]; then
  mkdir "OneColor"
fi

filecnt=0
for i in *; do 
  if [ -d "$i" ]; then
    if [ "$i" != "OneColor" ]; then
      # echo "${i// /-}"; 
      
      n=${i// /-};
      f=`echo -n "SecureByObscure=$n" | md5 `;
      cobrands+=("$i");
      codedfiles+=("$f.zip");

      if [ -d "./$i/1-color for Promotional Items only" ]; then
        mv "./$i/1-color for Promotional Items only" "./OneColor/$i OneColor"
        cd "OneColor";
        zip -r -q "./$f.zip" "./$i OneColor/";
        rm -rf "$i OneColor/";
        cd ..
        echo "put -r ./OneColor/$f.zip one-color/$f.zip"  >> ftp.txt
      fi
      zip -r -q "$f.zip" "$i/";
      rm -rf "$i/";
      echo "put -r ./$f.zip"  >> ftp.txt

      let filecnt++;
    fi
  fi
done
echo "quit" >> ftp.txt

# Upload Tiles to Server
if [ $filecnt -gt 0 ]; then
    sftp -P "$PORT" "$LOGIN@$SERVER:$FILEPATH" < ftp.txt

    # Output Results
    echo "Add the following values to the Gravity Form Field"
    echo ""
    count=0;
    while [ $count -lt $filecnt ]
    do
    rm -f ${codedfiles[${count}]};
    rm -f ./OneColor/${codedfiles[${count}]};

    echo "${cobrands[${count}]}|${codedfiles[${count}]}";
    count=$(( $count + 1 ))
    done
fi

# Cleanup
rm -f ftp.txt
echo "";
exit;
