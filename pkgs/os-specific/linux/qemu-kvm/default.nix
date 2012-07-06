{ stdenv, fetchurl, attr, zlib, SDL, alsaLib, pkgconfig, pciutils, libuuid, vde2
, libjpeg, libpng, ncurses, python, glib, libaio, mesa }:

assert stdenv.isLinux;

let version = "1.1.0"; in

stdenv.mkDerivation rec {
  name = "qemu-kvm-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/kvm/qemu-kvm/${version}/${name}.tar.gz";
    sha256 = "1gzch3yshq7yirc5k3cn0m3ibd6qbl2hvl1lbh7lychfc7s4a963";
  };

  patches = [ ./smb-tmpdir.patch ];

  postPatch =
    '' for i in $(find . -type f)
       do
         sed -i "$i" \
             -e 's|/bin/bash|/bin/sh|g ;
                 s|/usr/bin/python|${python}/bin/python|g ;
                 s|/bin/rm|rm|g'
       done
    '';

  configureFlags =
    [ "--audio-drv-list=alsa"
      "--smbd=smbd"                               # use `smbd' from $PATH
    ];

  enableParallelBuilding = true;

  buildInputs =
    [ attr zlib SDL alsaLib pkgconfig pciutils libuuid vde2 libjpeg libpng
      ncurses python glib libaio mesa
    ];

  postInstall =
    ''
      # Libvirt expects us to be called `qemu-kvm'.  Otherwise it will
      # set the domain type to "qemu" rather than "kvm", which can
      # cause architecture selection to misbehave.
      ln -sv $(cd $out/bin && echo qemu-system-*) $out/bin/qemu-kvm
    '';

  meta = {
    homepage = http://www.linux-kvm.org/;
    description = "A full virtualization solution for Linux on x86 hardware containing virtualization extensions";
    platforms = stdenv.lib.platforms.linux;
  };
}
