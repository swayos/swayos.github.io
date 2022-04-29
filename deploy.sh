sh img-build.sh
sh iso-build.sh
rsync temp/*.iso root@116.203.87.141:/root/milgra.com/server/resources/public/downloads/
