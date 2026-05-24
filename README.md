# bashit

Type natural language in your terminal, press **Ctrl+G**, and the line becomes a shell command. It never runs the command for you — you press Enter when you're ready.

![demo](docs/demo.gif)

Works with any OpenAI-compatible `/chat/completions` endpoint (OpenAI, Ollama, vLLM, Together, Groq, etc.).

## Install

**Homebrew** (macOS, Linux):

```sh
brew install dnivra26/tap/bashit
```

**Curl installer** (macOS, Linux — no brew required):

```sh
curl -fsSL https://raw.githubusercontent.com/dnivra26/bashit/main/install.sh | sh
```

**From source** (requires Rust):

```sh
git clone https://github.com/dnivra26/bashit && cd bashit
cargo install --path .
```

Then enable the Ctrl+G widget by adding this to `~/.zshrc`:

```sh
# brew install:           /opt/homebrew/share/bashit/bashit.zsh  (Apple Silicon)
#                         /usr/local/share/bashit/bashit.zsh     (Intel / Linux)
# curl install (default): /usr/local/share/bashit/bashit.zsh
# from source:            <repo>/shell/bashit.zsh
source /usr/local/share/bashit/bashit.zsh
```

Reload (`source ~/.zshrc` or open a new shell) and you're set. Ctrl+G replaces the current line in place; errors (missing key, network, quota) show up under the prompt and your typed text is preserved.

> `Ctrl+G` is bound to `send-break` by default in zsh. Rebinding is harmless but you lose that. Want a different key? Edit `shell/bashit.zsh` — e.g. `bindkey '^[g' bashit-widget` for Alt+G, or `bindkey '^Xg' bashit-widget` for the chord Ctrl+X G.

## Configure

Set via env vars:

| Variable           | Default                       | Required |
|--------------------|-------------------------------|----------|
| `OPENAI_API_KEY`   | —                             | yes      |
| `OPENAI_BASE_URL`  | `https://api.openai.com/v1`   | no       |
| `OPENAI_MODEL`     | `gpt-4o-mini`                 | no       |

```sh
export OPENAI_API_KEY=sk-...
```

## Pipe / CLI usage

The Ctrl+G widget is the main way to use this. But the `bashit` binary also works as a plain CLI if you want to script with it:

```sh
bashit find files larger than 100MB under home
echo "kill the process listening on port 8080" | bashit
$(bashit list all files sorted by size)   # run the result
```
