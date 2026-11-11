{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    fuse
    go-mtpfs
  ];

  security.wrappers.fusermount = {
    source = "${pkgs.fuse}/bin/fusermount3";
    setuid = true;
    owner = "root";
    group = "root";
  };
}
