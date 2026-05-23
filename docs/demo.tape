# vhs script: regenerate with `vhs docs/demo.tape`
# Records the Ctrl+G inline-replacement flow.
# Requires OPENAI_API_KEY (and OPENAI_BASE_URL/OPENAI_MODEL if non-default)
# to be set in the calling shell.

Output "docs/demo.gif"

Set Shell "zsh"
Set FontSize 20
Set Width 1100
Set Height 380
Set Theme "Catppuccin Mocha"
Set TypingSpeed 60ms

# Silent setup: load the widget, set a clean prompt, clear the screen.
Hide
Type "source /Users/arvindthangamani/projects/bashit/shell/bashit.zsh"
Enter
Type `autoload -U colors && colors`
Enter
Type `setopt prompt_subst`
Enter
Type `PS1='%{$fg_bold[green]%}➜  %{$fg[cyan]%}demo %{$reset_color%}'`
Enter
Type "clear"
Enter
Sleep 400ms
Show

Sleep 600ms
Type "list all files in this directory sorted by time"
Sleep 1s
Ctrl+G
Sleep 2500ms
Enter
Sleep 1500ms
