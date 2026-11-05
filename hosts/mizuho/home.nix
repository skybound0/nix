{ pkgs, ... }:

{
  imports = [ ../../home/desktop.nix ];

  my.desktop.wallpaper = pkgs.fetchurl {
    name = "mizuho-wallpaper-placeholder.png";
    url = "https://thegoose.cloud/apps/files_sharing/publicpreview/ALzEd34YEMtXEpZ?file=/&fileId=808&x=2560&y=1440&a=true&etag=4dc76c354284bd329623b1701c23b9e1";
    hash = "sha256-unOBq9bl2yinwnzSM2JHZVYsEXutkg+FsQNjmZb/9dI=";
  };
  my.desktop.unblank = false;
}
