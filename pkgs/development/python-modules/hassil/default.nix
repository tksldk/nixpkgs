{ lib
, buildPythonPackage
, fetchPypi

# build
, antlr4

# propagates
, antlr4-python3-runtime
, dataclasses-json
, pyyaml

# tests
, pytestCheckHook
}:

let
  pname = "hassil";
  version = "1.0.5";
in
buildPythonPackage {
  inherit pname version;
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Rq7jGCArEhYPGw/0XCiT07+ceDzr7BbwG8SxKH7yXzQ=";
  };

  nativeBuildInputs = [
    antlr4
  ];

  postPatch = ''
    sed -i 's/antlr4-python3-runtime==.*/antlr4-python3-runtime/' requirements.txt
    rm hassil/grammar/*.{tokens,interp}
    antlr -Dlanguage=Python3 -visitor -o hassil/grammar/ *.g4
  '';

  propagatedBuildInputs = [
    antlr4-python3-runtime
    dataclasses-json
    pyyaml
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  meta = with lib; {
    changelog  = "https://github.com/home-assistant/hassil/releases/tag/v${version}";
    description = "Intent parsing for Home Assistant";
    homepage = "https://github.com/home-assistant/hassil";
    license = licenses.asl20;
    maintainers = teams.home-assistant.members;
  };
}
