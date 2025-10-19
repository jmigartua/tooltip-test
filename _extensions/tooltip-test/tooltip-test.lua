-- tooltip-test.lua
local tooltip_counter = 0
local dependencies_added = false

return {
  ['tooltip-test'] = function(args, kwargs, meta, raw_args, context)
    -- Add dependencies only once
    if not dependencies_added then
      dependencies_added = true
      
      -- Add CDN links directly
      quarto.doc.include_text("in-header", [[
<link rel="stylesheet" href="https://unpkg.com/tippy.js@6/dist/tippy.css">
<link rel="stylesheet" href="https://unpkg.com/tippy.js@6/themes/light-border.css">
<link rel="stylesheet" href="https://unpkg.com/tippy.js@6/animations/scale-subtle.css">
<script src="https://unpkg.com/tippy.js@6/dist/tippy-bundle.umd.min.js"></script>
]])
      
      -- Add custom CSS
      quarto.doc.include_text("in-header", [[
<style>
.tooltip-trigger{background:#F0F0F0;color:#333;border:1px solid #CCC;border-radius:25px;padding:5px 12px;font:600 .9em/1.2 system-ui,-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif;cursor:pointer;transition:background-color .2s,color .2s}
.tooltip-trigger:hover{background:#000;color:#fff}
.tooltip-header{display:flex;justify-content:space-between;align-items:center;padding-bottom:8px;border-bottom:1px solid #eee;margin-bottom:8px}
.tooltip-nav button{border:none;background:none;cursor:pointer;font-size:1.2em;padding:0 5px;color:#555}
.tooltip-nav button:hover:not(:disabled){color:#000}
.tooltip-nav button:disabled{cursor:not-allowed;opacity:.3}
.tooltip-counter{font-size:.8em;color:#666}
.slide-title{display:flex;align-items:center;gap:8px;font-weight:600;margin-bottom:10px;font-size:1.1em}
.tooltip-slide{display:none}
.tooltip-slide.active{display:block}
.tooltip-slide .slide-body{font-size:.95em;color:#333;line-height:1.5}
</style>
]])
      
      -- Add initialization JS
      quarto.doc.include_text("after-body", [[
<script>
document.addEventListener('DOMContentLoaded',function(){if(typeof tippy!=='function')return;document.querySelectorAll('[id^="tooltip-"]').forEach(function(trigger){var id=trigger.id;var contentElement=document.getElementById(id+'-content');if(!contentElement)return;tippy(trigger,{content:contentElement.innerHTML,allowHTML:true,interactive:true,theme:'light-border',animation:'scale-subtle',delay:[100,200],maxWidth:400,onShow:function(instance){var content=instance.popper.querySelector('.tippy-content');var slides=content.querySelectorAll('.tooltip-slide');var prevBtn=content.querySelector('.tooltip-prev-btn');var nextBtn=content.querySelector('.tooltip-next-btn');var counter=content.querySelector('.tooltip-counter');var current=0;var total=slides.length;function showSlide(i){slides.forEach(function(s){s.classList.remove('active');s.style.display='none'});slides[i].classList.add('active');slides[i].style.display='block';counter.textContent=(i+1)+'/'+total;prevBtn.disabled=i===0;nextBtn.disabled=i===total-1}prevBtn.addEventListener('click',function(){if(current>0){current--;showSlide(current)}});nextBtn.addEventListener('click',function(){if(current<total-1){current++;showSlide(current)}});showSlide(current)}})})});
</script>
]])
    end
    
    -- Generate unique ID
    tooltip_counter = tooltip_counter + 1
    local id = "tooltip-" .. tooltip_counter
    
    -- Get parameters
    local trigger_text = pandoc.utils.stringify(kwargs["trigger"] or "Click Me")
    local trigger_class = pandoc.utils.stringify(kwargs["class"] or "tooltip-trigger")
    
    -- Parse slides
    local content = pandoc.utils.stringify(args[1] or "")
    local slides = {}
    for slide in content:gmatch("([^%-%-%-]+)") do
      slide = slide:match("^%s*(.-)%s*$")
      if slide ~= "" then table.insert(slides, slide) end
    end
    
    -- Build slides HTML
    local slides_html = ""
    for i, slide_content in ipairs(slides) do
      local title, body = slide_content:match("^#%s*(.-)%s*\n(.*)$")
      if not title then
        title = "Slide " .. i
        body = slide_content
      end
      slides_html = slides_html .. string.format([[
    <div class="tooltip-slide">
      <div class="slide-title"><span>%s</span></div>
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
  <div class="tooltip-slides">%s</div>
</div>
]], id, trigger_class, trigger_text, id, slides_html)
    
    return pandoc.RawBlock('html', html)
  end
}