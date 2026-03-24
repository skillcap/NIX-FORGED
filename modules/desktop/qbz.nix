{ pkgs }:

pkgs.rustPlatform.buildRustPackage rec {
  pname = "qbz";
  version = "1.2.0";

  src = pkgs.fetchFromGitHub {
    owner = "vicrodh";
    repo = "qbz";
    rev = "v${version}";
    hash = "sha256-hiadYCBQn2+YFKam4RJ1ae+1JN5mgEjyQVyGnxr8VPA=";
  };

  cargoRoot = "src-tauri";
  buildAndTestSubdir = cargoRoot;
  cargoLock = {
    lockFile = "${src}/src-tauri/Cargo.lock";
  };

  npmDeps = pkgs.fetchNpmDeps {
    name = "${pname}-${version}-npm-deps";
    inherit src;
    hash = "sha256-koLJdbtSgDoCiI+u9lhR/iJ+uY63NbVuDkS+ytLp7Bg=";
  };

  env.LIBCLANG_PATH = "${pkgs.lib.getLib pkgs.llvmPackages.libclang}/lib";

  nativeBuildInputs = with pkgs; [
    clang
    cargo-tauri.hook
    nodejs
    npmHooks.npmConfigHook
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = with pkgs; [
    alsa-lib
    openssl
    webkitgtk_4_1
    glib-networking
    libsecret
    libappindicator-gtk3
    libayatana-appindicator
  ];

  checkFlags = [
    "--skip=credentials::tests::test_credentials_roundtrip"
    "--skip=credentials::tests::test_encryption_roundtrip"
    "--skip=qconnect_service::tests::refreshes_local_renderer_id_from_unique_fingerprint_when_uuid_missing"
  ];

  postInstall = ''
    install -Dm644 ${src}/src-tauri/icons/icon.png $out/share/icons/hicolor/512x512/apps/qbz.png
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --set WEBKIT_DISABLE_DMABUF_RENDERER 1
      --set WEBKIT_DISABLE_COMPOSITING_MODE 1
      --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [ pkgs.libappindicator pkgs.libappindicator-gtk3 pkgs.libayatana-appindicator ]}"
    )
  '';
}
