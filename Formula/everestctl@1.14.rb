class EverestctlAT114 < Formula
  desc "CLI tool for provisioning and managing OpenEverest on Kubernetes"
  homepage "https://github.com/openeverest/openeverest"
  version "1.14.0"
  license "Apache-2.0"

  keg_only :versioned_formula

  on_macos do
    on_intel do
      url "https://github.com/openeverest/openeverest/releases/download/v1.14.0/everestctl-darwin-amd64"
      sha256 "ac90d8502e4168266281822976843ddb81ed605fb202936342e2e38cd99722e0"
    end
    on_arm do
      url "https://github.com/openeverest/openeverest/releases/download/v1.14.0/everestctl-darwin-arm64"
      sha256 "499202c10d8c3665dcc6d3408ca5632f44302b7cb86b91c3b49e2f0e0da6142a"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/openeverest/openeverest/releases/download/v1.14.0/everestctl-linux-amd64"
      sha256 "322d4d3b8bd7953dcd3d34cfa74010c3b049cc6a9f19e7319fbe39be8afedb4e"
    end
    on_arm do
      url "https://github.com/openeverest/openeverest/releases/download/v1.14.0/everestctl-linux-arm64"
      sha256 "0255b5c792072f5189d066b96797f4023110b2547785a7025882f1fa5df2500a"
    end
  end

  def install
    os = OS.mac? ? "darwin" : "linux"
    arch = Hardware::CPU.arm? ? "arm64" : "amd64"
    bin.install "everestctl-#{os}-#{arch}" => "everestctl"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/everestctl version 2>&1")
  end
end
