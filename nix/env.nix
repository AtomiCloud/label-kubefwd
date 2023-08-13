{ pkgs, packages }:
with packages;
{
  system = [
    coreutils
    bash
    gnugrep
    gnused
    yq-go
  ];

  dev = [
    git
  ];

  infra = [
    helm
    kubectl
    k3d
    docker
  ];

  main = [
    pls
    docker
    jq
    helm
  ];

  lint = [
    # core
    treefmt
    hadolint
    helm-docs
    gitlint
    shellcheck
    sg
  ];

  releaser = [
    node
    sg
    npm
    docker
    helm
  ];

  ci = [
    pls
    docker
    helm
  ];
}
