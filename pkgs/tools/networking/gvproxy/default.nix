{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "gvproxy";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "gvisor-tap-vsock";
    rev = "v${version}";
    hash = "sha256-7WV/PHuZwRnhENolvCAdl9QIQ56B3IvH3n4Db1BvG1o=";
  };

  vendorHash = null;

  buildPhase = ''
    runHook preBuild
    make build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install bin/* -Dt $out/bin
    runHook postInstall
  '';

  meta = with lib; {
    changelog = "https://github.com/containers/gvisor-tap-vsock/releases/tag/${src.rev}";
    description = "Network stack based on gVisor";
    homepage = "https://github.com/containers/gvisor-tap-vsock";
    license = licenses.asl20;
    maintainers = with maintainers; [ ] ++ teams.podman.members;
  };
}
