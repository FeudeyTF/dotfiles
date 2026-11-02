{ pkgs, ... }: {

  nixpkgs.config.allowUnfreePackages = [
    "cloudflare-warp"
  ];

  services.cloudflare-warp.enable = true;

  environment.systemPackages = with pkgs; [
    cloudflare-warp
  ];

}
