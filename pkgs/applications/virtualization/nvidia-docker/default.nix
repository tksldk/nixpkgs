{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, callPackage
, makeWrapper
, buildGoModule
, buildGoPackage
, glibc
, docker
, linkFarm
}:

with lib; let
  nvidia-container-toolkit = buildGoModule rec {
    pname = "nvidia-container-toolkit";
    version = "1.3.0";
    src = fetchFromGitHub {
      owner = "NVIDIA";
      repo = "nvidia-container-toolkit";
      rev = "v${version}";
      sha256 = "04284bhgx4j55vg9ifvbji2bvmfjfy3h1lq7q356ffgw3yr9n0hn";
    };
    vendorSha256 = "17zpiyvf22skfcisflsp6pn56y6a793jcx89kw976fq2x5br1bz7";
    buildFlagsArray = [ "-ldflags=" "-s -w" ];
    postInstall = ''
      mv $out/bin/{pkg,${pname}}
      cp $out/bin/{${pname},nvidia-container-runtime-hook}
    '';
  };

in
stdenv.mkDerivation rec {
  pname = "nvidia-docker";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = pname;
    rev = "v${version}";
    sha256 = "1n1k7fnimky67s12p2ycaq9mgk245fchq62vgd7bl3bzfcbg0z4h";
  };

  buildPhase = ''
    mkdir bin

    cp nvidia-docker bin
    substituteInPlace bin/nvidia-docker --subst-var-by VERSION ${version}

    cp ${nvidia-container-toolkit}/bin/nvidia-container-{toolkit,runtime-hook} bin
  '';

  installPhase = ''
    mkdir -p $out/{bin,etc}
    cp -r bin $out

    cp ${./config.toml} $out/etc/config.toml
    substituteInPlace $out/etc/config.toml --subst-var-by glibcbin ${lib.getBin glibc}

    cp ${./podman-config.toml} $out/etc/podman-config.toml
    substituteInPlace $out/etc/podman-config.toml --subst-var-by glibcbin ${lib.getBin glibc}
  '';

  meta = {
    homepage = "https://github.com/NVIDIA/nvidia-docker";
    description = "NVIDIA container runtime for Docker";
    license = licenses.bsd3;
    platforms = platforms.linux;
    maintainers = with lib.maintainers; [ cpcloud ];
  };
}
