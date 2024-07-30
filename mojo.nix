{ stdenv, fetchurl, python39, gcc, makeWrapper, curl, version ? "stable" }:

assert version == "stable" || version == "nightly";

stdenv.mkDerivation rec {
  pname = "mojo";
  version = "latest";

  src = fetchurl {
    url = "https://get.modular.com";
    sha256 = "8b67fb2558cda8d7be4a5313b4bbff71ea80f787a9374c9c260f58319f14724f";  # Substitua pelo hash correto
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ python39 gcc curl ];

  installPhase = ''
    mkdir -p $out/bin

    curl -s https://get.modular.com | sh -

    export MOJO_PATH=$HOME/.modular/bin

    if [ "${version}" = "nightly" ]; then
      python3 -m venv mojo-nightly-venv && source mojo-nightly-venv/bin/activate
      modular install nightly/mojo
      MOJO_NIGHTLY_PATH=$(modular config mojo-nightly.path)
      ln -s $MOJO_NIGHTLY_PATH/mojo $out/bin/mojo
      wrapProgram $out/bin/mojo \
        --set MODULAR_HOME $HOME/.modular \
        --prefix PATH : $MOJO_NIGHTLY_PATH
    else
      modular install mojo
      ln -s $MOJO_PATH/mojo $out/bin/mojo
      wrapProgram $out/bin/mojo \
        --set MODULAR_HOME $HOME/.modular \
        --prefix PATH : $MOJO_PATH
    fi
  '';

  meta = with stdenv.lib; {
    description = "Mojo SDK";
    homepage = "https://www.modular.com";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}

