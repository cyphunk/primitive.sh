Primitive linux management scripts that attempts to avoid abstractions and be more compatible with older systems. 

Primitives: 

 - `monitor` manage external monitor/lcd
 - `wifi` manage wifi
 - `printer` manage network/usb printer
 - `mount.sh` mount external drives
 - `bluetooth` manage bluetooth devices

Other helpful tools:

 - `nointernet` block internet for given command
 - `aliases` one-liners:
   - `httpdquick` http server
   - `ntponce` sync system time once

Still to be ported to this repo (todo):

 - `configure.sh` setup system, X, remove systemd, etc
 - `safersudo` warn if sudo target writeable by non-root
 - `syncenc` 
 - `sync.sh`
 - `proxyall` force proxy for given command
 - `tftpdserver.sh`
 - `gifmake`
