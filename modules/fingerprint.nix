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
  security.pam.services.sddm.fprintAuth = true;
  security.pam.services.polkit.fprintAuth = true;
  security.pam.services.login.enableGnomeKeyring = true; # see https://wiki.nixos.org/wiki/Secret_Service#Auto-decrypt_on_login

}
