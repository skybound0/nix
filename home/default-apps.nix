{ lib, ... }:

let
  assoc = app: types: lib.genAttrs types (_: app);

  files = "org.gnome.Nautilus.desktop";
  images = "org.gnome.Loupe.desktop";
  documents = "org.gnome.Papers.desktop";
  media = "org.gnome.Showtime.desktop";
  editor = "code.desktop";
  mail = "co.hyprlab.Hylki.desktop";
  calendar = "org.gnome.Calendar.desktop";
  slicer = "BambuStudio.desktop";
in
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      assoc files [ "inode/directory" ]
      // assoc images [
        "image/png"
        "image/jpeg"
        "image/gif"
        "image/webp"
        "image/bmp"
        "image/tiff"
        "image/avif"
        "image/heif"
        "image/heic"
        "image/jxl"
        "image/svg+xml"
        "image/x-icon"
      ]
      // assoc documents [
        "application/pdf"
        "image/vnd.djvu"
        "application/postscript"
        "application/x-cbz"
        "application/vnd.comicbook+zip"
      ]
      // assoc media [
        "video/mp4"
        "video/webm"
        "video/x-matroska"
        "video/quicktime"
        "video/x-msvideo"
        "video/mpeg"
        "video/ogg"
        "audio/mpeg"
        "audio/flac"
        "audio/ogg"
        "audio/opus"
        "audio/wav"
        "audio/x-wav"
        "audio/aac"
        "audio/mp4"
        "audio/x-m4a"
      ]
      // assoc editor [
        "text/plain"
        "text/markdown"
        "text/x-nix"
        "text/x-python"
        "text/x-csrc"
        "text/x-chdr"
        "text/x-c++src"
        "text/x-shellscript"
        "application/x-shellscript"
        "application/json"
        "application/toml"
        "application/x-yaml"
        "application/xml"
      ]
      // assoc mail [
        "x-scheme-handler/mailto"
        "message/rfc822"
        "application/vnd.ms-outlook"
      ]
      // assoc calendar [ "text/calendar" ]
      // assoc "writer.desktop" [
        "application/vnd.oasis.opendocument.text"
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        "application/msword"
        "application/rtf"
      ]
      // assoc "calc.desktop" [
        "application/vnd.oasis.opendocument.spreadsheet"
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        "application/vnd.ms-excel"
        "text/csv"
      ]
      // assoc "impress.desktop" [
        "application/vnd.oasis.opendocument.presentation"
        "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        "application/vnd.ms-powerpoint"
      ]
      // assoc slicer [
        "model/stl"
        "model/3mf"
        "application/vnd.ms-3mfdocument"
      ]
      // {
        "x-scheme-handler/beeper" = "beepertexts.desktop";
        "x-scheme-handler/discord" = "vesktop.desktop";
        "x-scheme-handler/sms" = "org.gnome.Shell.Extensions.GSConnect.desktop";
        "x-scheme-handler/tel" = "org.gnome.Shell.Extensions.GSConnect.desktop";
      };
  };

  xdg.configFile."mimeapps.list".force = true;
  xdg.dataFile."applications/mimeapps.list".force = true;

  xdg.terminal-exec = {
    enable = true;
    settings.default = [ "com.mitchellh.ghostty.desktop" ];
  };
}
