---
layout: single
author_profile: false
permalink: /publications/
---

<style>
.publication-item {
  margin-bottom: 30px;
  padding: 20px;
  border-left: 4px solid #2196F3;
  background-color: #f9f9f9;
  border-radius: 0 8px 8px 0;
}

.pub-title {
  font-weight: bold;
  font-size: 1.1em;
  color: #333;
  margin-bottom: 8px;
  line-height: 1.3;
}

.pub-authors {
  color: #666;
  margin-bottom: 8px;
  font-size: 0.95em;
}

.pub-venue {
  color: #2196F3;
  font-weight: bold;
  margin-bottom: 10px;
  font-size: 0.95em;
}

.pub-links {
  margin-top: 10px;
}

.pub-links a {
  display: inline-block;
  margin-right: 8px;
  margin-bottom: 5px;
  padding: 4px 8px;
  background-color: #2196F3;
  color: white;
  text-decoration: none;
  border-radius: 3px;
  font-size: 0.8em;
}

.pub-links a:hover {
  background-color: #1976D2;
}

.year-section {
  margin-top: 40px;
  margin-bottom: 20px;
}

.year-title {
  font-size: 1.5em;
  font-weight: bold;
  color: #2196F3;
  border-bottom: 2px solid #2196F3;
  padding-bottom: 5px;
  margin-bottom: 20px;
}
</style>

{% for year_data in site.data.publications %}
<div class="year-section">
  <div class="year-title">{{ year_data.year }}</div>
  
  {% for paper in year_data.papers %}
  <div class="publication-item">
    <div class="pub-title">{{ paper.title }}</div>
    <div class="pub-authors">{{ paper.authors }}</div>
    <div class="pub-venue">{{ paper.venue }}</div>
    <div class="pub-links">
      {% for link in paper.links %}
      <a href="{{ link.url }}">{{ link.type }}</a>
      {% endfor %}
    </div>
  </div>
  {% endfor %}
</div>
{% endfor %}

