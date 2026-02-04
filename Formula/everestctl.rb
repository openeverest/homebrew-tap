class Everestctl < Formula
  desc "CLI tool for provisioning and managing OpenEverest on Kubernetes"
  homepage "https://github.com/openeverest/openeverest"
  license "Apache-2.0"
  version "1.13.0"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openeverest/openeverest/releases/download/v1.13.0/everestctl-darwin-amd64"
      sha256 "b1340ad8c1cb67c8cb570943511b3740dc3b5d231510205331ef4d32c990f477"
    elsif Hardware::CPU.arm?
      url "https://github.com/openeverest/openeverest/releases/download/v1.13.0/everestctl-darwin-arm64"
      sha256 "e62b6975ca1e5e5cf24053c73e59f57be8180750718caca43f230093870af9cc"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/openeverest/openeverest/releases/download/v1.13.0/everestctl-linux-amd64"
      sha256 "edd42d88711ba7e66f763f02d72e34b9f765e9253fcf4e4a7ccb85449734a96c"
    elsif Hardware::CPU.arm?
      url "https://github.com/openeverest/openeverest/releases/download/v1.13.0/everestctl-linux-arm64"
      sha256 "573bbd6f5394ef96be684c5bd3081481b2e47b91e9551cf545bc333df6986253"
    end
  end

  def install
    # Determine which file was downloaded
    arch = Hardware::CPU.intel? ? "amd64" : "arm64"
    os = OS.mac? ? "darwin" : "linux"
    
    # Rename the downloaded binary to 'everestctl' and install it
    bin.install "everestctl-#{os}-#{arch}" => "everestctl"
  end

  def caveats
    <<~EOS
      To get started with OpenEverest:
        everestctl install

      For headless installation:
        everestctl install --namespaces <namespace> --operator.mongodb=true --operator.postgresql=true --operator.mysql=true --skip-wizard

      Documentation: https://openeverest.io/documentation/current/
    EOS
  end

  test do
    assert_match "everestctl version", shell_output("#{bin}/everestctl version 2>&1")
  end
end