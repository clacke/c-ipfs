{ bootPkgs ? import <nixpkgs> {}
, pinnedPkgsSrc ? bootPkgs.fetchFromGitHub {
    owner = "NixOS"; repo = "nixpkgs-channels";
    rev = "ea145b68a019f6fff89e772e9a6c5f0584acc02c";
    sha256 = "18jr124cbgc5zvawvqvvmrp8lq9jcscmn5sg8f5xap6qbg1dgf22";
  }
, pkgs ? import pinnedPkgsSrc {}
, gccStdenv ? pkgs.gccStdenv
}:

let attrs = rec {
  _sources = {
    c-ipfs = builtins.filterSource (path: type: type != "symlink" || null == builtins.match "result.*" (baseNameOf path)) ./.;
    lmdb = pkgs.fetchFromGitHub {
      name = "lmdb";
      owner = "LMDB"; repo = "lmdb";
      rev = "45a88275d2a410e683bae4ef44881e0f55fa3c4d";
      sha256 = "0vv2qspxl55kzlmm3gqmb71i8m1ji0lxvfx6hql0whzjhsk9p1k6";
    };
    c-protobuf = pkgs.fetchFromGitHub {
      name = "c-protobuf";
      owner = "Agorise"; repo = "c-protobuf";
      rev = "66bb50907112525b128ceb734d7b812fa94d47bf";
      sha256 = "07pafxb1cgqy587vjqchi4v974b7mjbz8msy5xbsk1a9cqw1n728";
    };
    c-multihash = pkgs.fetchFromGitHub {
      name = "c-multihash";
      owner = "Agorise"; repo = "c-multihash";
      rev = "961feef19c0489c1621008859edfe720e52e5364";
      sha256 = "11zhkz35j0q4480bi7mpv9nkgksp6qzngxjiy7qxlsf45nlh0cxi";
    };
    c-multiaddr = pkgs.fetchFromGitHub {
      name = "c-multiaddr";
      owner = "Agorise"; repo = "c-multiaddr";
      rev = "028223e46ab5b15fa1fea5d238414537bd97328f";
      sha256 = "012a7bzl7cm3fmwx3rzpcr20p05vgqc21slcc5dxikgnx6y44qbi";
    };
    c-libp2p = pkgs.fetchFromGitHub {
      name = "c-libp2p";
      owner = "squishyhuman"; repo = "c-libp2p";
      rev = "2e0391f68c65a4255732482f7f463179d6e49a79";
      sha256 = "1mbrdzvr1kp0l65kilf71xwj35765asy3ldv1y034sgl2mmmgram";
    };
  };
  c-ipfs = gccStdenv.mkDerivation {
    name = "c-ipfs";
    srcs = with _sources; [ lmdb c-protobuf c-multihash c-multiaddr c-libp2p _sources.c-ipfs ];
    phases = "unpackPhase buildPhase installPhase fixupPhase";
    sourceRoot = ".";
    buildInputs = [ pkgs.tree pkgs.curl.dev ];
    buildPhase = ''
      for src in $srcs; do
        (
          cd $(stripHash $src)
          while [ ! -e Makefile ]; do cd */; done
          pwd
          tree -L 2
          make all
        )
      done
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp c-ipfs/main/ipfs $out/bin/ipfs
    '';
  };
};
in
attrs.c-ipfs // attrs
