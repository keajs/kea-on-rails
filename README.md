# kea-on-rails

![Kea the mountain parrot](https://raw.githubusercontent.com/mariusandra/kea/master/kea-small.jpg)

This is the rails companion for the [`kea`](https://github.com/mariusandra/kea) high level front-end architecture and the [`kea-rails-loader`](https://github.com/mariusandra/kea-rails-loader) webpack loader.

This module is still highly experimental. It works, but things can change at any moment. Proper documentation coming
once it's all ready.

## How to use?

First, put `kea-on-rails` into your `Gemfile`

```
gem 'kea-on-rails'
```

Then organize your Rails project like so: (proper scaffolding coming soon !!!)

```
app/assets        # usual
app/concepts      # trailblazer operations and other files
app/controllers   # normal controllers for API, etc
app/models
app/scenes/inbox/controller.rb      # ruby logic that directs to trailblazer operations
app/scenes/inbox/index.js           # the react component
app/scenes/inbox/logic.js           # actions, reducer, selectors
app/scenes/inbox/saga.js            # business logic of the component
app/scenes/inbox/styles.scss        # design
app/scenes/inbox/show/index.js      # sub-component
app/scenes/inbox/show/avatar.js     # sub-sub-component
app/scenes/inbox/title/index.js     # sub-component
app/scenes/home/...                 # other scene
app/views
app/views/layouts
config/kea/webpack.development.js
config/kea/webpack.production.js
config/kea/webpack.common.js
package.json
```

Then add this to your `routes.rb`:

```ruby
# Define an endpoint at `/_kea.json`. This is where kea-rails-loader will direct its requests.
kea_endpoint '_kea'

# Start a bundle. Code for the following routes will be in a separate .js file (inbox.js)
kea_bundle :inbox do
  get 'inbox', to: 'scenes/inbox/#index'
  get 'inbox/:id', to: 'scenes/inbox/#show'
end

# .. and this will be in home.js. When you visit a route, only the relevant JS files are loaded.
kea_bundle :home do
  root to: 'scenes/home/#index'
end
```

The routes inside `kea_bundle` must point to controllers that `include Kea::Controller`.

Note the `/#` in this line:

```
get 'inbox', to: 'scenes/inbox/#index'
```

A request to `/inbox` will get dispatched to the method `index` of the controller `Scenes::Inbox::Controller`, which lives under `app/scenes/inbox/controller.rb`

In each controller add `include Kea::Controller`:

```ruby
# at scenes/inbox/controller.rb
class Scenes::Inbox::Controller < ApplicationController
  include Kea::Controller

  def index
    @props = Messages::FetchForInbox.(page: params[:page]).model

    # renders either:
    # - format=json: @props as json
    # - format=html: rails layout + optional server rendered component with @props + code to init react on the client
    render_props_or_component
  end

  def add_star
    Messages::AddStar.(message: Message.find(params[:message_id]))

    render json: { success: true }
  end

  def remove_star
    Messages::RemoveStar.(message: Message.find(params[:message_id]))

    render json: { success: true }
  end
end
```

Then follow the instructions at [`kea-rails-loader`](https://github.com/mariusandra/kea-rails-loader).

Something like this:

```js
// at scenes/search/saga.js
import controller from './controller.rb'

function * handleAddStarClick (id) {
  const response = yield controller.addStar({ message_id: id })
  if (response.success) {
    console.log('the star has been added!')
  }
}
```

In case your controllers live outside of the recommended `/app/scenes` path, add this to `config/application.rb`

```
config.autoload_paths += Dir["#{config.root}/client/app/**/"]
```

(assuming now everything is under `/client/app/scenes`)

## API

The options for `kea_bundle` in routes.rb:

```ruby
{
  bundle: 'bundle_name',              # or pass as first argument
  component: 'ComponentThatOpensApp', # react component that will be opened
  prerender: true                     # render on the server? defaults to true
}
```

## Current state

This project is still under construction. The code above works, just needs to be cleanly packaged and released as open source.
