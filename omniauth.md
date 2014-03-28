##Omniauth

###Assignment

You will be adding twitter authentication to a simple Rails App. You will attempt to do this on your own with the following instructions. Do this lab in pairs.  

First clone this rails app:  

terminal `git clone https://github.com/jackieiscool/omaniauth_lab.git`  

1. Sign-up for twitter API access
  - Make sure you check the box to enable twitter sign-in
  - Use this as your callback url `http://127.0.0.1:3000`
2. Install omniauth twitter gem as well as the figaro gem, and bundle
  
*Gemfile*  

```ruby
gem 'omniauth-twitter'
gem 'figaro'
```

3. Run `rails g figaro:install` in your terminal

4. Add this code with your API access keys to your application.yml file

*application.yml*  

```ruby
CONSUMER_KEY: <YOUR CONSUMER KEY>
CONSUMER_SECRET: <YOUR CONSUMER SECRET>
```

5. Create and add code to omniauth.rb file

*omniauth.rb*  

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, 'CONSUMER_KEY', 'CONSUMER_SECRET'
end
```

6. Create user model with provider, uid, and name?

*terminal*  

`rails g model user`

- In your new migration file (in the migrate folder, under the db folder) add the following code.  

*create_users.rb*  

```ruby
class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :provider
      t.string :uid
      t.string :name
      t.timestamps
    end
  end
end
```

7. Create sessions controller

termnal `rails g controller sessions`  

8. Add route for sign_in and omniauth

*routes.rb*  

```ruby
  get '/sign_in' => "sessions#new"
  get "/auth/:provider/callback" => "sessions#create"
```

9. Add new method to sessions controller

*sessions_controller.rb*  

```ruby

def new

end

```

10. Add new.html.erb page with twitter link

*terminal* `touch app/views/sessions/new.html.erb`  

*views/sessions/new.html.erb*  

```
<%= link_to "Sign in with Twitter", "/auth/twitter" %>
```

11. Add create method to sessions

```ruby

def create
  auth = request.env["omniauth.auth"]
  user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.create_with_omniauth(auth)
  session[:user_id] = user.id
  redirect_to root_url, :notice => "Signed in!"
end

```

12. Add create with omniauth method to user

*user.rb*  

```ruby

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["info"]["name"]
    end
  end

```

13. Add current_user method to application controller

*application_controller.rb*  

```ruby

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

end

```

14. Now add an authenticate method to your application_controller, and call on that method in a before_action

```ruby

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user
  before_action :authenticate

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def authenticate
    unless current_user
      redirect_to sign_in_path, notice: "Please sign in."
    end
  end
end

```

15. Now, we want our users to be able to access the sign_in page before we authenticate, so we will add a skip_before_action


*sessions_controller.rb*  

```ruby
class SessionsController < ApplicationController
  skip_before_action :authenticate


end
```

16. Turn on your rails server (`rails s`) and visit localhost:3000. You should be able to sign in with Twitter, and see your name.  

17. Finally, our user's can now sign_in, but they do not have a way to signout, so let's add that. Add a destroy method to sessions controller

*sessions_controller.rb*  

```ruby

def destroy
  session[:user_id] = nil
  redirect_to root_url, :notice => "Signed out!"
end

```

18. Add a signout route

*routes.rb*  

```ruby

get "/signout" => "sessions#destroy", :as => :signout

```

19. Last, add the following link to your welcome page.

*views/welcome/index.html.erb*  

```
<%= link_to "Sign Out", signout_path %>
```



