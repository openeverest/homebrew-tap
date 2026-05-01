class Everestctl < Formula
  desc "CLI tool for provisioning and managing OpenEverest on Kubernetes"
  homepage "https://github.com/openeverest/openeverest"
  version "1.15.1"
  license "Apache-2.0"

  livecheck do
    url :homepage
    strategy :github_latest
  end

  on_macos do
    on_intel do
      url "https://github.com/openeverest/openeverest/releases/download/v1.15.1/everestctl-darwin-amd64"
      sha256 "d90c3881b880fc71ffdd0154e087a9d77f243cab8c6ab153ad439bcf995440e4"
    end
    on_arm do
      url "https://github.com/openeverest/openeverest/releases/download/v1.15.1/everestctl-darwin-arm64"
      sha256 "9ace1c830d05af104b7fd9f458b38af6a17b2d92c778a382da66072524ad12a2"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/openeverest/openeverest/releases/download/v1.15.1/everestctl-linux-amd64"
      sha256 "3ef3d433dded91c8693a63468bf250afdd53d86366ad8b74b5996b72c0b91097"
    end
    on_arm do
      url "https://github.com/openeverest/openeverest/releases/download/v1.15.1/everestctl-linux-arm64"
      sha256 "72d0dc865964a9729604eafdb43bc2da14f689979940f108f6536893200ae7fd"
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
