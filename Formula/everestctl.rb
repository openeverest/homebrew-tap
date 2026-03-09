class Everestctl < Formula
  desc "CLI tool for provisioning and managing OpenEverest on Kubernetes"
  homepage "https://github.com/openeverest/openeverest"
  license "Apache-2.0"
  version "1.14.0"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openeverest/openeverest/releases/download/v1.14.0/everestctl-darwin-amd64"
      sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
    elsif Hardware::CPU.arm?
      url "https://github.com/openeverest/openeverest/releases/download/v1.14.0/everestctl-darwin-arm64"
      sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/openeverest/openeverest/releases/download/v1.14.0/everestctl-linux-amd64"
      sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
    elsif Hardware::CPU.arm?
      url "https://github.com/openeverest/openeverest/releases/download/v1.14.0/everestctl-linux-arm64"
      sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
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