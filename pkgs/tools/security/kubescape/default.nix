{ lib
, buildGoModule
, fetchFromGitHub
, installShellFiles
}:

buildGoModule rec {
  pname = "kubescape";
  version = "2.2.3";

  src = fetchFromGitHub {
    owner = "armosec";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-qb8Kk+d3KFf+GVHv6Tg1qBuX6xFS4zbpkCPc502alxU=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-KoAuM1H9FRcPLD0AipnXOCUiNHcCWnek4sV0ztu5SyI=";

  nativeBuildInputs = [
    installShellFiles
  ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/armosec/kubescape/v2/core/cautils.BuildNumber=v${version}"
  ];

  subPackages = [ "." ];

  preCheck = ''
    # Feed in all but the integration tests for testing
    # This is because subPackages above limits what is built to just what we
    # want but also limits the tests
    # Skip httphandler tests - the checkPhase doesn't care about excludedPackages
    getGoDirs() {
      go list ./... | grep -v httphandler
    }

    # remove tests that use networking
    rm core/pkg/resourcehandler/urlloader_test.go
    rm core/pkg/opaprocessor/*_test.go

    # remove tests that use networking
    substituteInPlace core/pkg/resourcehandler/repositoryscanner_test.go \
      --replace "TestScanRepository" "SkipScanRepository" \
      --replace "TestGit" "SkipGit"

    # remove test that requires networking
    substituteInPlace core/cautils/scaninfo_test.go \
      --replace "TestSetContextMetadata" "SkipSetContextMetadata"
  '';

  postInstall = ''
    installShellCompletion --cmd kubescape \
      --bash <($out/bin/kubescape completion bash) \
      --fish <($out/bin/kubescape completion fish) \
      --zsh <($out/bin/kubescape completion zsh)
  '';

  meta = with lib; {
    description = "Tool for testing if Kubernetes is deployed securely";
    homepage = "https://github.com/armosec/kubescape";
    changelog = "https://github.com/armosec/kubescape/releases/tag/v${version}";
    longDescription = ''
      Kubescape is the first open-source tool for testing if Kubernetes is
      deployed securely according to multiple frameworks: regulatory, customized
      company policies and DevSecOps best practices, such as the NSA-CISA and
      the MITRE ATT&CK®.
      Kubescape scans K8s clusters, YAML files, and HELM charts, and detect
      misconfigurations and software vulnerabilities at early stages of the
      CI/CD pipeline and provides a risk score instantly and risk trends over
      time. Kubescape integrates natively with other DevOps tools, including
      Jenkins, CircleCI and Github workflows.
    '';
    license = licenses.asl20;
    maintainers = with maintainers; [ fab jk ];
  };
}
