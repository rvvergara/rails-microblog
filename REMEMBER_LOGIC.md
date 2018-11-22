## Logic of Remembering a user

1. Whenever user logs in:

- User enters right credentials (user email existing and password is correct)
- `log_in` method is called which simply creates a `session[:user_id]` equal to `user.id`
- `remember(user)` will be run, which basically just

1. Generates a new random token and then runs this token in the `User.digest` method to make it into a hash, then saving this hashed token into `remember_digest` column of the users table
2. Assigns into the browser:

- `cookies.permanent.signed[:user_id] = user.id` as a hashed value of the user's id
- `cookies.permanent[:remember_token] = user.remember_token`

### When a user closes the browser and opens it again and visits the app:

1. The `current_user` method will not see any `session[:user_id]` present so it will check if there is a `cookies.signed[:user_id]` present then it will use this to find the user in the database. If found then the `cookie[:remember_token]`, which will first be run through BCrypt, will be compared to the remember_digest stored for the user in the database. If they're the same then `log_in(user)` will be run (creating a `session[:user_id] = user.id`)
