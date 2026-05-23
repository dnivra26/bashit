# bashit

Type natural language in your terminal, press **Ctrl+G**, and the line becomes a shell command. It never runs the command for you — you press Enter when you're ready.

```
$ list all files in this directory sorted by time   ← type, then Ctrl+G
$ ls -ltr                                            ← line is replaced
```

Works with any OpenAI-compatible `/chat/completions` endpoint (OpenAI, Ollama, vLLM, Together, Groq, etc.).

## Install

```sh
cargo build --release
ln -s "$PWD/target/release/bashit" /opt/homebrew/bin/bashit   # or anywhere on PATH
```

Then add to `~/.zshrc`:

```sh
source /path/to/bashit/shell/bashit.zsh
```

Reload (`source ~/.zshrc` or open a new shell) and you're set. Ctrl+G replaces the current line in place; errors (missing key, network, quota) show up under the prompt and your typed text is preserved.

> `Ctrl+G` is bound to `send-break` by default in zsh. Rebinding is harmless but you lose that. Want a different key? Edit `shell/bashit.zsh` — e.g. `bindkey '^[g' bashit-widget` for Alt+G, or `bindkey '^Xg' bashit-widget` for the chord Ctrl+X G.

## Configure

Set via env vars (the `OPENAI_*` names are accepted as fallbacks):

| Variable           | Default                       | Required |
|--------------------|-------------------------------|----------|
| `BASHIT_API_KEY`   | —                             | yes      |
| `BASHIT_BASE_URL`  | `https://api.openai.com/v1`   | no       |
| `BASHIT_MODEL`     | `gpt-4o-mini`                 | no       |

```sh
# OpenAI
export BASHIT_API_KEY=sk-...

# Local Ollama
export BASHIT_BASE_URL=http://localhost:11434/v1
export BASHIT_MODEL=llama3.1
export BASHIT_API_KEY=ollama   # any non-empty string

# Groq
export BASHIT_BASE_URL=https://api.groq.com/openai/v1
export BASHIT_MODEL=llama-3.3-70b-versatile
export BASHIT_API_KEY=gsk_...
```

## Pipe / CLI usage

The Ctrl+G widget is the main way to use this. But the `bashit` binary also works as a plain CLI if you want to script with it:

```sh
bashit find files larger than 100MB under home
echo "kill the process listening on port 8080" | bashit
$(bashit list all files sorted by size)   # run the result
```
