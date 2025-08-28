#!/bin/sh

# Disable redundant services to clean up RAM
/etc/init.d/datacenter stop
/etc/init.d/datacenter disable
/etc/init.d/plugincenter stop
/etc/init.d/plugincenter disable
/etc/init.d/syslog-ng stop
/etc/init.d/syslog-ng disable
/etc/init.d/messagingagent.sh stop
/etc/init.d/messagingagent.sh disable
/etc/init.d/smartcontroller stop
/etc/init.d/smartcontroller disable
/etc/init.d/netapi stop
/etc/init.d/netapi disable
/etc/init.d/trafficd stop
/etc/init.d/trafficd disable
opkg remove datacenter
opkg remove messagingagent
opkg remove smartcontroller_c
opkg remove netapi
opkg remove traffic2

# Router doesn't boot
# /etc/init.d/tbusd stop
# /etc/init.d/tbusd disable