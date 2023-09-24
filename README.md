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
Add these lines to `user.rb` like bellow.
```ruby
class User < ApplicationRecord
  include Breath::Model

  attr_breath :email
end
```
Here, with `attr_breath`, you need to specify the user's attribute with authentication.

#### Migration
In migration file, you need to add `password_digest`, and `remember_digest` attributes.<br/>
And if you specify the `attr_breath` attribute with email, you need to add `email` attribute.
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
You need to construct the directory like bellow.
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
Here, if `csrf_protect` is `true`, Csrf protection is enabled.<br/>

- app/controllers/users/sessions_controller.rb
```ruby
class Users::SessionsController < Users::ApplicationController
  include Breath::SessionsControllerHelper
end
```

`Breath::ApplicationControllerHelper` intoroduce the user's authorization.<br/>
`Breath::SessionsControllerHelper` introduce the actions `login`, and `logout`.

After you added these lines, show `bundle exec rails routes` command.<br/>
You can see these routes are added.
```
GET /users/login
POST /users/login
DELETE /users/logout
```

Then, you don't need write the codes to introduce authorizations.

#### Last Work
You need to create view side.<br/>
In view side, you have remaining works.<br/>
if you `csrf_protect true`, you need to introduce `withCredentials: true` option in client side.<br/>
And, write csrf token into the cookie with `csrf_token` key.

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
