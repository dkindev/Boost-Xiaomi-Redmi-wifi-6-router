#!/bin/sh

# Download byedpi
curl --insecure -L https://github.com/hufrea/byedpi/releases/download/v0.17.3/byedpi-17.3-armv7l.tar.gz | tar xzf - -C /usr/bin

# Create hosts
mkdir -p /etc/config/byedpi && cat > /etc/config/byedpi/hosts << 'EOF'
youtube.com
youtu.be
yt.be
ggpht.com
gvt1.com
ytimg.com
i.ytimg.com
i9.ytimg.com
yt3.ggpht.com
l.google.com
play.google.com
youtube-nocookie.com
youtube-ui.l.google.com
youtubeembeddedplayer.googleapis.com
youtube.googleapis.com
youtubei.googleapis.com
yt-video-upload.l.google.com
wide-youtube.l.google.com
nhacmp3youtube.com
googleusercontent.com
yt3.googleusercontent.com
googleapis.com
googlevideo.com
1e100.net
whatsapp.com
whatsapp.net
static.whatsapp.net
g.whatsapp.net
time.android.com
web.whatsapp.com
signal.org
getsession.org
amazon.com
amazonaws.com
facebook.com
x.com
twitter.com
instagram.com
EOF

# Create service to run at boot
cat > /etc/init.d/byedpi << 'EOF'
#!/bin/sh /etc/rc.common

# Service metadata
USE_PROCD=1          # Use modern procd init system
START=99             # Start order (lower = earlier, 95-99 for user services)
STOP=10              # Stop order (higher = later)
SERVICE_WRITE_PID=1  # Let procd manage PID file

HOSTS_FILE=/etc/config/byedpi/hosts
COMMAND=/usr/bin/ciadpi-armv7l

get_proto() {
    [ $1 == 443 ] && echo https || echo www
}

get_local_redirect_rule_number() {
    RULE="REDIRECT.*192.168.31.0/24.*$(get_proto $1).*1080"
    echo $(iptables -t nat -L --line-numbers | grep "$RULE" | awk '{print $1}')
}

add_local_redirect() {
    RULE_NUMBER=$(get_local_redirect_rule_number $1)
    if [ -z "$RULE_NUMBER" ]; then
        iptables -t nat -A PREROUTING -p tcp -s 192.168.31.0/24 \! -d 192.168.31.0/24 --dport $1 -j REDIRECT --to-port 1080
    fi
}

remove_local_redirect() {
    RULE_NUMBER=$(get_local_redirect_rule_number $1)
    if [ -n "$RULE_NUMBER" ]; then
        iptables -t nat -D PREROUTING $RULE_NUMBER
    fi
}

start_service() {
    # Redirect http/https traffic to transparent proxy
    add_local_redirect 80
    add_local_redirect 443

    procd_open_instance
    procd_set_param command "$COMMAND" -p 1080 --transparent --hosts $HOSTS_FILE -s1 -q1 -Y -Ar -s5 -o1+s -At -f-1 -r1+s -As -s1 -o1 +s -s-1 -An -b+500 --auto=none
    procd_set_param file $HOSTS_FILE
    procd_set_param respawn
    procd_close_instance
}

stop_service() {
    # Cleanup actions
    remove_local_redirect 80
    remove_local_redirect 443
}

reload_service() {
    # Handle SIGHUP reload
    stop
    start
}
EOF

# Enable execution
chmod +x /etc/init.d/byedpi

# Enable service to start at boot
/etc/init.d/byedpi enable

# Start the service now
/etc/init.d/byedpi start