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
  
end
