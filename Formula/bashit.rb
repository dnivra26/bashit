# Homebrew formula template for bashit.
#
# This file is a starting point — copy it to your tap repo
# (github.com/dnivra26/homebrew-bashit) as Formula/bashit.rb.
# After the first release, the release workflow will auto-bump version
# and sha256s on each new tag (requires HOMEBREW_TAP_TOKEN secret).

class Bashit < Formula
  desc "Translate natural language into a shell command, replace the line in place"
  homepage "https://github.com/dnivra26/bashit"
  version "0.1.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/dnivra26/bashit/releases/download/v#{version}/bashit-aarch64-apple-darwin.tar.gz"
      sha256 "REPLACE_AFTER_FIRST_RELEASE_aarch64-apple-darwin"
    end
    on_intel do
      url "https://github.com/dnivra26/bashit/releases/download/v#{version}/bashit-x86_64-apple-darwin.tar.gz"
      sha256 "REPLACE_AFTER_FIRST_RELEASE_x86_64-apple-darwin"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/dnivra26/bashit/releases/download/v#{version}/bashit-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "REPLACE_AFTER_FIRST_RELEASE_aarch64-unknown-linux-gnu"
    end
    on_intel do
      url "https://github.com/dnivra26/bashit/releases/download/v#{version}/bashit-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "REPLACE_AFTER_FIRST_RELEASE_x86_64-unknown-linux-gnu"
    end
  end

  def install
    bin.install "bashit"
    (share/"bashit").install "bashit.zsh"
  end

  def caveats
    <<~EOS
      To enable the Ctrl+G inline-replacement widget, add this line to ~/.zshrc:

        source #{share}/bashit/bashit.zsh

      Configure with environment variables:

        export OPENAI_API_KEY=sk-...
        # optional:
        # export OPENAI_BASE_URL=https://api.openai.com/v1
        # export OPENAI_MODEL=gpt-4o-mini
    EOS
  end

  test do
    assert_match "missing API key", shell_output("#{bin}/bashit hello 2>&1", 1)
  end
end
