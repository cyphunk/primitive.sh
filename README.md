Primitive linux management scripts that attempt to avoid abstractions and be more compatible with older systems.

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
 - `gifmake` nerds make memes
 - `syncenc` encrypt a file then scp it
 - `zipenc` make zip and password protect

Still to be ported to this repo (todo):

 - `configure.sh` setup system, X, remove systemd, etc
 - `safersudo` warn if sudo target writeable by non-root
 - `sync.sh`
 - `proxyall` force proxy for given command
 - `tftpdserver.sh`

Rant:

More often then not linux distrobution UI managers and abstractions work only in the narrowist of cases, require that users overfit their knowledge to a specific method of configuration that does not transverse well to other linux distrobutions or even newer revisions of the same distrobution, or require users interact with management tools that rarely if ever work without spending hours to days in the frustrating brute-force configuration circus. If devs and linuxy people were honest with themselves they'd tell you that of the meager 2 weeks per year that they have left after work to invest in other technical projects that 50% of that time is spent configuring their printer and the other 50% on various other linux system oddities. For some techy people this a replacement for meditation, for others a time drain. If you are in the latter category then you might have realized that if you invest in creating your own management scripts, throwing away as much of what your distros provides as possible, that you will reduce the overall time required when updating or moving systems. For those people maybe these scripts will help. Maybe not.