{
  config,
  pkgs,
  inputs,
  ...
}:
{
  #only laptop specific home stuff, everything else in default.nix

  services.mpris-proxy.enable = true;
  home.packages = [
    pkgs.brightnessctl
    (pkgs.writeShellApplication {
      name = "power-profile-cycle";
      runtimeInputs = with pkgs; [
        power-profiles-daemon
        libnotify
      ];
      text = builtins.readFile ./scripts/power-profile-cycle.sh;
    })
  ];

  xdg.configFile."quickshell" = {
    source = ./config/quickshell;
    recursive = true;
  };

  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${
        inputs.quickshell.packages.${pkgs.system}.default
      }/bin/quickshell -p /home/kaarlo/.config/quickshell/laptop.qml"; # prob shouldn't hardcode but whatever
      Restart = "on-failure";
      RestartSec = 2;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

}
