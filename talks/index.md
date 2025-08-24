---
layout: single
author_profile: false
permalink: /talks/
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
</style>

{% assign talks_by_year = site.data.talks | group_by: "year" | sort: "name" | reverse %}
{% for year_group in talks_by_year %}
<div class="year-title">{{ year_group.name }}</div>
{% for talk in year_group.items %}
+ {{ talk.title }}. {{ talk.venue }}. {{ talk.date }} <br>
  <a href="{{ talk.slides }}" class="btn btn--primary btn--small">
    <i class="fas fa-file-pdf"></i> Slides
  </a>
{% endfor %}
{% endfor %}

