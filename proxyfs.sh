#!/bin/bash


# PROXY PRESETS CONFIGURATION, feel free to change the default to what you use the most

# Throne / V2Ray / Xray default mixed port
THRONE_HTTP="http://127.0.0.1:2080"
THRONE_SOCKS="socks5://127.0.0.1:2080"

# I2P (Standard: HTTP on 4444, SOCKS on 4447)
I2P_HTTP="http://127.0.0.1:4444"
I2P_SOCKS="socks5://127.0.0.1:4447"

# Tor Daemon (Standard SOCKS on 9050, socks5h enables remote DNS resolving)
TOR_SOCKS="socks5h://127.0.0.1:9050"

# Clash / Mihomo mixed port
CLASH_HTTP="http://127.0.0.1:7890"
CLASH_SOCKS="socks5://127.0.0.1:7890"

# Shadowsocks local SOCKS5 port
SS_SOCKS="socks5://127.0.0.1:1080"


# CORE FUNCTIONS


function _apply_env() {
    local http_val="$1"
    local socks_val="$2"
    local label="$3"

    export http_proxy="$http_val"
    export https_proxy="$http_val"
    export HTTP_PROXY="$http_val"
    export HTTPS_PROXY="$http_val"
    export ALL_PROXY="$socks_val"

    echo "[+] (^_^)b Proxy enabled: $label"
    echo "    HTTP/HTTPS: $http_val"
    echo "    ALL_PROXY:  $socks_val"
}

function proxy_set_profile() {
    local profile="${1:-throne}"
    case "$profile" in
        throne|v2ray)
            _apply_env "$THRONE_HTTP" "$THRONE_SOCKS" "Throne / V2Ray (127.0.0.1:2080)"
            ;;
        i2p)
            _apply_env "$I2P_HTTP" "$I2P_SOCKS" "I2P (HTTP: 4444 / SOCKS: 4447)"
            ;;
        tor)
            _apply_env "$TOR_SOCKS" "$TOR_SOCKS" "Tor SOCKS (127.0.0.1:9050)"
            ;;
        clash|mihomo)
            _apply_env "$CLASH_HTTP" "$CLASH_SOCKS" "Clash / Mihomo (127.0.0.1:7890)"
            ;;
        ss|shadowsocks)
            _apply_env "$SS_SOCKS" "$SS_SOCKS" "Shadowsocks (127.0.0.1:1080)"
            ;;
        *)
            # Treat unknown profile as custom IP:PORT or URL
            local target="$profile"
            [[ "$target" != http* && "$target" != socks* ]] && target="http://$target"
            _apply_env "$target" "$target" "Custom ($target)"
            ;;
    esac
}

function proxy_off() {
    unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY
    echo "[-] (x_x) All proxy environment variables cleared."
}

function proxy_status() {
    echo "<*)))>< --- Current Proxy Status --- ><(((+>"
    local active_proxies
    active_proxies=$(env | grep -iE '^(http_proxy|https_proxy|all_proxy)=' 2>/dev/null)
    if [ -z "$active_proxies" ]; then
        echo " (o_o) No proxy environment variables set."
    else
        echo "$active_proxies"
    fi
    echo "-----------------------------------------"
}

# Run a single app in a subshell without altering your parent shell
function proxy_run_app() {
    local proxy_choice="$1"
    shift
    local cmd=("$@")

    if [ ${#cmd[@]} -eq 0 ]; then
        echo "[!] (o_O) No command provided to run."
        return 1
    fi

    local hp="" sp=""
    case "$proxy_choice" in
        throne|v2ray) hp="$THRONE_HTTP"; sp="$THRONE_SOCKS" ;;
        i2p)          hp="$I2P_HTTP";    sp="$I2P_SOCKS" ;;
        tor)          hp="$TOR_SOCKS";   sp="$TOR_SOCKS" ;;
        clash)        hp="$CLASH_HTTP";  sp="$CLASH_SOCKS" ;;
        ss)           hp="$SS_SOCKS";    sp="$SS_SOCKS" ;;
        *)            hp="$proxy_choice"; sp="$proxy_choice" ;;
    esac

    echo "[*] (>_<) Running '${cmd[*]}' via [$proxy_choice]..."
    env http_proxy="$hp" https_proxy="$hp" HTTP_PROXY="$hp" HTTPS_PROXY="$hp" ALL_PROXY="$sp" "${cmd[@]}"
}

