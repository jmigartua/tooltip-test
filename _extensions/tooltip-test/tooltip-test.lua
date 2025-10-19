-- tooltip-test.lua
-- Shortcode handler for interactive tooltip slides

local tooltip_counter = 0

return {
  ['tooltip-test'] = function(args, kwargs, meta, raw_args, context)
    -- Generate unique ID for this tooltip
    tooltip_counter = tooltip_counter + 1
    local id = "tooltip-" .. tooltip_counter
    
    -- Get parameters
    local trigger_text = pandoc.utils.stringify(kwargs["trigger"] or "Click Me")
    local trigger_class = pandoc.utils.stringify(kwargs["class"] or "tooltip-trigger")
    
    -- Parse slides from content (separated by ---)
    local content = pandoc.utils.stringify(args[1] or "")
    local slides = {}
    
    for slide in content:gmatch("([^%-%-%-]+)") do
      slide = slide:match("^%s*(.-)%s*$") -- trim whitespace
      if slide ~= "" then
        table.insert(slides, slide)
      end
    end
    
    -- Build slide HTML
    local slides_html = ""
    for i, slide_content in ipairs(slides) do
      -- Check if slide has a title (first line starting with #)
      local title, body = slide_content:match("^#%s*(.-)%s*\n(.*)$")
      if not title then
        title = "Slide " .. i
        body = slide_content
      end
      
      slides_html = slides_html .. string.format([[
    <div class="tooltip-slide">
      <div class="slide-title">
        <span>%s</span>
      </div>
      <div class="slide-body">%s</div>
    </div>
]], title, body)
    end
    
    -- Build complete HTML
    local html = string.format([[
<button id="%s" class="%s">%s</button>
<div id="%s-content" style="display:none">
  <div class="tooltip-header">
    <div class="tooltip-nav">
      <button class="tooltip-prev-btn">&leftarrow;</button>
      <button class="tooltip-next-btn">&rightarrow;</button>
    </div>
    <div class="tooltip-counter"></div>
  </div>
  <div class="tooltip-slides">
%s
  </div>
</div>
]], id, trigger_class, trigger_text, id, slides_html)
    
    return pandoc.RawBlock('html', html)
  end
}