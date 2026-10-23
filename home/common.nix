{ pkgs, ... }:

{
  imports = [
    ./nextcloud-autosync.nix
  ];

  home.username = "skybound";
  home.homeDirectory = "/home/skybound";
  home.stateVersion = "26.11";
  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch";

  home.packages = with pkgs; [
    github-cli
    btop
    tmux
    jq
    ripgrep
    fd
  ];

  catppuccin = {
    enable = true;
    autoEnable = true;
  };

  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    nix-direnv.enable = true;
    config.global.hide_env_diff = true;
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
      nixfmt
    ];
    initLua = ''
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
}
