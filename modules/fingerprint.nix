{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.fprintd.enable = true;
  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id.indexOf("net.reactivated.fprint.") == 0 &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';
  security.pam.services.sudo.fprintAuth = true;
  security.pam.services.swaylock.fprintAuth = true;
  security.pam.services.login.fprintAuth = true;
  # security.pam.services.sddm.fprintAuth = true;
  security.pam.services.sddm.fprintAuth = false; # was true — this is your real login path

  security.pam.services.polkit.fprintAuth = true;

}
