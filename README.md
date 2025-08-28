# SOC-Eye 

A Minimal SOC-Style Live Monitoring & Alerting Tool (Pure Bash)

# overview

SOC-Eye is a lightweight, Bash-based script that simulates a Security Operations Center (SOC) eye-on-glass experience.
It continuously monitors system and IDS logs in real-time, extracts indicators of compromise (IoCs), and raises alerts with severity-based color coding.

Perfect for students, SOC interns, or anyone who wants to get hands-on with log analysis, threat detection, and SOC-style monitoring—without needing heavy SIEM tools.

# Features

🔍 Real-time log monitoring (syslog, auth.log, Suricata fast.log, etc.)

Detection rules for common SOC events:

SSH brute force attempts

Failed sudo escalations

Kernel crashes & suspicious downloads

Suricata IDS alerts

DNS beaconing patterns

 IoC extraction → IP, URL, domains, hashes, emails

  Pretty terminal output with severity coloring

  Optional alerts: desktop popups (notify-send) + terminal bell

  CSV logging for later analysis

# Test mode: generate sample events to demonstrate functionality

#  Requirements

# Bash 4+

awk, grep, coreutils

(Optional) notify-send (via libnotify-bin) → desktop notifications

# Usage
1. Clone & Setup
git clone https://github.com/<your-username>/soc-eye.git
cd soc-eye
chmod +x soc-eye.sh

# Run with Defaults
./soc-eye.sh
