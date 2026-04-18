#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]")/.." && pwd)"
SERVICE_NAME="vllm-qwen3.6-35b-a3b-dflash.service"
USER_SERVICE_DIR="$HOME/.config/systemd/user"

echo "=================================="
echo "vLLM Systemd Service Installer"
echo "=================================="

mkdir -p "$USER_SERVICE_DIR"

cat > "$USER_SERVICE_DIR/$SERVICE_NAME" << EOF
[Unit]
Description=vLLM Qwen3.6-35B-A3B-DFlash
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$REPO_DIR
ExecStart=$REPO_DIR/scripts/start.sh
ExecStop=-docker stop vllm-qwen3.6-35b-a3b-dflash
ExecStop=-docker rm vllm-qwen3.6-35b-a3b-dflash

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable "$SERVICE_NAME"

echo ""
echo "✅ Service installed: $SERVICE_NAME"
echo ""
echo "Commands:"
echo "  Start now:   systemctl --user start $SERVICE_NAME"
echo "  Stop:        systemctl --user stop $SERVICE_NAME"
echo "  Status:      systemctl --user status $SERVICE_NAME"
echo "  Disable:     systemctl --user disable $SERVICE_NAME"
echo ""

if ! loginctl show-user "$USER" --property=Linger 2>/dev/null | grep -q "yes"; then
    echo "⚠️  Important: lingering is NOT enabled for user $USER."
    echo "   Without lingering, the service will only start on login, not at boot."
    echo ""
    echo "   To enable boot-time auto-start, run:"
    echo "     sudo loginctl enable-linger $USER"
    echo ""
else
    echo "✅ Linger is enabled — service will auto-start at boot."
fi

echo "To start vLLM immediately, run: systemctl --user start $SERVICE_NAME"
