{
  lib,
  stdenv,
  fetchSteam,
}:
let
  gameInfoFilePath = builtins.fetchurl {
    name = "valheim-manifest-id";
    url = "https://api.steamcmd.net/v1/info/896660";
  };
  gameInfo = lib.importJSON gameInfoFilePath;
in
stdenv.mkDerivation (finalAttrs: {
  name = "valheim-server";
  version = "unknown";
  src = fetchSteam {
    inherit (finalAttrs) name;
    appId = "896660";
    depotId = "896661";
    manifestId = gameInfo.data."896660".depots."896661".manifests.public.download;
    hash = "sha256-8UdoLzKiu8CEztqwTHGP5M3RdrrVUTmAwN6Cqt9R+v8=";
  };

  # Skip phases that don't apply to prebuilt binaries.
  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r \
      *.so \
      *.debug \
      valheim_server.x86_64 \
      valheim_server_Data \
      $out

    chmod +x $out/valheim_server.x86_64

    runHook postInstall
  '';

  meta = with lib; {
    description = "Valheim dedicated server";
    homepage = "https://steamdb.info/app/896660/";
    changelog = "https://store.steampowered.com/news/app/892970?updates=true";
    sourceProvenance = with sourceTypes; [binaryBytecode binaryNativeCode];
    license = licenses.unfree;
    maintainers = with maintainers; [aidalgol];
    platforms = ["x86_64-linux"];
  };
})

