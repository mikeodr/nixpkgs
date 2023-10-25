{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "scalingo";
  version = "1.29.1";

  src = fetchFromGitHub {
    owner = pname;
    repo = "cli";
    rev = version;
    sha256 = "sha256-xBf+LIwlpauJd/0xJIQdfEa0rxph3BJPuMY4+0s+Bb4=";
  };

  vendorHash = null;

  preConfigure = ''
    export HOME=$TMPDIR
  '';

  meta = with lib; {
    description = "Command line client for the Scalingo PaaS";
    homepage = "https://doc.scalingo.com/platform/cli/start";
    changelog = "https://github.com/Scalingo/cli/blob/master/CHANGELOG.md";
    license = licenses.bsdOriginal;
    maintainers = with maintainers; [ cimm ];
    platforms = with lib.platforms; unix;
  };
}
