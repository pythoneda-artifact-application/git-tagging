{
  description = "Application layer for pythoneda-artifact/git-tagging";

  inputs = rec {
    nixos.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    pythoneda-base = {
      url = "github:pythoneda/base/0.0.1a15";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
    };
    pythoneda-artifact-git-tagging = {
      url = "github:pythoneda-artifact/git-tagging/0.0.1a3";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-base.follows = "pythoneda-base";
    };
    pythoneda-infrastructure-base = {
      url = "github:pythoneda-infrastructure/base/0.0.1a11";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-base.follows = "pythoneda-base";
    };
    pythoneda-artifact-infrastructure-git-tagging = {
      url = "github:pythoneda-artifact-infrastructure/git-tagging/0.0.1a3";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-base.follows = "pythoneda-base";
      inputs.pythoneda-artifact-git-tagging.follows =
        "pythoneda-artifact-git-tagging";
      inputs.pythoneda-infrastructure-base.follows =
        "pythoneda-infrastructure-base";
    };
    pythoneda-application-base = {
      url = "github:pythoneda-application/base/0.0.1a11";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-base.follows = "pythoneda-base";
      inputs.pythoneda-infrastructure-base.follows =
        "pythoneda-infrastructure-base";
    };
  };
  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixos { inherit system; };
        description = "Application layer for pythoneda-artifact/git-tagging";
        license = pkgs.lib.licenses.gpl3;
        homepage =
          "https://github.com/pythoneda-artifact-application/git-tagging";
        maintainers = with pkgs.lib.maintainers; [ ];
        nixpkgsRelease = "nixos-23.05";
        shared = import ./nix/devShells.nix;
        pythoneda-artifact-application-git-tagging-for = { version
          , pythoneda-base, pythoneda-artifact-git-tagging
          , pythoneda-infrastructure-base
          , pythoneda-artifact-infrastructure-git-tagging
          , pythoneda-application-base, python }:
          let
            pname = "pythoneda-artifact-application-git-tagging";
            pythonVersionParts = builtins.splitVersion python.version;
            pythonMajorVersion = builtins.head pythonVersionParts;
            pythonMajorMinorVersion =
              "${pythonMajorVersion}.${builtins.elemAt pythonVersionParts 1}";
            pnameWithUnderscores =
              builtins.replaceStrings [ "-" ] [ "_" ] pname;
            wheelName =
              "${pnameWithUnderscores}-${version}-py${pythonMajorVersion}-none-any.whl";
          in python.pkgs.buildPythonPackage rec {
            inherit pname version;
            projectDir = ./.;
            src = ./.;
            format = "pyproject";

            nativeBuildInputs = with python.pkgs; [ pip pkgs.jq poetry-core ];
            propagatedBuildInputs = with python.pkgs; [
              pythoneda-base
              pythoneda-artifact-git-tagging
              pythoneda-infrastructure-base
              pythoneda-application-base
              pythoneda-artifact-infrastructure-git-tagging
            ];

            checkInputs = with python.pkgs; [ pytest ];

            pythonImportsCheck =
              [ "pythonedaartifactinfrastructuregittagging" ];

            preBuild = ''
              python -m venv .env
              source .env/bin/activate
              pip install ${pythoneda-base}/dist/pythoneda_base-${pythoneda-base.version}-py3-none-any.whl
              pip install ${pythoneda-artifact-git-tagging}/dist/pythoneda_artifact_git_tagging-${pythoneda-artifact-git-tagging.version}-py3-none-any.whl
              pip install ${pythoneda-infrastructure-base}/dist/pythoneda_infrastructure_base-${pythoneda-infrastructure-base.version}-py3-none-any.whl
              pip install ${pythoneda-artifact-infrastructure-git-tagging}/dist/pythoneda_artifact_infrastructure_git_tagging-${pythoneda-artifact-infrastructure-git-tagging.version}-py3-none-any.whl
              pip install ${pythoneda-application-base}/dist/pythoneda_application_base-${pythoneda-application-base.version}-py3-none-any.whl
              rm -rf .env
            '';

            postInstall = ''
              mkdir $out/dist
              cp dist/${wheelName} $out/dist
              jq ".url = \"$out/dist/${wheelName}\"" $out/lib/python${pythonMajorMinorVersion}/site-packages/${pnameWithUnderscores}-${version}.dist-info/direct_url.json > temp.json && mv temp.json $out/lib/python${pythonMajorMinorVersion}/site-packages/${pnameWithUnderscores}-${version}.dist-info/direct_url.json
            '';

            meta = with pkgs.lib; {
              inherit description homepage license maintainers;
            };
          };
        pythoneda-artifact-application-git-tagging-0_0_1a3-for =
          { pythoneda-base, pythoneda-artifact-git-tagging
          , pythoneda-infrastructure-base
          , pythoneda-artifact-infrastructure-git-tagging
          , pythoneda-application-base, python }:
          pythoneda-artifact-application-git-tagging-for {
            version = "0.0.1a3";
            inherit pythoneda-base pythoneda-artifact-git-tagging
              pythoneda-infrastructure-base
              pythoneda-artifact-infrastructure-git-tagging
              pythoneda-application-base python;
          };
      in rec {
        packages = rec {
          pythoneda-artifact-application-git-tagging-0_0_1a3-python38 =
            pythoneda-artifact-application-git-tagging-0_0_1a3-for {
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python38;
              pythoneda-artifact-git-tagging =
                pythoneda-artifact-git-tagging.packages.${system}.pythoneda-artifact-git-tagging-latest-python38;
              pythoneda-infrastructure-base =
                pythoneda-infrastructure-base.packages.${system}.pythoneda-infrastructure-base-latest-python38;
              pythoneda-artifact-infrastructure-git-tagging =
                pythoneda-artifact-infrastructure-git-tagging.packages.${system}.pythoneda-artifact-infrastructure-git-tagging-latest-python38;
              pythoneda-application-base =
                pythoneda-application-base.packages.${system}.pythoneda-application-base-latest-python38;
              python = pkgs.python38;
            };
          pythoneda-artifact-application-git-tagging-0_0_1a3-python39 =
            pythoneda-artifact-application-git-tagging-0_0_1a3-for {
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python39;
              pythoneda-artifact-git-tagging =
                pythoneda-artifact-git-tagging.packages.${system}.pythoneda-artifact-git-tagging-latest-python39;
              pythoneda-infrastructure-base =
                pythoneda-infrastructure-base.packages.${system}.pythoneda-infrastructure-base-latest-python39;
              pythoneda-artifact-infrastructure-git-tagging =
                pythoneda-artifact-infrastructure-git-tagging.packages.${system}.pythoneda-artifact-infrastructure-git-tagging-latest-python39;
              pythoneda-application-base =
                pythoneda-application-base.packages.${system}.pythoneda-application-base-latest-python39;
              python = pkgs.python39;
            };
          pythoneda-artifact-application-git-tagging-0_0_1a3-python310 =
            pythoneda-artifact-application-git-tagging-0_0_1a3-for {
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python310;
              pythoneda-artifact-git-tagging =
                pythoneda-artifact-git-tagging.packages.${system}.pythoneda-artifact-git-tagging-latest-python310;
              pythoneda-infrastructure-base =
                pythoneda-infrastructure-base.packages.${system}.pythoneda-infrastructure-base-latest-python310;
              pythoneda-artifact-infrastructure-git-tagging =
                pythoneda-artifact-infrastructure-git-tagging.packages.${system}.pythoneda-artifact-infrastructure-git-tagging-latest-python310;
              pythoneda-application-base =
                pythoneda-application-base.packages.${system}.pythoneda-application-base-latest-python310;
              python = pkgs.python310;
            };
          pythoneda-artifact-application-git-tagging-latest-python38 =
            pythoneda-artifact-application-git-tagging-0_0_1a3-python38;
          pythoneda-artifact-application-git-tagging-latest-python39 =
            pythoneda-artifact-application-git-tagging-0_0_1a3-python39;
          pythoneda-artifact-application-git-tagging-latest-python310 =
            pythoneda-artifact-application-git-tagging-0_0_1a3-python310;
          pythoneda-artifact-application-git-tagging-latest =
            pythoneda-artifact-application-git-tagging-latest-python310;
          default = pythoneda-artifact-application-git-tagging-latest;
        };
        defaultPackage = packages.default;
        devShells = rec {
          pythoneda-artifact-application-git-tagging-0_0_1a3-python38 =
            shared.devShell-for {
              package =
                packages.pythoneda-artifact-application-git-tagging-0_0_1a3-python38;
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python38;
              python = pkgs.python38;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-artifact-application-git-tagging-0_0_1a3-python39 =
            shared.devShell-for {
              package =
                packages.pythoneda-artifact-application-git-tagging-0_0_1a3-python39;
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python39;
              python = pkgs.python39;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-artifact-application-git-tagging-0_0_1a3-python310 =
            shared.devShell-for {
              package =
                packages.pythoneda-artifact-application-git-tagging-0_0_1a3-python310;
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python310;
              python = pkgs.python310;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-artifact-application-git-tagging-latest-python38 =
            pythoneda-artifact-application-git-tagging-0_0_1a3-python38;
          pythoneda-artifact-application-git-tagging-latest-python39 =
            pythoneda-artifact-application-git-tagging-0_0_1a3-python39;
          pythoneda-artifact-application-git-tagging-latest-python310 =
            pythoneda-artifact-application-git-tagging-0_0_1a3-python310;
          pythoneda-artifact-application-git-tagging-latest =
            pythoneda-artifact-application-git-tagging-latest-python310;
          default = pythoneda-artifact-application-git-tagging-latest;

        };
      });
}
