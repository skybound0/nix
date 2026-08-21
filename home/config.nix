{ pkgs, ... }:

{
  home.username = "skybound";
  home.homeDirectory = "/home/skybound";
  home.stateVersion = "26.11";
  programs.home-manager.enable = true;

  catppuccin = {
    enable = true;
    autoEnable = true;
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      telescope-nvim
      nvim-treesitter.withAllGrammars
      nvim-lspconfig
      gitsigns-nvim
      lualine-nvim
      which-key-nvim
      comment-nvim
      nvim-autopairs
      oil-nvim
    ];
  };
  home.sessionVariables.EDITOR = "nvim";
  
  programs.git = {
    enable = true;
    settings = {
      user.name = "skybound0";
      user.email = "tianchenggu@outlook.com";
      init.defaultBranch = "main";
      pull.rebase = false;
      core.editor = "nvim";
      alias = {
        st = "status";
	co = "checkout";
	lg = "log --oneline --graph --decorate";
      };
    };
  };

  # hide nvim.desktop 
  xdg.desktopEntries."nvim" = {
    name = "Neovim";
    noDisplay = true;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
    '';
    plugins = [
      { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
      { name = "autopair"; src = pkgs.fishPlugins.autopair.src; }
    ];
  };

  programs.starship.enable = true;

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
  };

  # bridge for the bitwarden browser extension
  home.file.".mozilla/native-messaging-hosts/com.8bit.bitwarden.json".text = builtins.toJSON {
    name = "com.8bit.bitwarden";
    description = "Bitwarden desktop <-> browser bridge";
    path = "/etc/profiles/per-user/skybound/bin/bitwarden";
    type = "stdio";
    allowed_extensions = [ "{446900e4-71c2-419f-a6a7-df9c091e268b}" ];
  };
}
