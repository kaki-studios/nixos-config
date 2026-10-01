local ls = require "luasnip"
local s, i = ls.snippet, ls.insert_node
local fmta = require("luasnip.extras.fmt").fmta

local in_math = function()
  return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end

return {}, {
  s({ trig = "mk", snippetType = "autosnippet" }, fmta("$<>$", { i(1) })),
  s({ trig = "dm", snippetType = "autosnippet" }, fmta("\\[\n\t<>\n\\]", { i(1) })),
  s({ trig = "ff", snippetType = "autosnippet", condition = in_math }, fmta("\\frac{<>}{<>}", { i(1), i(2) })),
  s({ trig = "sq", snippetType = "autosnippet", condition = in_math }, fmta("\\sqrt{<>}", { i(1) })),
}
