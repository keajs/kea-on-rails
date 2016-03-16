# kea-on-rails

![Kea the mountain parrot](https://raw.githubusercontent.com/mariusandra/kea/master/kea-small.jpg)

This is the rails companion for the [`kea`](https://github.com/mariusandra/kea) high level front-end architecture and the [`kea-rails-loader`](https://github.com/mariusandra/kea-rails-loader) webpack loader.

## How to use?

First, put `kea-on-rails` into your `Gemfile`

```
gem 'kea-on-rails'
```

Then add this to your `routes.rb`:

```ruby
match '_kea', to: Kea::Router.do_route, as: :kea, via: [:post]
```

Finally, in each controller that you import in webpack via `kea-rails-loader`, add `include Kea::Controller`:

```ruby
# at scenes/search/endpoint.rb
class Scenes::Search::Endpoint < ApplicationController
  include Kea::Controller

  def add_favourite
    course = Course.find(params[:course_id])
    Favourite::Create.(user: current_user, anon_user_hash: session[:anon_user_hash], course: course)

    render json: { favourites: collect_favourites! }
  end

  def remove_favourite
    course = Course.find(params[:course_id])
    Favourite::Remove.(user: current_user, anon_user_hash: session[:anon_user_hash], course: course)

    render json: { favourites: collect_favourites! }
  end
end
```

Then follow the instructions at [`kea-rails-loader`](https://github.com/mariusandra/kea-rails-loader).

Something like:

```js
// at scenes/search/logic.js
import endpoint from './endpoint.rb'

endpoint.addFavoruire({ course_id: this.props.id }).then(response => {
  console.log('all favourites:', response.favourites)
})
```
