sh img-build.sh
sh iso-build.sh
# copy to milgra.com downloads
rsync temp/*.iso root@116.203.87.141:/root/milgra.com/server/resources/public/downloads/
# link it under transmission folder
ln /root/milgra.com/server/resources/public/downloads/swayos-2022.08.29-x86_64.iso swayos-2022.08.29-x86_64.iso
# create torrent
transmission-create swayos-2022.05.12-x86_64.iso -t udp://tracker.opentrackr.org:1337/announce
# add
transmission-remote -n 'transmission:pass' -a swayos-2022.05.12-x86_64.iso.torrent 
# download torrent
rsync -avP root@116.203.87.141:/var/lib/transmission-daemon/downloads/swayos-2022.08.29-x86_64.iso.torrent .
