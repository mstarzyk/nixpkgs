{ stdenv, fetchurl, libedit, makeWrapper }:
let
  version = "803";

  name = "j-${version}";
  
  fetch_j = { sha256, bits } : fetchurl {
    url = "http://www.jsoftware.com/download/j${version}/install/j${version}_linux${bits}.tar.gz";
    inherit sha256;
  };

  byLinux = { linux64, linux32 } :
    if stdenv.system == "i686-linux" then linux32
    else if stdenv.system == "x86_64-linux" then linux64
    else throw "platform ${stdenv.system} not supported!";

  bits = byLinux { linux64 = "64"; linux32 = "32"; };

  libPath = stdenv.lib.makeLibraryPath [ stdenv.gcc.libc libedit2 ];

  fixInterpreter = file: ''
    patchelf --interpreter "$(cat $NIX_GCC/nix-support/dynamic-linker)" ${file}
  '';

  fixRpath = file: ''
    patchelf --set-rpath ${libPath} ${file}
  '';

  libedit2 = stdenv.mkDerivation rec {
    name = "libedit.so.2";

    phases = "installPhase";

    buildInputs = [ libedit ];

    installPhase = ''
      mkdir -p $out/lib
      ln -s ${libedit}/lib/libedit.so $out/lib/libedit.so.2
    '';
  };
in
stdenv.mkDerivation rec {
  inherit name version;

  buildInputs = [ libedit2 ];

  src = byLinux {
    linux32 = fetch_j {
      bits = "32";
      sha256 = "19x21dbvck213lq9chi6j8lxiv611ji5347y00w3fvixipr4gnx5";
    };
    linux64 = fetch_j {
      bits = "64";
      sha256 = "03z04ld379mjrk1zpsphnfkdfdnqwmzmwnyjjwiwpppn72b2mmp0";
    };
  };

  phases = "unpackPhase installPhase fixupPhase";

  installPhase = ''
      mkdir -p $out
      cp -R * $out
    '';

  fixupPhase = ''
      ${fixInterpreter "$out/bin/jconsole"}
      ${fixRpath "$out/bin/jconsole"}
      ${fixRpath "$out/bin/libj.so"}
    '';

  meta = {
    description = "J programming language, an ASCII-based APL successor";
    maintainers = [ stdenv.lib.maintainers.raskin ];
    platforms = stdenv.lib.platforms.linux;
    license = stdenv.lib.licenses.gpl3Plus;
    homepage = http://jsoftware.com/;
  };
}
