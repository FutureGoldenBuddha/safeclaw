#!/bin/bash
set -e

# Display debug information
echo "=== DEBUG INFO ==="
echo "HOME: $HOME"
echo "PWD: $(pwd)"
echo "USER: $(whoami)"
echo "UID: $(id -u)"
echo "MODEL_PATH: $MODEL_PATH"
echo ""

echo "=== LISTING /models ==="
ls -la /models/
echo ""

echo "=== CHECKING IF MODEL EXISTS ==="
if [ -f "$MODEL_PATH" ]; then
    echo "✓ Model found: $MODEL_PATH"
    ls -lh "$MODEL_PATH"
else
    echo "✗ Model NOT found: $MODEL_PATH"
fi
echo ""

# intel only
#echo "=== TESTING COMMUNICATION WITH /dev/dri ==="
#echo "test -w /dev/dri/renderD128 && echo 'Access OK' || echo 'No access'"
#echo "=== CONFIRMING PERMISSIONS ON /dev/dri ==="
#ls -la /dev/dri/ || true
#echo ""

echo "=== STARTING LLAMA-SERVER ==="
echo "=== SWITCHING TO USER 1000 ==="

# Drop privileges to user 1000 and start the server
exec gosu 1000:1000 /app/llama-server \
    --host 0.0.0.0 \
    --port 8080 \
    -m "$MODEL_PATH" \
    -ngl -1 \
    --ctx-size 32000