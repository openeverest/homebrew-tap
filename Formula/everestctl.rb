class Everestctl < Formula
  desc "CLI tool for provisioning and managing OpenEverest on Kubernetes"
  homepage "https://github.com/openeverest/openeverest"
  version "1.15.0"
  license "Apache-2.0"

  livecheck do
    url :homepage
    strategy :github_latest
  end

  on_macos do
    on_intel do
      url "https://github.com/openeverest/openeverest/releases/download/v1.15.0/everestctl-darwin-amd64"
      sha256 "01685e015b9e40475c6b04e9d0f233093cfa445b8f68f807d6658012c028a1a8"
    end
    on_arm do
      url "https://github.com/openeverest/openeverest/releases/download/v1.15.0/everestctl-darwin-arm64"
      sha256 "c2d54acde0106f499117756f093114f7fb93f4d3f4ace7010c4917e9fff5f8c7"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/openeverest/openeverest/releases/download/v1.15.0/everestctl-linux-amd64"
      sha256 "de6b99abcf4f8234d2449645a09dc6e9ddea32ca938b2e7fcb15958847c9d127"
    end
    on_arm do
      url "https://github.com/openeverest/openeverest/releases/download/v1.15.0/everestctl-linux-arm64"
      sha256 "d611101365e0ac49f040f60c300de960471a6c5a977db363c8c76e3360001595"
    end
  end

  def install
    os = OS.mac? ? "darwin" : "linux"
    arch = Hardware::CPU.arm? ? "arm64" : "amd64"
    bin.install "everestctl-#{os}-#{arch}" => "everestctl"
  end

  def caveats
    <<~EOS
      To get started with OpenEverest:
        everestctl install

      For headless installation:
        everestctl install --namespaces <namespace> \\
          --operator.mongodb=true \\
          --operator.postgresql=true \\
          --operator.mysql=true \\
          --skip-wizard

      Documentation: https://openeverest.io/documentation/current/
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/everestctl version 2>&1")
  end
end
