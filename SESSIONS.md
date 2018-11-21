# Implementing Authentication

1. Generate controller called Sessions with new as an action

   `rails g controller Sessions new`

2. This will generate routes but only maintain:

###config/routes.rb

`get '/login', to: 'sessions#new'`<br>
`post '/login', to: 'sessions#create'`<br>
`delete '/logout', to: 'sessions#destroy'`

3. Update `test/controllers/sessions_controller_test.rb` &nbsp; to include &nbsp;`get login_path`

4. Create login form using <br>
   `<%= form_for(:sessions, url: login_path) do |f| %>`

5. Build &nbsp;`new` &nbsp;, `create`&nbsp; and &nbsp; `destroy`&nbsp; actions in &nbsp; `/controllers/sessions_controller.rb`

6. Create integration test for user login:

`rails g integration_test users_login`<br>
Use this to write tests for login page (including flash messages, etc)

7. Include&nbsp; `/controllers/helpers/sessions_helper.rb`&nbsp; to&nbsp;`/controllers/application_controller.rb`:<br>

```
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
end
```

8. Create a&nbsp;`log_in`&nbsp; method inside `sessions_helper.rb`. Use this method inside `create` method in `sessions_controller.rb`

```
# Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
  end
```

9. Create a `current_user` method inside `sessions_helper.rb` and this can be used in views

```
# Returns the current logged-in user (if any).
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end
```

10. Create a `logged_in?` method inside `sessions_helper.rb` and this will be used in views to show appropriate links/elements depending on whether the user is logged in or not:

```
def logged_in?
    !current_user.nil?
  end
```

11. In order to create a test user for testing layout changes:

- Add a `digest` method in `models/user.rb` for use in `test/fixtures/users.yml`:

```
#models/user.rb

def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
```

- Create test user/s in `test/fixtures/users.yml`:

```
michael:
  name: Michael Example
  email: michael@example.com
  password_digest: <%= User.digest('password') %>
```

- in `test/integration/users_login_test.rb` to use the test user then create a `setup` method:

```
  def setup
    @user = users(:michael)
  end
```

and do the test this way:

```
test "login with valid information" do
    get login_path
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' } }
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end
```

12. Log in user immediately upon account creation by adding `log_in(@user)` to `create` method in `users_controller.rb` after `if @user.save` line

```
def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end
  end
```

12. To test if indeed user is logged in upon creation:

- Create an `is_logged_in?` method in `test/test_helper.rb`

```
# Returns true if a test user is logged in.
  def is_logged_in?
    !session[:user_id].nil?
  end
```

- Use this method inside `test/integration/users_signup_test.rb`

```
test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User", email: "user@example.com", password:   "password", password_confirmation: "password" } }
    end
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
end
```

13. To log out user:

- Create a `log_out` method in `helpers/sessions_helper.rb`:

```
# Logs out the current user.
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
```

- Create a `destroy` method in `sessions_helper.rb` using this `log_out` method

```
def destroy
    log_out
    redirect_to root_url
  end
```
