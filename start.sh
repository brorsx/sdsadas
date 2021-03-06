#!/usr/bin/env bash
# Start script generated by ServerPackCreator 3.7.0.
# This script checks for the Minecraft and Forge JAR-files, and if they are not found, they are downloaded and installed.
# If everything is in order, the server is started.

if [ "$(id -u)" = "0" ]; then
  echo "Warning! Running with administrator-privileges is not recommended."
fi

JAVA="java"
MINECRAFT="1.18.2"
FORGE="40.1.54"
ARGS=""
OTHERARGS="-Dlog4j2.formatMsgNoLookups=true"

if [[ ! -s "libraries/net/minecraftforge/forge/$MINECRAFT-$FORGE/forge-$MINECRAFT-$FORGE-server.jar" ]];then

  echo "Forge Server JAR-file not found. Downloading installer...";
  wget -O forge-installer.jar https://files.minecraftforge.net/maven/net/minecraftforge/forge/$MINECRAFT-$FORGE/forge-$MINECRAFT-$FORGE-installer.jar;

  if [[ -s "forge-installer.jar" ]]; then

    echo "Installer downloaded. Installing...";
    "$JAVA" -jar forge-installer.jar --installServer;

    if [[ -s "libraries/net/minecraftforge/forge/$MINECRAFT-$FORGE/forge-$MINECRAFT-$FORGE-server.jar" ]];then
      rm -f forge-installer.jar;
      echo "Installation complete. forge-installer.jar deleted.";
    else
      rm -f forge-installer.jar
      echo "Something went wrong during the server installation. Please try again in a couple of minutes and check your internet connection.
      echo "Exiting..."
      read -n 1 -s -r -p "Press any key to continue"
      exit 1
    fi

  else
    echo "forge-installer.jar not found. Maybe the Forge servers are having trouble.";
    echo "Please try again in a couple of minutes and check your internet connection.";
    echo "Exiting..."
    read -n 1 -s -r -p "Press any key to continue"
    exit 1
  fi
else
  echo "Forge server present. Moving on..."
fi

if [[ ! -s "libraries/net/minecraft/server/$MINECRAFT/server-$MINECRAFT.jar" ]];then
  echo "Minecraft Server JAR-file not found. Downloading...";
  wget -O libraries/net/minecraft/server/$MINECRAFT/server-$MINECRAFT.jar https://launcher.mojang.com/v1/objects/c8f83c5655308435b3dcf03c06d9fe8740a77469/server.jar;
  if [[ -s "libraries/net/minecraft/server/$MINECRAFT/server-$MINECRAFT.jar" ]];then
    echo Download complete.
  else
    echo Something went wrong during the server download. Please try again in a couple of minutes and check your internet connection.
    echo "Exiting..."
    read -n 1 -s -r -p "Press any key to continue"
    exit 1
  fi
else
  echo "Minecraft server present. Moving on..."
fi

if [[ -s "run.bat" ]];then
  rm -f run.bat;
fi
if [[ -s "run.sh" ]];then
  rm -f run.sh;
fi

if [[ ! -s "eula.txt" ]];then
  echo "Mojang's EULA has not yet been accepted. In order to run a Minecraft server, you must accept Mojang's EULA."
  echo "Mojang's EULA is available to read at https://account.mojang.com/documents/minecraft_eula"
  echo "If you agree to Mojang's EULA then type 'I agree'"

  echo -n "Response: "
  read ANSWER

  if [[ "$ANSWER" = "I agree" ]]; then
    echo "User agreed to Mojang's EULA."
    echo "#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/documents/minecraft_eula)." > eula.txt;
    echo "eula=true" >> eula.txt;
  else
    echo "User did not agree to Mojang's EULA."
    echo "Entered: $ANSWER"
    echo "Exiting..."
    read -n 1 -s -r -p "Press any key to continue"
    exit 1
  fi
else
  echo "eula.txt present. Moving on...";
fi

echo "Starting server...";
echo "Minecraft version: $MINECRAFT";
echo "Forge version: $FORGE";
echo "Java version:"
$JAVA -version
echo "Java args in user_jvm_args.txt: $ARGS";

# Forge requires a configured set of both JVM and program arguments.
# Add custom JVM arguments to the user_jvm_args.txt
# Add custom program arguments {such as nogui} to this file in the next line before the "$@" or
#  pass them to this script directly
echo "If you receive the error message 'Error: Could not find or load main class @user_jvm_args.txt' you may be using the wrong Java-version for this modded Minecraft server. Contact the modpack-developer or, if you made the server pack yourself, do a quick google-search for the used Minecraft version to find out which Java-version is required in order to run this server."

$JAVA $OTHERARGS @user_jvm_args.txt @libraries/net/minecraftforge/forge/$MINECRAFT-$FORGE/unix_args.txt nogui "$@"