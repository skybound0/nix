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

  programs.obsidian = {
    enable = true;
    cli.enable = true;
    defaultSettings.themes.AnuPpuccin.enable = true;
    defaultSettings.communityPlugins = {
      obsidian-livesync.enable = true;
      obsidian-style-settings.enable = true;
    };
  };

  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    nix-direnv.enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      ripgrep
      fd
      nixd
      nixfmt-rfc-style
    ];
    extraLuaConfig = ''
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.signcolumn = "yes"
    '';

    plugins = with pkgs.vimPlugins; [
      {
        plugin = which-key-nvim;
        type = "lua";
        config = ''
          vim.g.mapleader = " "
          vim.g.maplocalleader = " "
          require("which-key").setup({})
        '';
      }

      plenary-nvim
      telescope-fzf-native-nvim
      {
        plugin = telescope-nvim;
        type = "lua";
        config = ''
          require("telescope").setup({})
          require("telescope").load_extension("fzf")
          local t = require("telescope.builtin")
          vim.keymap.set("n", "<leader>ff", t.find_files, { desc = "Find files" })
          vim.keymap.set("n", "<leader>fg", t.live_grep,  { desc = "Live grep" })
          vim.keymap.set("n", "<leader>fb", t.buffers,    { desc = "Buffers" })
          vim.keymap.set("n", "<leader>fh", t.help_tags,  { desc = "Help" })
        '';
      }

      {
        plugin = oil-nvim;
        type = "lua";
        config = ''
          require("oil").setup({})
          vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Parent dir" })
        '';
      }

      {
        plugin = nvim-treesitter.withAllGrammars;
        type = "lua";
        config = ''
          vim.api.nvim_create_autocmd("FileType", {
            callback = function() pcall(vim.treesitter.start) end,
          })
        '';
      }

      nvim-web-devicons
      {
        plugin = lualine-nvim;
        type = "lua";
        config = ''require("lualine").setup({ options = { theme = "auto" } })'';
      }

      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = ''require("gitsigns").setup({})'';
      }

      {
        plugin = nvim-autopairs;
        type = "lua";
        config = ''require("nvim-autopairs").setup({})'';
      }
      {
        plugin = nvim-surround;
        type = "lua";
        config = ''require("nvim-surround").setup({})'';
      }
      {
        plugin = flash-nvim;
        type = "lua";
        config = ''
          require("flash").setup({})
          vim.keymap.set({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash jump" })
        '';
      }
      vim-sleuth

      {
        plugin = indent-blankline-nvim;
        type = "lua";
        config = ''require("ibl").setup({})'';
      }
      {
        plugin = todo-comments-nvim;
        type = "lua";
        config = ''require("todo-comments").setup({})'';
      }

      {
        plugin = trouble-nvim;
        type = "lua";
        config = ''
          require("trouble").setup({})
          vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics" })
        '';
      }

      {
        plugin = undotree;
        type = "lua";
        config = ''vim.keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<cr>", { desc = "Undotree" })'';
      }

      {
        plugin = blink-cmp;
        type = "lua";
        config = ''require("blink.cmp").setup({ keymap = { preset = "default" } })'';
      }

      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = ''vim.lsp.enable({ "nixd" })'';
      }
      {
        plugin = fidget-nvim;
        type = "lua";
        config = ''require("fidget").setup({})'';
      }

      {
        plugin = conform-nvim;
        type = "lua";
        config = ''
          require("conform").setup({
            formatters_by_ft = { nix = { "nixfmt" } },
            format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
          })
        '';
      }
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

  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 11;
    };
  };

  home.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
  fonts.fontconfig.enable = true;

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      set -gx NIX_REMOTE daemon
    '';
    plugins = [
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
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
