{ pkgs, ... }:

{
  my.desktop.wallpaper = pkgs.fetchurl {
    name = "nozomi-wallpaper.png";
    url = "https://thegoose.cloud/apps/files_sharing/publicpreview/KxE95nD6qKaEs2R?file=/&fileId=646&x=2256&y=1504&a=true&etag=a8774b83fbdae6cd3e1e6df1c8663408";
    hash = "sha256-aoKHI9n02Gki1ISEyrWW1C/hRoqhmgr2BK6ugng7XjI=";
  };
  my.desktop.unblank = true;
  my.desktop.lockscreenFingerprint = true;
}
