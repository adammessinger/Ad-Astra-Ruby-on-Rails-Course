# Ruby on Rails Week 3, Day 1

## Magic methods

[Video](http://player.vimeo.com/video/91023389)

The way we've been writing Rails apps isn't the way real Rails developers write
Rails apps. Just like Active Record provides a huge amount of pre-built
functionality so that you don't have to write the same methods every time,
Rails provides a bunch of shortcuts and "magic methods" to make it faster and
easier to build your apps.

### Routes

Let's start with the router. Every time you create a model that you want to
provide RESTful actions for, your routes look pretty much the same:

`config/routes.rb`

```ruby
Rails.application.routes.draw do
  match('contacts', {:via => :get, :to => 'contacts#index'})
  match('contacts/new', {:via => :get, :to => 'contacts#new'})
  match('contacts', {:via => :post, :to => 'contacts#create'})
  match('contacts/:id', {:via => :get, :to => 'contacts#show'})
  match('contacts/:id/edit', {:via => :get, :to => 'contacts#edit'})
  match('contacts/:id', {:via => [:patch, :put], :to => 'contacts#update'})
  match('contacts/:id', {:via => :delete, :to => 'contacts#destroy'})
end
```

As long as your controller actions have the names `index`, `new`, `create`,
`show`, `edit`, `update`, and `destroy`, Rails lets us DRY this up with the
`resources` method:

`config/routes.rb`

```ruby
Rails.application.routes.draw do
  resources :contacts
end
```

Any time you want to get those seven RESTful routes, you can use the `resources`
method instead. If there are any of them you don't need -- for example, maybe
your `index` template includes a form for creating a new contact, or maybe you
don't have a `show` page -- you can take them out like this:

```ruby
Rails.application.routes.draw do
  resources :contacts, :except => [:new, :show]
end
```

What about nested routes that look like this?

```ruby
Rails.application.routes.draw do
  resources :contacts

  match('contacts/:contact_id/phones/new', {:via => :get, :to => 'phones#new'})
  match('contacts/:contact_id/phones/', {:via => :post, :to => 'phones#create'})
  ...
end
```

Rails provides a shortcut for these, too:

```ruby
Rails.application.routes.draw do
  resources :contacts do
    resources :phones
  end
end
```

The `resources` method is convenient and encourages you to stick to RESTful
routes, but it also obscures what routes your app has. Fortunately, Rails has a
nice tool to list all of your application's routes: `$ rake routes`. The output
looks like this:

```
            Prefix             Verb   URI Pattern                                     Controller#Action
                   GET    /                                               contacts#index
    contact_phones GET    /contacts/:contact_id/phones(.:format)          phones#index
                   POST   /contacts/:contact_id/phones(.:format)          phones#create
 new_contact_phone GET    /contacts/:contact_id/phones/new(.:format)      phones#new
edit_contact_phone GET    /contacts/:contact_id/phones/:id/edit(.:format) phones#edit
     contact_phone GET    /contacts/:contact_id/phones/:id(.:format)      phones#show
                   PATCH  /contacts/:contact_id/phones/:id(.:format)      phones#update
                   PUT    /contacts/:contact_id/phones/:id(.:format)      phones#update
                   DELETE /contacts/:contact_id/phones/:id(.:format)      phones#destroy
          contacts GET    /contacts(.:format)                             contacts#index
                   POST   /contacts(.:format)                             contacts#create
      edit_contact GET    /contacts/:id/edit(.:format)                    contacts#edit
           contact GET    /contacts/:id(.:format)                         contacts#show
                   PATCH  /contacts/:id(.:format)                         contacts#update
                   PUT    /contacts/:id(.:format)                         contacts#update
                   DELETE /contacts/:id(.:format)                         contacts#destroy
```

Don't worry about the `Prefix` column yet. The rest of it, you can see, gives
you a really nice table listing out the HTTP method, the path, and the
corresponding controller action.

By the way, with nested routes, it's often convenient to have a resource that's
both nested and not nested:

`config/routes.rb`

```ruby
Rails.application.routes.draw do
  resources :contacts do
    resources :phones, :only => [:new, :create]
  end

  resources :phones, :except => [:new, :create]
end
```

This is perfectly legitimate, and often very useful.

The last tool for the router is for your root route. You can change this:

```ruby
Rails.application.routes.draw do
  match('/', {:via => :get, :to => 'contacts#index'})
end
```

to this:

```ruby
Rails.application.routes.draw do
  root :to => 'contacts#index'
end
```

### Controllers

Have you noticed how we often name the template that a controller action
renders with the same name as the action? For example:

`app/controllers/contacts_controller.rb`

```ruby
class ContactsController < ApplicationController
  def index
    @contacts = Contact.all
    render('contacts/index.html.erb')
  end

  def new
    @contact = Contact.new
    render('contacts/new.html.erb')
  end
end
```

The `index` action renders `index.html.erb`, and the `new` action renders
`new.html.erb`. Guess what? We can be lazy and take the render method out of
these:

```ruby
class ContactsController < ApplicationController
  def index
    @contacts = Contact.all
  end

  def new
    @contact = Contact.new
  end
end
```

If you don't render or redirect, Rails will automatically render a view with
the filename of the controller action.

If you do need to specify the name of the view, you can shorten it from:

`app/controllers/contacts_controller.rb`

```ruby
class ContactsController < ApplicationController
...
  def create
    @contact = Contact.new(params[:contact])
    if @contact.save
      flash[:notice] = "Contact created."
      redirect_to('/contacts')
    else
      render('contacts/new.html.erb')
    end
  end
...
end
```

to:

```ruby
class ContactsController < ApplicationController
...
  def create
    @contact = Contact.new(params[:contact])
    if @contact.save
      flash[:notice] = "Contact created."
      redirect_to('/contacts')
    else
      render 'new'
    end
  end
...
end
```

Finally, let's take another look at the output of `rake routes`. For `GET
/contacts`, the prefix is `contacts`. Instead of writing a path like
`/contacts`, Rails developers will write `contacts_path`. The `contacts` part of
that helper is the prefix, and adding `_path` to the end calls a method that
returns the associated path. These type of methods are called **route
helpers.** Here's what a route helper looks like in the controller:

`app/controllers/contacts_controller.rb`

```ruby
class ContactsController < ApplicationController
...
  def create
    @contact = Contact.new(params[:contact])
    if @contact.save
      flash[:notice] = "Contact created."
      redirect_to contacts_path
    else
      render 'new'
    end
  end
...
end
```

For a path with a dynamic segment, such as `GET /contacts/:id`, you pass the
object whose ID you want as an argument, like this:

```ruby
class ContactsController < ApplicationController
...
  def update
    @contact = Contact.find(params[:id])
    if @contact.update(params[:contact])
      flash[:notice] = "Contact updated."
      redirect_to contact_path(@contact)
    else
      render 'edit'
    end
  end
...
end
```

Rails automatically extracts the ID and adds it to the path.

Now that we know how to write Rails controllers like Rails developers really
do, let's turn to views.

### Views

Let's start with the simple stuff and switch our links to use the route helpers
instead. We'll change this:

`app/views/contacts/index.html.erb`

```html
...
<a href="/contacts/new" class="btn btn-default">New contact</a>
into this:
```

```html
...
<%= link_to "New contact", new_contact_path, :class=> "btn btn-default" %>
```

The HTML this new version produces is exactly the same as the old one. But the
second way is the preferred Rails approach.

Let's refactor the `show` page. Before:

`app/views/contacts/show.html.erb`

```html
<p><a href="/contacts/<%= @contact.id %>/edit" class="btn btn-default">Edit</a></p>
<p><a href="/contacts/<%= @contact.id %>"
      data-confirm="You sure?"
      data-method="delete"
      rel="nofollow"
      class="btn btn-danger">Delete</a></p>
<p><a href="/contacts">Return to contact listing</a></p>
```

After:

```html
<p>
  <%= link_to('Edit', edit_contact_path(@contact), class: 'btn btn-default') %>
</p>

<p>
  <%= link_to('Delete', contact_path(@contact), {
    data: {confirm: 'You sure?', method: 'delete'},
    class: 'btn btn-danger',
    rel: 'nofollow'
  }) %>
</p>
```

If you check the source code, you can see that the same HTML is produced.

Notice that for destroying, I used `contact_path`. Look at `$ rake routes`
again:

```
contact GET    /contacts/:id(.:format)                         contacts#show
        PATCH  /contacts/:id(.:format)                         contacts#update
        PUT    /contacts/:id(.:format)                         contacts#update
        DELETE /contacts/:id(.:format)                         contacts#destroy
```

There's no prefix listed for `DELETE /contacts/:id`. That's because if multiple
paths share the same prefix, they are listed together, with the prefix for the
first working for all of them.

Finally, let's re-write our forms using Rails' form helpers. I'm going to get
rid of our `_form` partial for the moment, for the sake of clarity. Here's what
the form on the `new` page looks like currently:

`app/views/contacts/new.html.erb`

```html
...
<form action="/contacts" method="post">
  <div class="form-group">
    <label for="contact_name">Name</label>
    <input id="contact_name" name="contact[name]" type="text" value="<%= @contact.name %>">
  </div>
  <div class="form-group">
    <label for="contact_phone">Phone</label>
    <input id="contact_phone" name="contact[phone]" type="text" value="<%= @contact.phone %>">
  </div>
  <div class="form-group">
    <label for="contact_email">Email</label>
    <input id="contact_email" name="contact[email]" type="text" value="<%= @contact.email %>">
  </div>
  <button class="btn btn-primary">Create contact</button>
</form>
```

Here it is with the Rails `form_for` helper:

```html
...
<%= form_for(@contact) do |f| %>
  <div class="form-group">
    <%= f.label :name %>
    <%= f.text_field :name %>
  </div>
  <div class="form-group">
    <%= f.label :phone %>
    <%= f.text_field :phone %>
  </div>
  <div class="form-group">
    <%= f.label :email %>
    <%= f.text_field :email %>
  </div>
  <%= f.submit(:class => "btn btn-primary") %>
<% end %>
```

Now, here's something really awesome about `form_for`. Check out how we
refactor the form on our `edit` page. Before:

`app/views/contacts/edit.html.erb`

```html
...
<form action="/contacts/<%= @contact.id %>" method="post">
  <input name="_method" type="hidden" value="patch">
  <div class="form-group">
    <label for="contact_name">Name</label>
    <input id="contact_name" name="contact[name]" type="text" value="<%= @contact.name %>">
  </div>
  <div class="form-group">
    <label for="contact_phone">Phone</label>
    <input id="contact_phone" name="contact[phone]" type="text" value="<%= @contact.phone %>">
  </div>
  <div class="form-group">
    <label for="contact_email">Email</label>
    <input id="contact_email" name="contact[email]" type="text" value="<%= @contact.email %>">
  </div>
  <button class="btn btn-primary">Update contact</button>
</form>
```

After:

```html
...
<%= form_for(@contact) do |f| %>
  <div class="form-group">
    <%= f.label :name %>
    <%= f.text_field :name %>
  </div>
  <div class="form-group">
    <%= f.label :phone %>
    <%= f.text_field :phone %>
  </div>
  <div class="form-group">
    <%= f.label :email %>
    <%= f.text_field :email %>
  </div>
  <%= f.submit(:class => "btn btn-primary") %>
<% end %>
```

The forms are the same! `form_for` automatically detects if an object has been
saved to the database. If the object hasn't been saved, it builds a form that
makes a POST request. If the object has been saved, it adds the hidden field to
fake the PATCH request.

It also changes the text on the submit button accordingly: either Create
Contact or Update Contact.

Now, we can DRY up our `new` and `edit` pages with a partial again:

`app/views/contacts/_form.html.erb`

```html
<%= render("layouts/errors", :object => @contact) %>

<%= form_for(@contact) do |f| %>
  <div class="form-group">
    <%= f.label :name %>
    <%= f.text_field :name %>
  </div>
  <div class="form-group">
    <%= f.label :phone %>
    <%= f.text_field :phone %>
  </div>
  <div class="form-group">
    <%= f.label :email %>
    <%= f.text_field :email %>
  </div>
  <%= f.submit(:class => "btn btn-primary") %>
<% end %>
```

And then our `new` and `edit` views become simply:

`app/views/contacts/new.html.erb`

```html
<%= content_for(:title, "New contact | Wikipages") %>

<h1>New contact</h1>

<%= render 'form' %>
```

`app/views/contacts/edit.html.erb`

```html
<%= content_for(:title, "Edit contact | Wikipages") %>

<h1>Edit contact</h1>

<%= render 'form' %>
```

## Security Basics

### CSRF

If you look at the HTML that `form_for` generates, you'll see that there are a
few extra bits of code, among them:

```html
<input name="authenticity_token" type="hidden" value="c6j4CiHdGCJ5NcjWXvEQXGIsjCbrKQ4zpJYcyhCWn9E=" />
```

This authenticity token protects against **cross-site request forgery**, or CSRF
attacks. Here's a simplified example of how CSRF works:

1. You log into your bank account at `www.bank.com` and a cookie is placed on
   your computer to identify you.
2. You don't log out, and then you visit a chat board. The cookie remains on
   your computer.
3. On the chat board, a malicious user named Evil Alice posts an image with
   this tag:
   ```html
   <img src="http://www.cutekittens.com/really_cute_cat.png"
   width="400" height="400"
   onload="$.post('http://www.bank.com/transfer?to=evil_alice&amount=1000000')" />
   ```
   (**NOTE:** As Jarrett pointed out in class, if your bank blindly accepts
   transfer commands in query strings like this you need a new bank.)
4. When you view the page, loading the image silently triggers a POST request
   to your bank account, and your browser sends the cookie along with it,
   letting Evil Alice steal $1,000,000 from your bank account.

To protect against this, Rails creates an unguessable string called an
authenticity token. `form_for` automatically adds the token to your forms. And
remember that `<%= csrf_meta_tags %>` in `application.html.erb`? That includes
the token as well, so that when you make a JavaScript request (such as our
delete links), it can pass along the token, too. Evil Alice doesn't know what
this string is, so her requests will be rejected and you will be safe.

For CSRF protection to work, we have to turn it on. In our
`ApplicationController`, we simply stop commenting out this line:

```ruby
protect_from_forgery with: :exception
```

And now, we've protected our apps against CSRF attacks with no further work
needed.

### Mass assignment

Now that you know the basics of Rails, there are many more great resources
online that you can use. Wherever possible, I'm going to start directing you
towards other material, so that you can get comfortable with other resources
for continuing your learning. One amazing resource is
[Railscasts](http://railscasts.com/). Start out by watching
[the Railscast on mass assignment](http://railscasts.com/episodes/26-hackers-love-mass-assignment-revised);
however, note that the solution it shows is for Rails 3, not Rails 4. There are
a lot of Rails 3 apps still out there, so it's good to know how they work.
Then, read this [blog post on strong
parameters](http://blog.teamtreehouse.com/rails-4-strong-paremeters);
**strong parameters** is Rails 4's way of dealing with mass assignment. Now
that you're ready to use strong parameters, you can stop including
`config.action_controller.permit_all_parameters = true` in `application.rb`.

By the way, the move from `attr_accessible` to strong parameters was the main
change between Rails 3 and Rails 4.

### SQL Injection

Read [the Rails guide on SQL injection](http://guides.rubyonrails.org/security.html#sql-injection).

### Cross-Site Scripting (XSS)

First, watch [an older Railscast on cross-site
scripting](http://railscasts.com/episodes/27-cross-site-scripting). You can
stop watching this video at 3:32, because everything after that is out of date.
Then, watch [this newer Railscast on XSS in Rails
3](http://railscasts.com/episodes/204-xss-protection-in-rails-3), which also
applies to Rails 4.

## Authentication

Learning how to let users sign in and out of an app, and controlling who has
access to what parts of the app, will open up many more possibilities in what
you can build. Go through the [Authentication from Scratch Railscast](http://railscasts.com/episodes/250-authentication-from-scratch-revised)
to learn the basics. You'll run across gems like
[Devise](http://www.gotealeaf.com/blog/how-to-use-devise-in-rails-for-authentication)
and CanCan -- now superseded by CanCanCan (see next section) -- at some point.
Resist the temptation to use them\* for now, as we'll get to them in a bit. In
this video, you'll see Ryan use `rails g resource`, which, as I warned you
about earlier, isn't something you should use\* when coding. It's just a
shortcut for creating a pre-built controller, routes, specs, and a bunch of
other files, most of which you'll never use. Instead, create the routes and
controllers yourself, by hand.

\* **NOTE:** Jarrett says that most Rails devs do, in fact, use these things
all the time to speed development and improve productivity. He says it's
important to understand how they work, but they're too useful to avoid
completely.

## Authorization with CanCan(Can)

* [CanCanCan Tutorial 1](http://www.sitepoint.com/cancancan-rails-authorization-dance/)
* [CanCanCan Tutorial 2](http://hibbard.eu/authentication-with-devise-and-cancancan-in-rails-4-2/)

As your applications get more complex, you'll find that you often have multiple
kinds of users, each with different levels of permissions. The CanCan gem
provides a simple interface to manage authorization in your app. Watch the
[CanCan Railscast](http://railscasts.com/episodes/192-authorization-with-cancan)
to get started. Don't worry about the `load_and_authorize_resource` method;
it's not terribly common to use it.

CanCan's author disappeared for an extended vacation, so some concerned
community members forked the gem and continued work on it as
[CanCanCan](https://github.com/CanCanCommunity/cancancan), which you should use
in your apps instead of CanCan.

One of my favorite features of CanCan that I think people use too little is
unit testing your permissions. As your authorization structures get more
complex, you'll find that it gets a bit tricky to write and implement CanCan
permissions. Unit tests help you isolate the permission you're working on and
write a simple test around it. Here's an example of a CanCan unit test (the
`admin` factory presumably is a user with the `role` attribute set to `:admin`):

```ruby
require "cancan/matchers"

describe Ability do
  it 'lets a user update their own listing' do
    user = FactoryGirl.create(:user)
    listing = FactoryGirl.create(:listing, :user_id => user.id)
    ability = Ability.new(user)
    ability.should be_able_to(:update, listing)
  end

  it "prevents a user from updating somebody else's listing" do
    other_user = FactoryGirl.create(:user)
    listing = FactoryGirl.create(:listing)
    ability = Ability.new(user)
    ability.should_not be_able_to(:update, listing)
  end
end
```
