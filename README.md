# bashit

Translate natural language into a shell command. Prints the command, doesn't run it.

```
$ bashit list all files in this directory sorted by time
ls -ltr
```

Works with any OpenAI-compatible `/chat/completions` endpoint (OpenAI, Ollama, vLLM, Together, Groq, etc.).

## Install

```
cargo build --release
ln -s "$PWD/target/release/bashit" /opt/homebrew/bin/bashit   # or anywhere on PATH
```

## Configure

Set via env vars (the `OPENAI_*` names are also accepted as fallbacks):

| Variable           | Default                       | Required |
|--------------------|-------------------------------|----------|
| `BASHIT_API_KEY`   | —                             | yes      |
| `BASHIT_BASE_URL`  | `https://api.openai.com/v1`   | no       |
| `BASHIT_MODEL`     | `gpt-4o-mini`                 | no       |

Examples:

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

## Usage

Args or stdin — both work:

```sh
bashit find files larger than 100MB under home
echo "kill the process listening on port 8080" | bashit
```

Output is a single command on stdout. Use `$(...)` if you want to run it:

```sh
$(bashit list all files sorted by size)
```

## Shell integration (zsh): replace the line in place

Source the widget from `~/.zshrc`:

```sh
source /path/to/bashit/shell/bashit.zsh
```

Type a natural-language prompt, press **Ctrl+G**, and the line is replaced with the translated command. Nothing runs until you press Enter, so you can edit it first.

```
$ list all files in this directory sorted by time   ← type this, then Ctrl+G
$ ls -ltr                                            ← line becomes this
```

Errors (missing API key, network failure, quota) appear as a one-line message under the prompt; your typed text is preserved.

> Note: `Ctrl+G` is bound to `send-break` by default in zsh. Rebinding it is harmless but you'll lose that. Edit `shell/bashit.zsh` to pick a different key (e.g. `bindkey '^[g' bashit-widget` for Alt+G).
