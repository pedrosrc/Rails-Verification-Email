# Verification Email in Rails

## 🚀 Installing the project 

To install the project, follow these steps:

1- Clone Repository:
```
git@github.com:pedrosrc/Rails-Verification-Email.git
```

2- Install gem's

```
bundle install
```

3- Run Migrations

```
rails db:migrate
```

## ☕ Using projecty

```
bin/dev
```
## 📚Learning about Mailer

Hello, we know that email verification is present in many applications in our daily lives. It is through it that we improve the sender's reputation and, most importantly, prevent identity forgery. Given this, I saw in the Rails community that using Devise is quite common, but what if you wanted to implement something from scratch? How would you do it? Today, I’m going to teach you.

For this example, I will be using Rails 7.2, SQLite3, and Bcrypt.

## 1. Initial Configuration
To create the Rails application, run:

```
rails new verification-app
cd verification-app
```
**1.1 Create a Model for User**
Run in your terminal:
```
rails generate model User name:string email:string password_digest:string verification_code:string verified:boolean
rails db:migrate
```
Change `app/models/user.rb` to include secure authentication:

```
class User < ApplicationRecord
  has_secure_password
  before_create :generate_verification_code
  validates :name, :email, presence: true
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  
  def generate_verification_code
    self.verification_code = rand(100000..999999).to_s
    self.verified = false
  end
end
```
Method `generate_verification_code`: This method generates a random verification code (a 6-digit number) whenever a new user is created. The code is stored in the `verification_code` attribute, and the `verified` attribute is set to `false`, indicating that the user has not been verified yet.

## 2. Mailer Configuration
The Mailer is the Rails module responsible for facilitating email sending. It allows you to define templates, layouts, and some logic for emails in an organized way.

**2.1 Creating Mailer**
Run in your terminal:

```
rails generate mailer UserMailer
```
Change `app/mailers/user_mailer.rb` :

```
class UserMailer < ApplicationMailer
  default from: 'youremail@gmail.com'
  
  def verification_email(user)
    @user = user
    mail(to: @user.email, subject: "Verification Code")
  end
end
```
In 'youremail@gmail.com', use the email that will be responsible for sending to users. I recommend using it in a credential or environment variable, but in this example, I will make it very explicit.

Create view `app/views/user_mailer/verification_email.html.erb`:

```
<!DOCTYPE html>
<html>
<head>
  <style>
    @import url('https://cdnjs.cloudflare.com/ajax/libs/tailwindcss/2.2.19/tailwind.min.css');
  </style>
</head>
<body class="bg-gray-100 font-sans leading-normal tracking-normal">
  <div class="max-w-lg mx-auto my-10 bg-white p-8 rounded-lg shadow-lg">
    <h1 class="text-2xl font-bold mb-4">Verify your account</h1>
    <p class="text-lg mb-4">Hi, <%= @user.name %>!</p>
    <p class="text-lg mb-4">Your verification code is: <strong class="text-blue-500"><%= @user.verification_code %></strong></p>
    <p class="text-lg">Enter this code on the verification page to activate your account.</p>
  </div>
</body>
</html>
```
This view will be the layout of the email that the user will receive. You can style it with Tailwind, as shown in the example. You can also use it in a regular erb structure.

**2.2  SMTP Configuration (Gmail - Tests)**
In my application, I chose to use Gmail to send emails, but you can use other services, such as SendGrid (recommended for production). Just configure them according to each one's instructions.

In the case of Gmail, you need to register an application at the following link and use the password it provides in your Rails Credentials or ENV, if you prefer.

1. Acess: https://myaccount.google.com/apppasswords
2. Generate a password for your app and use it instead of your real password.
3. In "user_name," it's the email that will be used.
4. In "password," you will enter the password generated from the Gmail application registration.

Add in `config/environments/development.rb`:

```
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: "smtp.gmail.com",
  port: 587,
  domain: "gmail.com",
  authentication: "plain",
  enable_starttls_auto: true,
  user_name: Rails.application.credentials.gmail_username,
  password: Rails.application.credentials.gmail_password
}
```

## 3. UsersController Implementation  
In our Controller, this is where the methods responsible for handling requests and implementing the logic for sending emails are located.
Change `app/controllers/users_controller.rb`:

```
class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      UserMailer.verification_email(@user).deliver_now
      redirect_to verify_user_path(@user), notice: "Code sent to your email."
    else
      render :new, status: :unprocessable_entity, notice: "Try again"
    end
  end

  def verify
    @user = User.find(params[:id])
  end

  def confirm_verification
    @user = User.find(params[:id])
    if @user.verification_code == params[:verification_code]
      @user.update(verified: true, verification_code: nil)
      redirect_to new_session_path, notice: "Account verified! Log in."
    else
      flash.now[:alert] = "Code invalid!"
      render :verify, status: :unprocessable_entity
    end
  end

  def resend_verification_code
    @user = User.find(params[:id])
    @user.update(verification_code: rand(100000..999999).to_s)
    UserMailer.verification_email(@user).deliver_now

    redirect_to verify_user_path(@user), notice: "New code sent to your email."
  end

  def show
    @user = User.find(params[:id])
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
```

## 4. Create the Email Verification View.
This will be our basic view where we can enter the code we receive in the email.
Create `app/views/users/verify.html.erb`:

```
<div class="max-w-md mx-auto mt-10 p-6 bg-white shadow-lg rounded-lg">
  <h1 class="text-2xl font-bold mb-4">Verificação de Conta</h1>

  <p class="mb-4">A verification code has been sent to your email.</p>

  <%= form_with url: confirm_verification_user_path(@user), local: true, class: "space-y-4" do |form| %>
    <div>
      <%= form.label :verification_code, "Enter the Code", class: "block text-sm font-medium text-gray-700" %>
      <%= form.text_field :verification_code, class: "mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm" %>
    </div>

    <div>
      <%= form.submit "Verify Account", class: "w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500" %>
    </div>
  <% end %>
  <p id="resend-info">You can resend the code at <span id="timer">30</span> seconds.</p>
  <%= button_to "Resend Code", resend_verification_code_user_path(@user), method: :post, id: "resend-button", disabled: true %>
</div>

<script>
  document.addEventListener("DOMContentLoaded", function() {
    let timer = 30;
    let button = document.getElementById("resend-button");
    let timerText = document.getElementById("timer");
    
    let countdown = setInterval(function() {
      timer--;
      timerText.textContent = timer;
      
      if (timer <= 0) {
        clearInterval(countdown);
        button.disabled = false;
        document.getElementById("resend-info").textContent = "Didn't receive the code? Resend now.";
      }
    }, 1000);
  });
</script>
```

## 5. Routes configuration
Lastly, the configuration of our routes.

```
resources :users, only: [:new, :create, :show] do
  member do
    get :verify
    post :confirm_verification
    post :resend_verification_code
  end
end
```

## Conclusion

And that's it, now you can send real emails. If it's just for local testing, Gmail works well. For production, SendGrid or Mailgun are more recommended. Rails is capable of doing countless things with numerous possibilities, and email sending is one of them with relative ease. I hope this article helps those who need it, and if you find something wrong or have a suggestion for improvement, feel free to leave it in the comments so we can discuss it.

Repository in my Github: [Rails-Verification-Email](https://github.com/pedrosrc/Rails-Verification-Email)
