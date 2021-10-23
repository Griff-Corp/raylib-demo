
let
  pypiDataRev="21786f91715b3e07fa1a5c67ea3ee01f86843e5a";
  #pypiDataSha256="1dj7dg4j0qn9a47aw9fqq4wy9as9f86xbms90mpyyqs0i8g1awjz"; ## Fri Oct 22 20:31:08 UTC 2021 # DavHau/pypi-deps-db
  mach-nix = import (builtins.fetchGit {
    url = "https://github.com/DavHau/mach-nix/";
    ref = "3.3.0";
  }) {
    inherit pypiDataRev;# pypiDataSha256;
  };
  pkgs =  mach-nix.nixpkgs;
  raylib-py = mach-nix.buildPythonPackage {
    src = builtins.fetchGit{
      url = "https://github.com/adamlwgriffiths/raylib-py";
      ref = "master";
      # rev = "put_commit_hash_here";
    };
  };
  raylib-py-flat = mach-nix.buildPythonPackage {
    src = builtins.fetchGit{
      url = "https://github.com/adamlwgriffiths/raylib-py-flat";
      ref = "master";
      # rev = "put_commit_hash_here";
    };
  };
  custom-python = mach-nix.mkPython {
    python = "python38";
    requirements = ''
      PyOpenGL
      PyOpenGL_accelerate
      ipython
    '';
    packagesExtra = [
      raylib-py
      raylib-py-flat
    ];
    providers = {
      _default = "nixpkgs,wheel,sdist";
      # fix for pyopengl not working from pypi
      # https://github.com/NixOS/nixpkgs/issues/76822
      PyOpenGL = "nixpkgs";
      PyOpenGL_accelerate = "nixpkgs";
    };
  };
  raylib = pkgs.callPackage ./nix/raylib/default.nix {};
in pkgs.mkShell {
  buildInputs = with pkgs; [
    # just for testing
    raylib
    custom-python
  ];

  shellHook = ''
    export LD_LIBRARY_PATH="$(pwd)/lib:${raylib}/lib:$LD_LIBRARY_PATH"
    export USE_EXTERNAL_RAYLIB=
  '';
}
