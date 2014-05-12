Ikari
=======

![ファーッ!](https://rawgit.com/glassesfactory/Ikari/master/assets/logo.svg)


Usage
-------

```coffeescript
engine = new Ikari
  el : "#test"
```

```jade
ul#test
  li(i-loop="item in collection", i-id="collections" class="age-{{ item.age }}").test
    div(i-if="item.age > 19") おっとなー
    a(href="/users/{{ item.id }}") 
      {{ item.id }} {{ item.name }}
      img(src="/assets/images/{{ item.id }}".jpg)
```

```coffeescript
collection = [
  {
    "id": 1
    "age": 3
    "name": "おじさん"
  }
  {
    "id": 2
    "age": 40
    "name": "めだまやき"
  }
]
engine.create collection
```

####result...

```html
<ul id="test">
  <li class="age-3 test">
    <a href="/users/1">
      1 おじさん
      <img src="/assets/images/1.jpg">
    </a>
  </li>
  <li class="age-40 test">
    <div>おっとなー</div>
    <a href="/users/2">
      2 めだまやき
      <img src="/assets/images/2.jpg">
    </a>
  </li>
</ul>
```