# Assets via webpack

Webpack can serve js and css. Let's try to integrate bootstrap 5 with our
application.

```
yarn add bootstrap
yarn add @popperjs/core@^2.9.2
```

Create `app/javascript/js/bootstrap_js_files`:
```js
// inside app/frontend/js/bootstrap_js_files.js
// enable plugins as you require them

// import 'bootstrap/js/src/alert'
import 'bootstrap/js/src/button'
// import 'bootstrap/js/src/carousel'
// import 'bootstrap/js/src/collapse'
// import 'bootstrap/js/src/dropdown'
// import 'bootstrap/js/src/modal'
// import 'bootstrap/js/src/popover'
// import 'bootstrap/js/src/scrollspy'
// import 'bootstrap/js/src/tab'
// import 'bootstrap/js/src/toast'
// import 'bootstrap/js/src/tooltip'
```

Import this file into `app/javascript/packs/application.js`:
```js
import 'js/bootstrap_js_files.js'
```

Create `app/javascript/packs/application.scss`:
```scss
@import "~bootstrap/scss/bootstrap";
```

Change assert section in the layout file
`app/views/layouts/application.html.erb`:
```erb
<%= javascript_pack_tag 'application', 'data-turbo-track': 'reload' %>
<%= stylesheet_pack_tag 'application', 'data-turbo-track': 'reload' %>
```

Add example buttons on the welcome page `app/views/welcome/index.html.erb`:
```erb
<p>
  <button type="button" class="btn btn-primary">Primary</button>
  <button type="button" class="btn btn-secondary">Secondary</button>
  <button type="button" class="btn btn-success">Success</button>
  <button type="button" class="btn btn-danger">Danger</button>
  <button type="button" class="btn btn-warning">Warning</button>
  <button type="button" class="btn btn-info">Info</button>
  <button type="button" class="btn btn-light">Light</button>
  <button type="button" class="btn btn-dark">Dark</button>

  <button type="button" class="btn btn-link">Link</button>
</p>
```

## Images

  1. Create `app/javascript/images` directory
  1. Add `additional_paths: ['app/javascript/images']` to `config/webpacker.yml`
  1. Add `require.context('../images', true)` to
     `app/javascript/packs/application.js`

Now you can use following helper in you views:
```erb
<%= image_pack_tag "my-image.jpg" %>
```
