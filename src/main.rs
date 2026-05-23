use std::io::{self, Read, Write};
use std::process::ExitCode;
use std::time::Duration;

use serde::{Deserialize, Serialize};

const DEFAULT_BASE_URL: &str = "https://api.openai.com/v1";
const DEFAULT_MODEL: &str = "gpt-4o-mini";

const SYSTEM_PROMPT: &str = "You translate natural language into a single shell command for the user's terminal. \
Reply with ONLY the command, on a single line. \
No code fences, no backticks, no quotes around the whole command, no commentary, no leading shell prompt. \
Prefer POSIX-portable commands when reasonable. \
If the request is ambiguous, pick the most common interpretation. \
If the request cannot be expressed as a shell command, output exactly: # cannot translate";

#[derive(Serialize)]
struct ChatRequest<'a> {
    model: &'a str,
    messages: Vec<Message<'a>>,
    temperature: f32,
}

#[derive(Serialize)]
struct Message<'a> {
    role: &'a str,
    content: &'a str,
}

#[derive(Deserialize)]
struct ChatResponse {
    choices: Vec<Choice>,
}

#[derive(Deserialize)]
struct Choice {
    message: RespMessage,
}

#[derive(Deserialize)]
struct RespMessage {
    content: String,
}

struct Config {
    base_url: String,
    model: String,
    api_key: String,
}

impl Config {
    fn from_env() -> Result<Self, String> {
        let api_key = std::env::var("OPENAI_API_KEY")
            .map_err(|_| "missing API key: set OPENAI_API_KEY".to_string())?;
        let base_url =
            std::env::var("OPENAI_BASE_URL").unwrap_or_else(|_| DEFAULT_BASE_URL.to_string());
        let model = std::env::var("OPENAI_MODEL").unwrap_or_else(|_| DEFAULT_MODEL.to_string());
        Ok(Self { base_url, model, api_key })
    }
}

fn read_prompt() -> io::Result<String> {
    let args: Vec<String> = std::env::args().skip(1).collect();
    let arg_prompt = args.join(" ").trim().to_string();

    let mut stdin_buf = String::new();
    if !stdin_is_tty() {
        io::stdin().read_to_string(&mut stdin_buf)?;
    }
    let stdin_prompt = stdin_buf.trim().to_string();

    let combined = match (arg_prompt.is_empty(), stdin_prompt.is_empty()) {
        (true, true) => String::new(),
        (false, true) => arg_prompt,
        (true, false) => stdin_prompt,
        (false, false) => format!("{arg_prompt}\n\n{stdin_prompt}"),
    };
    Ok(combined)
}

fn stdin_is_tty() -> bool {
    #[cfg(unix)]
    unsafe {
        unsafe extern "C" {
            fn isatty(fd: i32) -> i32;
        }
        isatty(0) != 0
    }
    #[cfg(not(unix))]
    {
        true
    }
}

fn clean_command(raw: &str) -> String {
    let mut s = raw.trim().to_string();

    if s.starts_with("```") {
        if let Some(rest) = s.strip_prefix("```") {
            let after_lang = rest.find('\n').map(|i| &rest[i + 1..]).unwrap_or(rest);
            s = after_lang.to_string();
        }
        if let Some(idx) = s.rfind("```") {
            s.truncate(idx);
        }
        s = s.trim().to_string();
    }

    s = s.trim_matches('`').trim().to_string();

    for prefix in ["$ ", "% ", "# "] {
        if let Some(stripped) = s.strip_prefix(prefix) {
            s = stripped.to_string();
            break;
        }
    }

    s.lines()
        .map(str::trim_end)
        .find(|l| !l.trim().is_empty())
        .unwrap_or("")
        .to_string()
}

fn translate(cfg: &Config, prompt: &str) -> Result<String, String> {
    let url = format!("{}/chat/completions", cfg.base_url.trim_end_matches('/'));

    let body = ChatRequest {
        model: &cfg.model,
        messages: vec![
            Message { role: "system", content: SYSTEM_PROMPT },
            Message { role: "user", content: prompt },
        ],
        temperature: 0.0,
    };

    let client = reqwest::blocking::Client::builder()
        .timeout(Duration::from_secs(60))
        .build()
        .map_err(|e| format!("http client: {e}"))?;

    let resp = client
        .post(&url)
        .bearer_auth(&cfg.api_key)
        .json(&body)
        .send()
        .map_err(|e| format!("request failed: {e}"))?;

    let status = resp.status();
    let text = resp.text().map_err(|e| format!("read body: {e}"))?;
    if !status.is_success() {
        return Err(format!("api error {status}: {text}"));
    }

    let parsed: ChatResponse = serde_json::from_str(&text)
        .map_err(|e| format!("parse response: {e}: {text}"))?;
    let raw = parsed
        .choices
        .into_iter()
        .next()
        .ok_or_else(|| "empty choices in response".to_string())?
        .message
        .content;

    Ok(clean_command(&raw))
}

fn run() -> Result<(), String> {
    let prompt = read_prompt().map_err(|e| format!("read input: {e}"))?;
    if prompt.is_empty() {
        return Err(
            "no prompt provided. usage: `echo \"list all files\" | bashit` or `bashit list all files`"
                .to_string(),
        );
    }
    let cfg = Config::from_env()?;
    let cmd = translate(&cfg, &prompt)?;
    if cmd.is_empty() {
        return Err("model returned no command".to_string());
    }
    let mut out = io::stdout().lock();
    writeln!(out, "{cmd}").map_err(|e| format!("write stdout: {e}"))?;
    Ok(())
}

fn main() -> ExitCode {
    match run() {
        Ok(()) => ExitCode::SUCCESS,
        Err(e) => {
            let _ = writeln!(io::stderr(), "bashit: {e}");
            ExitCode::FAILURE
        }
    }
}
