-- kramdown-toc.lua
-- This filter replaces the Kramdown TOC marker (- TOC followed by {:toc})
-- with a native Table of Contents (with page numbers in PDF).

local function is_toc_marker(block)
  if block.t == 'BulletList' and #block.content == 1 then
    local item = block.content[1]
    local text = pandoc.utils.stringify(item)
    if text:match("^TOC%s*{:toc}$") then
      return true
    end
  end
  return false
end

function Pandoc(doc)
  local new_blocks = pandoc.List:new()

  for i, block in ipairs(doc.blocks) do
    if is_toc_marker(block) then
      if FORMAT == 'latex' or FORMAT == 'pdf' then
        -- Insert native LaTeX TOC for PDFs (gives page numbers)
        new_blocks:insert(pandoc.RawBlock('latex', '\\tableofcontents'))
      else
        -- Insert Pandoc-generated list for other formats (HTML, etc.)
        local toc_list = pandoc.structure.table_of_contents(doc)
        local title_text = "Table of Contents"
        if doc.meta.lang and pandoc.utils.stringify(doc.meta.lang) == 'et' then
          title_text = "Sisukord"
        end
        local toc_header = pandoc.Header(2, pandoc.Inlines(title_text), {id="table-of-contents", class="unlisted"})
        new_blocks:insert(pandoc.Div({toc_header, toc_list}, {id="TOC", class="toc"}))
      end
    else
      new_blocks:insert(block)
    end
  end

  return pandoc.Pandoc(new_blocks, doc.meta)
end
