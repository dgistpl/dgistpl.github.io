---
layout: single
author_profile: false
permalink: /gallery/
---

<style>
.year-title {
  font-size: 1.4em;
  font-weight: bold;
  color: #2196F3;
  border-bottom: 2px solid #2196F3;
  padding-bottom: 5px;
  margin: 30px 0 15px 0;
}

.event-title {
  font-size: 1.1em;
  font-weight: bold;
  margin: 25px 0 10px 0;
}

.event-date {
  color: #888;
  font-size: 0.9em;
  font-weight: normal;
  margin-left: 8px;
}

.gallery-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 15px;
  margin: 10px 0 30px 0;
}

.gallery-item {
  cursor: pointer;
  border-radius: 6px;
  overflow: hidden;
  background-color: #f5f5f5;
}

.gallery-item img {
  width: 100%;
  height: 180px;
  object-fit: cover;
  display: block;
  transition: transform 0.2s ease;
}

.gallery-item:hover img {
  transform: scale(1.04);
}

.gallery-caption {
  font-size: 0.85em;
  color: #666;
  padding: 6px 8px;
}

/* Lightbox */
.lightbox {
  display: none;
  position: fixed;
  inset: 0;
  z-index: 9999;
  background-color: rgba(0, 0, 0, 0.85);
  align-items: center;
  justify-content: center;
  flex-direction: column;
}

.lightbox.open {
  display: flex;
}

.lightbox img {
  max-width: 90vw;
  max-height: 80vh;
  border-radius: 4px;
}

.lightbox-caption {
  color: #eee;
  margin-top: 12px;
  font-size: 0.95em;
  text-align: center;
  max-width: 90vw;
}

.lightbox-close {
  position: absolute;
  top: 15px;
  right: 25px;
  color: #fff;
  font-size: 2em;
  cursor: pointer;
  background: none;
  border: none;
  line-height: 1;
}

.lightbox-nav {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  color: #fff;
  font-size: 2.5em;
  cursor: pointer;
  background: none;
  border: none;
  padding: 10px 15px;
  user-select: none;
}

.lightbox-prev { left: 10px; }
.lightbox-next { right: 10px; }
</style>

{% for year_group in site.data.gallery %}
<div class="year-title">{{ year_group.year }}</div>
  {% for event in year_group.events %}
  <div class="event-title">{{ event.title }}{% if event.date %}<span class="event-date">{{ event.date }}</span>{% endif %}</div>
  <div class="gallery-grid">
    {% for photo in event.photos %}
    <div class="gallery-item" data-image="{{ photo.image }}" data-caption="{{ photo.caption | escape }}">
      <img src="{{ photo.image }}" alt="{{ photo.caption | default: event.title }}" loading="lazy">
      {% if photo.caption %}<div class="gallery-caption">{{ photo.caption }}</div>{% endif %}
    </div>
    {% endfor %}
  </div>
  {% endfor %}
{% endfor %}

<div class="lightbox" id="lightbox">
  <button class="lightbox-close" aria-label="Close">&times;</button>
  <button class="lightbox-nav lightbox-prev" aria-label="Previous">&#10094;</button>
  <img src="" alt="">
  <button class="lightbox-nav lightbox-next" aria-label="Next">&#10095;</button>
  <div class="lightbox-caption"></div>
</div>

<script>
(function () {
  var items = Array.prototype.slice.call(document.querySelectorAll('.gallery-item'));
  var lightbox = document.getElementById('lightbox');
  var img = lightbox.querySelector('img');
  var caption = lightbox.querySelector('.lightbox-caption');
  var current = 0;

  function show(index) {
    current = (index + items.length) % items.length;
    img.src = items[current].getAttribute('data-image');
    caption.textContent = items[current].getAttribute('data-caption') || '';
    lightbox.classList.add('open');
  }

  function close() {
    lightbox.classList.remove('open');
    img.src = '';
  }

  items.forEach(function (item, i) {
    item.addEventListener('click', function () { show(i); });
  });

  lightbox.querySelector('.lightbox-close').addEventListener('click', close);
  lightbox.querySelector('.lightbox-prev').addEventListener('click', function (e) {
    e.stopPropagation();
    show(current - 1);
  });
  lightbox.querySelector('.lightbox-next').addEventListener('click', function (e) {
    e.stopPropagation();
    show(current + 1);
  });
  lightbox.addEventListener('click', function (e) {
    if (e.target === lightbox) close();
  });
  document.addEventListener('keydown', function (e) {
    if (!lightbox.classList.contains('open')) return;
    if (e.key === 'Escape') close();
    if (e.key === 'ArrowLeft') show(current - 1);
    if (e.key === 'ArrowRight') show(current + 1);
  });
})();
</script>
