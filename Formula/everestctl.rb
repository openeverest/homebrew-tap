class Everestctl < Formula
  desc "CLI tool for provisioning and managing OpenEverest on Kubernetes"
  homepage "https://github.com/openeverest/openeverest"
  license "Apache-2.0"
  version "1.12.0"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openeverest/openeverest/releases/download/v1.12.0/everestctl-darwin-amd64"
      sha256 "697a2059ca095458cce9624fbe668976596a5576ab86d36825d292cba057ba0e"
    elsif Hardware::CPU.arm?
      url "https://github.com/openeverest/openeverest/releases/download/v1.12.0/everestctl-darwin-arm64"
      sha256 "329d7d429f633e0f4d028cafe279273b4b184254f712568539131c015268b359"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/openeverest/openeverest/releases/download/v1.12.0/everestctl-linux-amd64"
      sha256 "83926c0e09cce17f3dfcdf93458f268d22a7d67a39ec6e2d52f382a6dd1699bc"
    elsif Hardware::CPU.arm?
      url "https://github.com/openeverest/openeverest/releases/download/v1.12.0/everestctl-linux-arm64"
      sha256 "a42ec0b72b014c4daf5d9ab77c97f36090730b92cd3c922bcf98acc3c4345c9d"
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