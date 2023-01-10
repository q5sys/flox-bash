{
  description = "flox environment";
  inputs.flox-floxpkgs.url = "github:flox/floxpkgs";

  outputs = args @ {flox-floxpkgs, ...}:
    flox-floxpkgs.project args (_: {
      config.extraPlugins = [
        (flox-floxpkgs.capacitor.plugins.localResources {
          type = "packages";
          dir = ./pkgs;
        })
        (flox-floxpkgs.plugins.floxEnvs {
          sourceType = "packages";
          dir = ./pkgs;
        })
      ];
    });
}
