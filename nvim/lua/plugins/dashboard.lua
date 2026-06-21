return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      -- 1. Tạo một hàm chứa các mã màu Gruvbox
      local function set_niis_colors()
        vim.api.nvim_set_hl(0, "NiisRed", { fg = "#fb4934" })
        vim.api.nvim_set_hl(0, "NiisOrange", { fg = "#fe8019" })
        vim.api.nvim_set_hl(0, "NiisYellow", { fg = "#fabd2f" })
        vim.api.nvim_set_hl(0, "NiisGreen", { fg = "#b8bb26" })
        vim.api.nvim_set_hl(0, "NiisBlue", { fg = "#83a598" })
        vim.api.nvim_set_hl(0, "NiisAqua", { fg = "#8ec07c" })
      end

      -- BẬT MÀU NGAY LẬP TỨC để Dashboard có màu ngay khi khởi động
      set_niis_colors()

      -- Vẫn giữ lệnh này để phòng hờ bạn gõ lệnh đổi theme thì không bị mất màu
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = set_niis_colors,
      })

      -- 2. Ghi đè toàn bộ bố cục (sections) để ép Neovim hiện logo của chúng ta
      opts.dashboard.sections = {
        {
          align = "center",
          text = {
            { "███╗   ██╗██╗██╗███████╗\n", hl = "NiisRed" },
            { "████╗  ██║██║██║██╔════╝\n", hl = "NiisOrange" },
            { "██╔██╗ ██║██║██║███████╗\n", hl = "NiisYellow" },
            { "██║╚██╗██║██║██║╚════██║\n", hl = "NiisGreen" },
            { "██║ ╚████║██║██║███████║\n", hl = "NiisBlue" },
            { "╚═╝  ╚═══╝╚═╝╚═╝╚══════╝\n", hl = "NiisAqua" },
          },
          padding = 2,
        },
        -- 3. Các nút bấm mặc định
        { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
        { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
        { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
        { section = "startup" },
      }
    end,
  },
}
