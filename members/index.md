---
layout: single
author_profile: false
permalink: /members/
---

<style>
.member-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 30px;
  margin: 20px 0;
}

.member-card {
  text-align: center;
  padding: 20px;
}

.member-photo {
  width: 120px;
  height: 120px;
  border-radius: 50%;
  object-fit: cover;
  margin: 0 auto 15px auto;
  display: block;
  border: 3px solid #f0f0f0;
}

.member-name {
  font-weight: bold;
  font-size: 1.1em;
  margin-bottom: 5px;
}

.member-name-kr {
  color: #666;
  font-size: 0.9em;
  margin-bottom: 10px;
}

.member-title {
  color: #888;
  font-size: 0.9em;
  line-height: 1.4;
}

.section-title {
  border-bottom: 2px solid #2196F3;
  padding-bottom: 10px;
  margin: 40px 0 20px 0;
  font-size: 1.3em;
  font-weight: bold;
}

.recruiting-message {
  text-align: center;
  padding: 40px 20px;
  background-color: #f9f9f9;
  border-radius: 8px;
  color: #666;
  font-style: italic;
}
</style>


<div class="section-title">Professors</div>
<div class="member-grid">
  {% for author_id in site.data.authors %}
    {% assign author = author_id[1] %}
    {% if author.position == "Assistant Professor" %}
    <div class="member-card">
      <a href="{{ author.url }}">
        <img src="{{ author.avatar }}" alt="{{ author.name }}" class="member-photo">
      </a>
      <div class="member-name">
        <a href="{{ author.url }}" style="text-decoration: none; color: inherit;">{{ author.name }}</a>
      </div>
      <div class="member-name-kr">{{ author.ko-name }}</div>
      <div class="member-title">{{ author.position }}</div>
    </div>
    {% endif %}
  {% endfor %}
</div>
<!-- 
<div class="section-title">Postdoc Researchers</div>
<div class="recruiting-message">
  Currently recruiting motivated postdoc researchers!
</div> -->

<div class="section-title">PhD Students</div>
<div class="recruiting-message">
  Currently recruiting motivated PhD students!
</div>

<div class="section-title">MS Students</div>
<div class="recruiting-message">
  Currently recruiting motivated MS students!
</div>

<div class="section-title">Undergraduate Interns</div>
<div class="recruiting-message">
  Currently recruiting motivated undergraduate students!
</div>

<!-- <div class="section-title">Alumni</div>
<div class="recruiting-message">
  Coming soon...
</div> -->

---

<div style="text-align: center; background-color: #f0f8ff; border: 2px solid #2196F3; border-radius: 8px; padding: 30px; margin-top: 40px;">
  <h3 style="color: #2196F3; margin-bottom: 15px;">Join PLX Lab!</h3>
  <p style="margin-bottom: 20px;">We are actively recruiting motivated researchers at all levels who are interested in developing programming language technologies for addressing challenges in various computer science domains.</p>
  
  <div style="margin-top: 20px;">
    <a href="mailto:minseok_jeon@dgist.ac.kr" class="btn btn--primary">
      <i class="fas fa-envelope"></i> Contact Us
    </a>
  </div>
</div>