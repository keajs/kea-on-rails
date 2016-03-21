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

Then add this to your `routes.rb`:

```ruby
kea_endpoint '_kea'

kea_bundle :search do
  get 'inbox', to: 'scenes/inbox/#index'
  get 'inbox/:id', to: 'scenes/inbox/#show'
end
```

`kea_endpoint` defines the endpoint at `/_kea.json`. This is where `kea-rails-loader` will direct its requests.

`kea_bundle` starts a block. All `Kea::Controller`s in blocks will be dispatched to the correct JavaScript bundles.

The options for `kea_bundle`:

```ruby
{
  bundle: 'bundle_name',              # or pass as first argument
  component: 'ComponentThatOpensApp', # react component that will be opened
  prerender: true                     # render on the server? defaults to true
}
```

Note the format of:

```
get 'inbox', to: 'scenes/inbox/#index'
```

This means that the request gets dispatched to the method `index` of the controller `Scenes::Inbox::Controller`.

In each controller add `include Kea::Controller`:

```ruby
# at scenes/search/controller.rb
class Scenes::Search::Controller < ApplicationController
  include Kea::Controller

  def index
    @props = Course::Search.(params).model

    # rendes kea/component.html.erb if format.html or json: @props if format.json
    render_props_or_component
  end


  def add_favourite
    Favourite::Create.(user: current_user, course: Course.find(params[:course_id]))

    render json: { favourites: current_user.favourites.pluck(:id) }
  end

  def remove_favourite
    Favourite::Remove.(user: current_user, course: Course.find(params[:course_id]))

    render json: { favourites: current_user.favourites.pluck(:id) }
  end
end
```

Then follow the instructions at [`kea-rails-loader`](https://github.com/mariusandra/kea-rails-loader).

Something like:

```js
// at scenes/search/logic.js
import controller from './controller.rb'

controller.addFavoruire({ course_id: this.props.id }).then(response => {
  console.log('all favourites:', response.favourites)
})
```

In case your controllers live outside of the recommended `/app/scenes` path, add this to `config/application.rb`

```
config.autoload_paths += Dir["#{config.root}/client/app/**/"]
```

(assuming now everything is under `/client/app/scenes`)
