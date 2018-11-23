module UsersHelper

  def gravatar_for(user, size = 50)
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end

  # This will determine which url the form will post/patch to in _form.html.erb
  def path
    params[:action] == "new" ? signup_path : nil
  end
  
  # This will set text in user form depending on whether the form is for signup or for updating profile
  def btn_txt
    return params[:action] == "new" ? "Create my account" : "Update account"
  end

  # this will set display of gravatar edit to none when the form is for new user
  def no_display
    display = params[:action] == 'new' ? 'no-display' : nil
  end

end
