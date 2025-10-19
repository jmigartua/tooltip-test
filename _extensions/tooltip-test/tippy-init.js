// tippy-init.js
// Initialize all tooltip instances

document.addEventListener('DOMContentLoaded', function() {
  if (typeof tippy !== 'function') {
    console.error('Tippy.js failed to load. Make sure the library is included.');
    return;
  }

  // Find all tooltip triggers
  const triggers = document.querySelectorAll('[id^="tooltip-"]');
  
  triggers.forEach(trigger => {
    const id = trigger.id;
    const contentElement = document.getElementById(id + '-content');
    
    if (!contentElement) {
      console.warn(`No content found for tooltip: ${id}`);
      return;
    }

    tippy(trigger, {
      content: contentElement.innerHTML,
      allowHTML: true,
      interactive: true,
      theme: 'light-border',
      animation: 'scale-subtle',
      delay: [100, 200],
      maxWidth: 400,
      onShow(instance) {
        const content = instance.popper.querySelector('.tippy-content');
        const slides = content.querySelectorAll('.tooltip-slide');
        const prevBtn = content.querySelector('.tooltip-prev-btn');
        const nextBtn = content.querySelector('.tooltip-next-btn');
        const counter = content.querySelector('.tooltip-counter');

        let current = 0;
        const total = slides.length;

        function showSlide(i) {
          slides.forEach(s => {
            s.classList.remove('active');
            s.style.display = 'none';
          });
          
          slides[i].classList.add('active');
          slides[i].style.display = 'block';
          
          counter.textContent = (i + 1) + '/' + total;
          prevBtn.disabled = i === 0;
          nextBtn.disabled = i === total - 1;
        }

        // Navigation event listeners
        prevBtn.addEventListener('click', () => {
          if (current > 0) {
            current--;
            showSlide(current);
          }
        });

        nextBtn.addEventListener('click', () => {
          if (current < total - 1) {
            current++;
            showSlide(current);
          }
        });

        // Keyboard navigation
        content.addEventListener('keydown', (e) => {
          if (e.key === 'ArrowLeft' && current > 0) {
            current--;
            showSlide(current);
          } else if (e.key === 'ArrowRight' && current < total - 1) {
            current++;
            showSlide(current);
          }
        });

        // Show first slide
        showSlide(current);
      }
    });
  });
});