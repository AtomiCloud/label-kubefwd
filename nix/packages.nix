{ pkgs, atomi, atomi_classic, pkgs-2305, pkgs-aug-01-23 }:
let
  all = {
    atomipkgs_classic = (
      with atomi_classic;
      {
        inherit
          sg;
      }
    );
    atomipkgs = (
      with atomi;
      {
        inherit
          pls;
      }
    );
    nix-2305 = (
      with pkgs-2305;
      {
        inherit
          k3d;
      }
    );
    aug-01-23 = (
      with pkgs-aug-01-23;
      {
        inherit
          coreutils
          sd
          bash
          git
          yq-go
          jq
          gnused
          gnugrep

          # lint
          treefmt
          helm-docs
          gitlint
          hadolint
          shellcheck

          #infra

          kubectl
          docker;
        helm = kubernetes-helm;
        npm = nodePackages.npm;
        node = nodejs_18;
      }
    );
  };
in
with all;
atomipkgs //
atomipkgs_classic //
nix-2305 //
aug-01-23
