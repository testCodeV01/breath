# Breath
Rails authentication plugin with API mode.<br />
Easy introducing login, logout.<br/>
Compact features set.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "breath"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install breath
```

## Usage
### Introduce

#### Model
If you want to introduce a authentication to `User` model.<br/>
Add these lines to `user.rb` like below.
```ruby
class User < ApplicationRecord
  include Breath::Model

  attr_breath :email
end
```
Here, with `attr_breath`, you need to specify the user's attribute with authentication.

#### Migration
In migration file, you need to add `password_digest`, and `remember_digest` attributes.<br/>
And if you specify the email attribute within `attr_breath`, you need to add `email` attribute in migration file.
```ruby
class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :remember_digest

      t.timestamps
    end
  end
end
```
After these lines you added, excute `bundle exec rails db:migrate`.


#### Controller
You need to construct the directory like below.
```
/app/controllers
  - application_controller.rb

  /users
    - application_controller.rb
    - sessions_controller.rb
```

- app/contorllers/users/application_controller.rb
```ruby
class Users::ApplicationController < ApplicationController
  include Breath::ApplicationControllerHelper
  before_action :authenticate!

  crsf_protect true
end
```
Here, if `csrf_protect` is `true`, CSRF protection is enabled.<br/>

- app/controllers/users/sessions_controller.rb
```ruby
class Users::SessionsController < Users::ApplicationController
  include Breath::SessionsControllerHelper
end
```

`Breath::ApplicationControllerHelper` intoroduce the user's authorization.<br/>
`Breath::SessionsControllerHelper` introduce the actions `login`, and `logout`.

Then, you don't need write the codes to introduce authorizations.<br/>

You can use `current_user` method which is current logined user.

#### Route
Write `route.rb`
```ruby
Rails.application.routes.draw do
  breath :users

  ...or...

  breath :users do
    get "test" => "sessions#test"
  end
end
```

After you added these lines, show `bundle exec rails routes` command.<br/>
You can see these routes are added.
```
GET /users/login
POST /users/login
DELETE /users/logout
```
Or, nested users routes.

#### Config
This plugin need cookie, and you can configure the cookie expires like below.<br/>
```ruby
module YourApp
  class Application < Rails::Application
    ...

    config.breath_expires = 3.days
  end
end
```
If you don't configure this, cookie is set permanently.

#### Error
When an error occurs when trying to log in or authorize, rescue from the error automatically.
Otherwise, you can also overwrite rescue method like below.<br/>
`app/controllers/users/application_controller.rb`
```ruby
class Users::ApplicationController < ApplicationController
  ...

  def render_401(e)
    # Write your programs. Here, e is error class.
    # e.g. Rails.logger.error(e.to_s)

    super({ error: 111, message: "error occur." })
  end

  ...
end
```
An argument you pass to super is returned to the client side as JSON value.<br/>
In addition, breath plugin provides below rescue methods.
```ruby
render_400
render_401 # Unauthorized.
render_404 # Not Found.
render_409 # Conflict.
render_422 # Unprocessable Entity.
render_500 # Internal Server Error.
```
You can use these rescue methods in controllers like below.
```ruby
class Users::HogeController < Users::ApplicationController
  def index
    ...
    render status: 200
  rescue => e
    render_404 e
  end

  def update
    ...
    render status: 201
  rescue => e
    response_body = { error_code: 100, message: "error" }

    render_409 response_body
  end
end
```
Breath plugin automatically rescues from CSRF token error which is status 422, and Internal Server Error with status code 500.<br/>
And you can overwrite these rescue methods.

#### Last Work
You need to create view side.<br/>
In view side, you have remaining works.<br/>
if you `csrf_protect true`, you need to introduce `withCredentials: true` option in client side.<br/>
And, write csrf token into the cookie with `csrf_token` key.<br/>
If your application needs to be requested by an client side application, you need to configure the  Cross-Origin Resource Sharing (CORS) .<br/>
You can introduce the CORS configure by `rack-cors` rails gem.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
