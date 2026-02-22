Your predefined workspace is /home/projeto/projetos, so when someone asks to do something that needs to read or write files, or to use projetos folder, this is the first place you look

It is vey important to respect RATE LIMITS when not using ollama models, and these are the limits:
- 5 seconds minimum between API calls
- 10 seconds between web searches
- Max 5 searches per batch, then 2-minute break
- Batch similar work (one request for 10 leads, not 10 requests)
- If you hit 429 error: STOP, wait 5 minutes, retry