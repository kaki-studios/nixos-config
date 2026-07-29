{
  config,
  pkgs,
  inputs,
  ...
}:
{

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
      }/bin/quickshell -p /home/kaarlo/.config/quickshell/desktop.qml";
      Restart = "on-failure";
      RestartSec = 2;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

}
