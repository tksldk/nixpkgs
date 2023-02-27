{ lib
, fetchPypi
, buildPythonPackage
, pythonOlder

# build time
, astropy-extension-helpers
, astropy-helpers
, cython
, jinja2
, setuptools-scm

# runtime
, numpy
, packaging
, pyerfa
, pyyaml
}:

let
  pname = "astropy";
  version = "5.2.1";
in
buildPythonPackage {
  inherit pname version;
  format = "pyproject";

  disabled = pythonOlder "3.8"; # according to setup.cfg

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-9q4noHf46oSQPvp2x5C5hWFzQaAISw0hw5H3o/MyrCM=";
  };

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  nativeBuildInputs = [
    astropy-extension-helpers
    astropy-helpers
    cython
    jinja2
    setuptools-scm
  ];

  propagatedBuildInputs = [
    numpy
    packaging
    pyerfa
    pyyaml
  ];

  # infinite recursion with pytest-astropy (pytest-astropy-header depends on astropy itself)
  doCheck = false;

  meta = with lib; {
    description = "Astronomy/Astrophysics library for Python";
    homepage = "https://www.astropy.org";
    license = licenses.bsd3;
    platforms = platforms.all;
    maintainers = [ maintainers.kentjames ];
  };
}
