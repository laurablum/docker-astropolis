#!/bin/bash

set -x

FORGE_VERSION=1.19.2-43.3.9
cd /data

if ! [[ "$EULA" = "false" ]] || grep -i true eula.txt; then
	echo "eula=true" > eula.txt
else
	echo "You must accept the EULA by in the container settings."
	exit 9
fi

if ! [[ -f 'Astropolis_server_pack.zip' ]]; then
	rm -fr config kubejs libraries mods *.zip forge*.jar
	curl -Lo 'Astropolis_server_pack.zip' 'https://edge.forgecdn.net/files/5232/781/Astropolis_server_pack.zip' && unzip -u -o 'Astropolis_server_pack.zip' -d /data
	DIR_TEST=$(find . -type d -maxdepth 1 | tail -1 | sed 's/^.\{2\}//g')
	if [[ $(find . -type d -maxdepth 1 | wc -l) -gt 1 ]]; then
		cd "${DIR_TEST}"
		mv -f * /data
		cd /data
		rm -fr "$DIR_TEST"
	fi
	java -jar $(ls forge-*-installer.jar) --installServer && rm -f forge-*-installer.jar
fi

if [[ -n "$JVM_OPTS" ]]; then
	sed -i '/-Xm[s,x]/d' user_jvm_args.txt
	for j in ${JVM_OPTS}; do sed -i '$a\'$j'' user_jvm_args.txt; done
fi
if [[ -n "$MOTD" ]]; then
    sed -i "/motd\s*=/ c motd=$MOTD" /data/server.properties
fi
if [[ -n "$LEVEL" ]]; then
    sed -i "/level-name\s*=/ c level-name=$LEVEL" /data/server.properties
fi
if [[ -n "$OPS" ]]; then
    echo $OPS | awk -v RS=, '{print}' > ops.txt
fi
if [[ -n "$ALLOWLIST" ]]; then
    echo $ALLOWLIST | awk -v RS=, '{print}' > white-list.txt
fi

sed -i 's/server-port.*/server-port=25565/g' server.properties

chmod +x run.sh
./run.sh