# INTERACTIVE TUI, might just be needed sometimes :D

function show_tui() {
    echo ""
    echo "+------------------------------------------+"
    echo "|          (o_o) PROXY MANAGER             |"
    echo "+------------------------------------------+"
    echo " 1) Throne / V2Ray   (127.0.0.1:2080)"
    echo " 2) I2P Router       (HTTP 4444 / SOCKS 4447)"
    echo " 3) Tor Daemon       (SOCKS 127.0.0.1:9050)"
    echo " 4) Clash / Mihomo   (127.0.0.1:7890)"
    echo " 5) Shadowsocks      (SOCKS 127.0.0.1:1080)"
    echo " 6) Custom Proxy     (Enter custom target)"
    echo " 7) Run Single App   (Isolated command execution)"
    echo " 8) Disable Proxy    (x_x)"
    echo " 9) View Status      (o_o)"
    echo " 0) Quit             (^o^)/"
    echo "+------------------------------------------+"

    read -p "Select option [0-9]: " choice
    case "$choice" in
        1) proxy_set_profile "throne" ;;
        2) proxy_set_profile "i2p" ;;
        3) proxy_set_profile "tor" ;;
        4) proxy_set_profile "clash" ;;
        5) proxy_set_profile "ss" ;;
        6)
            read -p "Enter proxy (e.g. 192.168.1.50:8080 or socks5://...): " custom
            [ -n "$custom" ] && proxy_set_profile "$custom"
            ;;
        7)
            echo ""
            echo "Select preset for application:"
            echo " [throne | i2p | tor | clash | ss | or custom host:port]"
            read -p "Proxy target: " app_proxy
            read -p "Enter command to run (e.g. curl ifconfig.me): " app_cmd
            echo ""
            if [ -n "$app_proxy" ] && [ -n "$app_cmd" ]; then
                eval "proxy_run_app \"$app_proxy\" $app_cmd"
            else
                echo "[!] (o_O) Cancelled: target or command was empty."
            fi
            ;;
        8) proxy_off ;;
        9) proxy_status ;;
        0) echo "Bye! (^o^)/" ;;
        *) echo "[!] (o_O) Invalid selection." ;;
    esac
}

# CLI ROUTER

case "$1" in
    on)
        # Allows: proxyfs on, or proxyfs on tor, proxyfs on i2p, proxyfs on 1.2.3.4:8080
        proxy_set_profile "${2:-throne}"
        ;;
    off)
        proxy_off
        ;;
    status)
        proxy_status
        ;;
    run)
        # Usage: proxyfs run <profile|target> <command...>
        # Example: proxyfs run tor curl ifconfig.me, you can also use it to run an application like steam, spotify etc...
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "[!] Usage: proxyfs run <throne|i2p|tor|clash|ss|HOST:PORT> <command>"
        else
            shift
            target="$1"
            shift
            proxy_run_app "$target" "$@"
        fi
        ;;
    "")
        show_tui
        ;;
    *)
        echo "Usage:"
        echo "  proxyfs                     Launch TUI  (o_o)"
        echo "  proxyfs on [profile]        Enable: throne | i2p | tor | clash | ss | IP:PORT"
        echo "  proxyfs off                 Turn off proxy (x_x)"
        echo "  proxyfs status              Check status"
        echo "  proxyfs run <profile> <cmd> Run single app through proxy"
        ;;
esac
