{
  imgui,
  lib,
  pkgs,
  ...
}:
pkgs.clangStdenv.mkDerivation {

  pname = "openstarbound";
  version = "0.1.14";

  src = pkgs.fetchFromGitHub {
    owner = "OpenStarbound";
    repo = "OpenStarbound";
    rev = "cd2d804f6feaa4c588df822f01eb5504ebd4ba55";
    fetchSubmodules = false;
    hash = "sha256-dwZgsMYPsIxdokdkMhwvdM3GIC9YJhJeP8oH47IB1BA=";
  };

  sourceRoot = "source/source";

  nativeBuildInputs = with pkgs; [
    cmake
    icoutils
    imagemagick
    pkg-config
  ];

  buildInputs =
    with pkgs;
    [
      cpptrace
      freetype
      glew
      jemalloc
      libcpr
      libopus
      libpng
      libsm
      libvorbis
      libxi
      re2
      sdl3
      unzip
      zlib
      zstd
    ]
    ++ lib.optionals (imgui != null) [ imgui ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_BUILD_TYPE" "Release")
    (lib.cmakeBool "STAR_USE_JEMALLOC" true)
  ];

  postPatch = ''
    cp ${./patches/CMakeLists.txt} CMakeLists.txt 2>/dev/null || true
    mkdir -p dist || true

    substituteInPlace core/StarFormat.hpp \
      --replace-fail \
        'try { return fmt::format(fmt, args...); }' \
        'try { return fmt::vformat(fmt, fmt::make_format_args(args...)); }' \
      --replace-fail \
        'format(std::cout, fmt, args...);' \
        'std::cout << fmt::vformat(fmt, fmt::make_format_args(args...));' \
      --replace-fail \
        'format(std::cerr, fmt, args...);' \
        'std::cerr << fmt::vformat(fmt, fmt::make_format_args(args...));'
  '';

  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin/ $out/libexec

    cp  -r ../dist/* $out/libexec >/dev/null 2>&1 || true

    if [ -f ../dist/starbound ]; then
        install -Dm755 ../dist/starbound $out/bin/starbound
    fi

    if [ -f ../dist/starbound_server ]; then
        install -Dm755 ../dist/starbound_server $out/bin/starbound_server
    fi

    mkdir -p $out/assets/
    if [ -d ../../assets ]; then
        cp -r ../../assets/opensb $out/assets/opensb
    fi

    runHook postInstall
  '';

}
