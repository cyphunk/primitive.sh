Primitive linux management scripts that attempts to avoid abstractions and be more compatible with older systems. 

Primitives: 
 - `monitor` manage external monitor/lcd
 - `wifi` manage wifi
 - `printer` manage network/usb printer
 - `mount.sh` mount external drives
 - `configure.sh` setup system, X, remove systemd, etc
 - `safersudo` warn if sudo target writeable by non-root

Other helpful tools:
 - `syncenc` 
 - `sync.sh`
 - `nointernet` block internet for given command
 - `proxyall` force proxy for given command
 - `httpdquick`
 - `httpdquickupload`
 - `tftpdserver.sh`
 - `gifmake` got tired of ffmeg's endless flags
 - `template.sh.example` how we prefer to write scripts
 - `helpers.sh` some functions used often. We copy+paste code from here rather than include this script in order to avoid potential security issues. Can run this script on other scripts to see if code differs
