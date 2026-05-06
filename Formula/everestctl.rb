class Everestctl < Formula
  desc "CLI tool for provisioning and managing OpenEverest on Kubernetes"
  homepage "https://github.com/openeverest/openeverest"
  version "1.15.2"
  license "Apache-2.0"

  livecheck do
    url :homepage
    strategy :github_latest
  end

  on_macos do
    on_intel do
      url "https://github.com/openeverest/openeverest/releases/download/v1.15.2/everestctl-darwin-amd64"
      sha256 "78ea2ff110722d512b2ec2d209fcaddba764377bc867b451e96c6ade8aae56c0"
    end
    on_arm do
      url "https://github.com/openeverest/openeverest/releases/download/v1.15.2/everestctl-darwin-arm64"
      sha256 "0e50a31adb492ef479999a79eeec2727b1a88276b959e97c840810eb31a1009a"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/openeverest/openeverest/releases/download/v1.15.2/everestctl-linux-amd64"
      sha256 "6ed4f641c5230416e924666b3fe439b2b8b349c1d0cc6a61d00cf10f0e841b42"
    end
    on_arm do
      url "https://github.com/openeverest/openeverest/releases/download/v1.15.2/everestctl-linux-arm64"
      sha256 "42314fe315b73b83e1537f0b0eaa39d657758990051442f2fec196afd94fc9d8"
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
