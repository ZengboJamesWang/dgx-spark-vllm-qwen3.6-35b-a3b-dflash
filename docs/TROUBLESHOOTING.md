# Troubleshooting

## Model Loading Issues

### "Model type not recognized"
```
Resolved architecture: Qwen3_5MoeForConditionalGeneration
```
This is normal - vLLM recognizes the model correctly.

### "Not enough SMs to use max_autotune_gemm mode"
This is a warning, not an error. The model will still run correctly with fallback kernels.

## Performance Issues

### Slow inference (~<30 tok/s)
- Check GPU utilization: `nvidia-smi`
- Ensure CUDA graphs compiled successfully
- Verify no other processes using GPU
- Check temperature - thermal throttling reduces performance

### Out of Memory
- Reduce `--gpu-memory-utilization` (current: 0.38)
- Reduce `--max-model-len` (current: 32768)
- Stop other GPU processes
- Enable FP8 KV cache: `--kv-cache-dtype fp8`

## Container Issues

### "libcudart.so.12: cannot open shared object file"
Use the pinned Docker image digest in the Dockerfile to avoid this CUDA 12/13 mismatch.

### Container exits immediately
Check logs: `docker logs vllm-qwen3.6-35b-a3b-dflash`

## API Issues

### Connection refused
Server is still loading. Wait for CUDA graph compilation (~2-3 minutes).

### "Engine core initialization failed"
Usually out of memory. Check GPU memory with `nvidia-smi`.

## Systemd Issues

### Service won't start
```bash
systemctl --user status vllm-qwen3.6-35b-a3b-dflash
journalctl --user -u vllm-qwen3.6-35b-a3b-dflash
```

### Not starting at boot
Enable lingering:
```bash
sudo loginctl enable-linger $USER
```
