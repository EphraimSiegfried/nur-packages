{
  lib,
  buildGoModule,
  buildNpmPackage,
  fetchFromGitHub,
}:

let
  pname = "bindery";
  version = "1.2.6";

  src = fetchFromGitHub {
    owner = "vavallee";
    repo = "bindery";
    rev = "v${version}";
    hash = "sha256-LR/guE19nd2411Ale/8Afn+TRx8p2lv2LF9Ulcv1CTc=";
  };

  frontend = buildNpmPackage {
    pname = "${pname}-web";
    inherit version src;
    sourceRoot = "${src.name}/web";
    npmDepsHash = "sha256-Zi3kPqRkvkLggaRdzM/graydwn2to7JCaYjOOOzMqXI=";
    installPhase = ''
      runHook preInstall
      cp -r dist $out
      runHook postInstall
    '';
  };
in

buildGoModule {
  inherit pname version src;

  vendorHash = "sha256-tpXM/vsHCiobw8vgJgWI2sOOQKHQT8F47Zodv8eJkPg=";

  postPatch = ''
    sed -i 's/go 1.25.9/go 1.25.0/' go.mod
  '';

  preBuild = ''
    cp -r ${frontend}/* internal/webui/dist/
  '';

  subPackages = [ "cmd/bindery" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
    "-X main.commit=nixpkgs"
    "-X main.date=1970-01-01T00:00:00Z"
  ];

  meta = {
    description = "Automated book download manager for Usenet and torrents";
    homepage = "https://github.com/vavallee/bindery";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "bindery";
  };
}
