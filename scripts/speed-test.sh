#!/bin/bash
set -e

API_URL="http://localhost:8000/v1/chat/completions"
MODEL="qwen3.6-35b-a3b-dflash"

echo "=================================================="
echo "DGX Spark vLLM Speed Test"
echo "Model: $MODEL"
echo "=================================================="

if ! curl -s http://localhost:8000/v1/models > /dev/null 2>&1; then
    echo "❌ Server not running! Start it first with: bash scripts/start.sh"
    exit 1
fi

echo ""
echo "Running streaming speed test (512 tokens)..."
echo ""

# Use Python for accurate streaming timing
python3 << 'PYEOF'
import requests
import json
import time

url = "http://localhost:8000/v1/chat/completions"
payload = {
    "model": "qwen3.6-35b-a3b-dflash",
    "messages": [{"role": "user", "content": "Write a detailed explanation of how neural networks work, including backpropagation, activation functions, and different architectures. Be thorough and educational."}],
    "max_tokens": 512,
    "temperature": 0.7,
    "stream": True
}

print("Starting generation...")
start_time = time.time()
first_token_time = None
token_count = 0

response = requests.post(url, json=payload, stream=True)
for line in response.iter_lines():
    if line:
        line = line.decode('utf-8')
        if line.startswith('data: '):
            data = line[6:]
            if data == '[DONE]':
                break
            try:
                chunk = json.loads(data)
                if 'choices' in chunk and len(chunk['choices']) > 0:
                    delta = chunk['choices'][0].get('delta', {})
                    if 'content' in delta and delta['content']:
                        token_count += 1
                        if first_token_time is None:
                            first_token_time = time.time()
                            ttf = first_token_time - start_time
                            print(f"⏱️  Time to first token: {ttf:.3f}s")
            except:
                pass

end_time = time.time()
total_time = end_time - start_time
gen_time = end_time - first_token_time if first_token_time else total_time

speed = token_count / gen_time if gen_time > 0 else 0

print(f"\n📊 Results:")
print(f"  Total tokens: {token_count}")
print(f"  Total time: {total_time:.2f}s")
print(f"  Generation time: {gen_time:.2f}s")
print(f"  Speed: {speed:.2f} tok/s")
PYEOF

echo ""
echo "=================================================="
