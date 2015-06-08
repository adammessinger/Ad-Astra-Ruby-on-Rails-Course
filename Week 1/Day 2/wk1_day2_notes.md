# Ruby on Rails Week 1, Day 2

## Rails Routing, Controllers, and Views

[Video](http://player.vimeo.com/video/90390483)

So far, there hasn't been a whole lot new here. Let's get into the new stuff and
fire up the Rails server by running `$ rails server`. Now, if we go to
`http://localhost:3000` in our web browser, we can see a default page that
Rails gives us. If this web address looks weird to you, here's a quick
explanation. Domain names (like epicodus.com) are translated into IP addresses
(like `324.100.95.232` - that's not the real IP, I'm just making it up). An IP
address that points at your own computer is `0.0.0.0`. You access web servers
via ports; the port that most web traffic runs over is 80. So when you go to
epicodus.com, you actually would go to something like `324.100.95.232:80`. The
Rails server by default runs on port 3000. I have no idea why.

To make things even more confusing, `0.0.0.0`, `127.0.0.1`, and `localhost` all
point to the computer you're currently working on. Typically, people use
`localhost` more than the other two.

So now we've got a server running. To actually use the model we created, we
need to makes routes, a controller, and some views. We'll start with an "index"
route to show all of the contacts. Let's put a few contacts in the database so
that we actually have some to list out. We'll open the Rails console and run:

```ruby
Contact.create({:name => 'Jill', :phone => '5035551212', :email => 'jill@example.com'})
Contact.create({:name => 'Jack', :phone => '4155551212', :email => 'jack@example.com'})
Contact.create({:name => 'Obama', :phone => '8005551212', :email => 'obama@whitehouse.gov'})
```

Now, for our route. Let's open up `config/routes.rb` and add this route (the
line that starts with `match`):

```ruby
Rails.application.routes.draw do
  match('contacts', {:via => :get, :to => 'contacts#index'})
end
```

This says that when the server receives a `GET` request to
`http://localhost:3000/contacts`, it will go to the contacts controller, and
run the `index` action. Let's make our controller now. We'll create
`app/controllers/contacts_controller.rb`, and in it write:

```ruby
class ContactsController < ApplicationController
  def index
    @contacts = Contact.all
    render('contacts/index.html.erb')
  end
end
```

**NOTE:** controllers use the plural form, `contacts`.

Controllers are weird. They are Ruby classes, but we never make instances of
them. They have methods, but we never call these methods directly. Don't think
of them like you would your models. Just accept that they use Ruby syntax, but
you won't use them like any other Ruby classes.

The last step is to create a folder in `app/views` called `contacts`, and in it
a file called `index.html.erb`. In that, we'll put:

```
<h1>Contacts</h1>

<ul>
  <% @contacts.each do |contact| %>
    <li><%= contact.name %></li>
  <% end %>
</ul>
```

The `erb` extension stands for _Embedded Ruby_. Any instance variables we set
in the controller action that renders this view are automatically available in
the view. In these views, we can run Ruby code by putting it inside of `<% %>`
tags; if we want the results of the Ruby code displayed in the HTML, we add an
equals sign like this: `<%= %>`.

Any instance variables set in the controller action that renders a view will be
available in that view. Since we set `@contacts = Contact.all` in
`ContactsController#index`, we have access to `@contacts` in our view.

In the view, inside of our `<ul>` tags, we've looped through `@contacts`, and
then inserted the contact's name inside of `<li>` tags. Pretty cool, huh?

Let's look at the fruits of our labor by visiting
`http://localhost:3000/contacts` in the web browser. There's our page, in all
its glory! If we switch back to the Terminal, we can see the server logs that
include a bunch of useful information. `Started GET "/contacts"` means that our
browser made a `GET` request to the route `/contacts` (we'll learn about other
types of requests shortly). Below that, you can actually see the SQL statement
that Active Record ran from `Contact.all`: `SELECT "contacts".* FROM
"contacts"`. Then, we can see the view that the controller rendered: `Rendered
contacts/index.html.erb`. And finally, we see the HTTP response code the server
returned to the browser: `Completed 200 OK`.

To review:

1. First, our browser made a `GET` request to `/contacts`.
2. The router matched the request to the contacts controller's `index` action.
3. The controller asked the model for all of the contacts with `Contact.all`,
   which it set to an instance variable `@contacts`.
4. The controller then rendered the `contacts/index.html.erb` view.
5. The view looped through `@contacts` and displayed each contact name on the
   page.
6. The server responded with a `200` status and the rendered view as the body
   of the response.

 Let's make another route, controller, and view to show more detailed
 information about each contact. If I visit `localhost:3000/contacts/1`, I want
 to see the contact with the ID 1. Since our database makes sure that each
 contact has a unique ID, the ID is a standard way to identify which contact we
 want to view. Here's the route:

```ruby
match('contacts/:id', {:via => :get, :to => 'contacts#show'})
```

The `:id` bit at the end tells the router that the ID is variable. Now, here's
the controller method:

```ruby
def show
  @contact = Contact.find(params[:id])
  render('contacts/show.html.erb')
end
```

This is similar to last time, where we pull information from the model, set it
to an instance variable, and then render a view. But this time, we're using a
new feature of Rails: the `params` hash. Let's take a closer look at our route
again: `match('contacts/:id', {:to => 'contacts#show', :via => :get})`. The
router makes the `params` hash available to the controller for every request. In
this request, the `:id` bit in the route tells the router to create a hash key
in `params` called `:id`, and assign a value to the hash of whatever is in that
part of the URL (which, in this case, would be `1`). In our controller action,
we're accessing the `:id` key of `params` to retrieve the ID of the contact we
want to show.

Phew! Now, let's make a view -- `app/views/contacts/show.html.erb` -- for this
controller action:

```
<h1><%= @contact.name %></h1>

<p>Phone: <%= @contact.phone %></p>
<p>Email: <%= @contact.email %></p>
```

And sure enough, if we go to `http://localhost:3000/contacts/1` in our web
browser, we can see our contact in all its glory. If we look at the server
logs, we can see a very similar story to the last request, including the HTTP
method, the path, the controller action, the SQL, the rendered view, and the
response code. There's something new in here, though: `Parameters:
{"id"=>"1"}`. This gives us insight into the params hash that the router has
generated. The key is displayed as a string, but Rails uses a special kind of
hash called a "hash with indifferent access", where it treats symbols and
strings equivalently.

To review:

1. First, our browser made a `GET` request to `/contacts/1`.
2. The router matched the request to the contacts controller's `show` action.
3. The router took the `1` from the request and in the `params` hash, set the
   `:id` key equal to `1`.
4. The controller took the `params` hash and accessed the `:id` key to get the
   `1`, and then asked the model for the Contact with that ID.
5. The controller set an instance variable `@contact` to the result of the
   query on that model.
6. The controller then rendered the `show` view.
7. The view displayed name, phone, and email from `@contact`.
8. The server responded with a `200` status and the rendered view as the body
   of the response.

Now, let's make our index page link to our contact show pages, and the show
page link back to the index. Here's my updated index view:

```
<h1>Contacts</h1>

<ul>
  <% @contacts.each do |contact| %>
    <li><a href="/contacts/<%= contact.id %>"><%= contact.name %></a></li>
  <% end %>
</ul>
```

And the updated show view:

```
<h1><%= @contact.name %></h1>

<p>Phone: <%= @contact.phone %></p>
<p>Email: <%= @contact.email %></p>

<p><a href="/contacts">Return to contact listing</a></p>
```

Let's keep going and make a page where we can create a new contact. Here's the
route:

```ruby
Rails.application.routes.draw do
  match('contacts', {:via => :get, :to => 'contacts#index'})
  match('contacts/new', {:via => :get, :to => 'contacts#new'})
  match('contacts/:id', {:via => :get, :to => 'contacts#show'})
end
```

We have to put the `contacts/new` route above `contacts/:id`, or the router
will think that `new` is the ID of a contact - Rails looks for a match in the
order the routes are listed.

**NOTE:** We'll soon be switching to a different approach to routes that will
involve more automation and less repetition.

Here's the controller action:

```ruby
def new
  render('contacts/new.html.erb')
end
```

And the view:

```
<h1>New contact</h1>

<form action="/contacts" method="post">
  <label for="contact_name">Name</label>
  <input id="contact_name" name="name" type="text">
  <label for="contact_phone">Phone</label>
  <input id="contact_phone" name="phone" type="text">
  <label for="contact_email">Email</label>
  <input id="contact_email" name="email" type="text">
  <button>Create Contact</button>
</form>
```

In our web browser, if we go to `http://localhost:3000/contacts/new`, we can
now see our page.

There are a couple new things in here. Let's start with the `action` and
`method` attributes on the `<form>` tag. These tell where to submit the form
to, and what HTTP method to use. That leads us to our next route:

```ruby
Rails.application.routes.draw do
  match('contacts', {:via => :get, :to => 'contacts#index'})
  match('contacts', {:via => :post, :to => 'contacts#create'})
  match('contacts/new', {:via => :get, :to => 'contacts#new'})
  match('contacts/:id', {:via => :get, :to => 'contacts#show'})
end
```

Which leads us to our next controller method:

```ruby
def create
  @contact = Contact.create(:name => params[:name],
                            :email => params[:email],
                            :phone => params[:phone])
  render('contacts/success.html.erb')
end
```

and a new view at `app/views/contacts/success.html.erb`:

```ruby
<h1>Contact saved!</h1>

<p>Your contact was successfully saved.</p>

<p><a href="/contacts/<%= @contact.id %>">View <%= @contact.name %></a></p>

<p><a href="/contacts">Return to contact listing</a></p>
```

Let's submit our form and see what happens. In the server logs, everything
looks pretty similar to before, but look closely at the parameters (the JS
dumped into the middle of things is part of a Rails security measure):

```
{"name"=>"Michael", "phone"=>"9995551212", "email"=>"michael@epicodus.com<span>
/* &lt;![CDATA[ */
(function(){try{var s,a,i,j,r,c,l,b=document.getElementsByTagName("</span><span>script</span><span>");l=b[b.length-1].previousSibling;a=l.getAttribute('data-cfemail');if(a){s='';r=parseInt(a.substr(0,2),16);for(j=2;a.length-j;j+=2){c=parseInt(a.substr(j,2),16)^r;s+=String.fromCharCode(c);}s=document.createTextNode(s);l.parentNode.replaceChild(s,l);}}catch(e){}})();
/* ]]&gt; */
</span>"}
```

These come from how we set up the form: each `<input>` tag had a `name`
attribute that looked something like `name="email"`. When the form is
submitted, the request body looks something like this:

```
name=Michael&phone=9995551212&email=michael@epicodus.com
```


The Rails router takes that request body and turns it into a hash. For example,
`name` is a key and `Michael` is a value; `phone` is a key, and `9995551212` is
a value.

Then, in our controller, we're able to access these values from the `params`
hash.

What happens if we try to create a contact that doesn't pass validation? Right
now, we show the success page regardless. Let's change this so that the user is
shown the form again and the errors are listed out. Here's the updated view,
`app/views/contacts/new.html.erb`:

```
<h1>New contact</h1>

<% if @contact.errors.any? %>
  <h3>Please fix these errors:</h3>
  <ul>
    <% @contact.errors.full_messages.each do |message| %>
      <li><%= message %></li>
    <% end %>
  </ul>
<% end %>

<form action="/contacts" method="post">
  <label for="contact_name">Name</label>
  <input id="contact_name" name="name" type="text" value="<%= @contact.name %>">
  <label for="contact_phone">Phone</label>
  <input id="contact_phone" name="phone" type="text" value="<%= @contact.phone %>">
  <label for="contact_email">Email</label>
  <input id="contact_email" name="email" type="text" value="<%= @contact.email %>">
  <button>Create Contact</button>
</form>
```

I've added a list of all the errors at the top, and also inserted the values of
the contact's existing attributes, so that the user doesn't have to re-type
everything if there is an error.

Before we update our controller, I want to show you how to use the
`better_errors` gem for debugging. Let's visit
`http://localhost:3000/contacts/new`. We get an error: `undefined method
'errors' for nil:NilClass`. We also get a snapshot of our code at the point
that the error occurred, and a live shell to play around and see what went
wrong. If we type `@contact` in the shell, we can see that it is `nil`.

Let's update the controller to fix this bug, and to handle when something isn't
saved properly:

```ruby
class ContactsController < ApplicationController
  def new
    @contact = Contact.new
    render('contacts/new.html.erb')
  end

  def create
    @contact = Contact.new(:name => params[:name],
                           :email => params[:email],
                           :phone => params[:phone])
    if @contact.save
      render('contacts/success.html.erb')
    else
      render('contacts/new.html.erb')
    end
  end
end
```

Now, if we submit the form without including a name, we get the form back
again, with our data intact, and a list of the errors.

At this point, we're able to create, read, and list contacts. In our CRUD
paradigm, we still are missing the ability to update and destroy them. Let's
work on updating first.

Let's start with a route that lets us edit a contact by going to a URL like
`/contacts/1/edit`:

```ruby
Rails.application.routes.draw do
  match('contacts', {:via => :get, :to => 'contacts#index'})
  match('contacts', {:via => :post, :to => 'contacts#create'})
  match('contacts/new', {:via => :get, :to => 'contacts#new'})
  match('contacts/:id', {:via => :get, :to => 'contacts#show'})
  match('contacts/:id/edit', {:via => :get, :to => 'contacts#edit'})
end
```

Now, the controller method:

```ruby
class ContactsController < ApplicationController
  def edit
    @contact = Contact.find(params[:id])
    render('contacts/edit.html.erb')
  end
end
```

And the view, `app/views/contacts/edit.html.erb`:

```
<h1>Edit contact</h1>

<% if @contact.errors.any? %>
  <h3>Please fix these errors:</h3>
  <ul>
    <% @contact.errors.full_messages.each do |message| %>
      <li><%= message %></li>
    <% end %>
  </ul>
<% end %>

<form action="/contacts/<%= @contact.id %>" method="post">
  <input name="_method" type="hidden" value="patch">
  <label for="contact_name">Name</label>
  <input id="contact_name" name="name" type="text" value="<%= @contact.name %>">
  <label for="contact_phone">Phone</label>
  <input id="contact_phone" name="phone" type="text" value="<%= @contact.phone %>">
  <label for="contact_email">Email</label>
  <input id="contact_email" name="email" type="text" value="<%= @contact.email %>">
  <button>Update Contact</button>
</form>
```

If we go to `http://localhost:3000/contacts/1/edit`, we can see our
pre-populated form, ready for us to update the contact.

Notice this bit of code: `<input name="_method" type="hidden" value="patch">`.
Remember how I mentioned in the lesson on how the web works that web browsers
only support GET and POST methods? The `_method` input is Rails's way of
communicating that, even though this form is submitted using POST, it should
treat it as a PATCH request.

Now, we need to write a route and controller action to handle the form
submission:

```ruby
match('contacts/:id', {:via => [:patch, :put], :to => 'contacts#update'})
```

Here, we've actually mapped two HTTP methods: PATCH and PUT. PATCH is a newer
method for updating and is less common than PUT. Rails standardizes on PATCH,
but also encourages you to support PUT requests for backwards-compatibility.

Here's the controller action:

```ruby
class ContactsController < ApplicationController
  def update
    @contact = Contact.find(params[:id])
    if @contact.update(:name => params[:name],
                       :email => params[:email],
                       :phone => params[:phone])
      render('contacts/success.html.erb')
    else
      render('contacts/edit.html.erb')
    end
  end
end
```

The last thing we need to take care of is destroying a contact. Let's add a
link for this to our show page, `app/views/contacts/show.html.erb`:

```
<h1><%= @contact.name %></h1>

<p>Phone: <%= @contact.phone %></p>
<p>Email: <%= @contact.email %></p>

<p><a href="/contacts/<%= @contact.id %>/edit">Edit</a></p>
<p><a href="/contacts/<%= @contact.id %>"
      data-confirm="You sure?"
      data-method="delete"
      rel="nofollow">Delete</a></p>
<p><a href="/contacts">Return to contact listing</a></p>
```

Rails has some JavaScript that loads on every page that looks for these `data-`
attributes. If it sees `data-confirm` on a link, it will run a JavaScript
`confirm()` before letting the request go through. If it sees `data-method` on
a link, it will "fake" a different method than GET. Finally, `rel="nofollow"`
tells search engines and other bots that might be crawling your page not to
click the link - we don't want them going around deleting all of our data!

To wrap this up, let's write a route, controller action, and view to handle
this link:

`config/routes.rb`

```ruby
Rails.application.routes.draw do
  match('contacts/:id', {:via => :delete, :to => 'contacts#destroy'})
end
```

`app/controllers/contacts_controller.rb`

```ruby
class ContactsController < ApplicationController
  def destroy
    @contact = Contact.find(params[:id])
    @contact.destroy
    render('contacts/destroy.html.erb')
  end
end
```

`app/views/contacts/destroy.html.erb`

```
<h1>Contact deleted</h1>

<p>
  Would you like to <a href="/contacts">see all the contacts</a>, or
  <a href="/contacts/new">create a new one</a>?
</p>
```

To wrap up the basics of our app, let's write one more route for the homepage:

`config/routes.rb`

```ruby
Rails.application.routes.draw do
  match('/', {:via => :get, :to => 'contacts#index'})
end
```

Remember how I told you that you should more or less stick to the CRUD pattern
for your database-backed objects -- that if you need to do something to an
object that isn't a CRUD operation, you probably should be using another object
to model it, and most models should have the CRUD functionality available?

The four HTTP methods we're using -- POST, GET, PATCH, and DELETE -- map to the
CRUD paradigm: Create is POST, Read is GET, Update is PATCH, and Destroy is
DELETE. The fifth part of CRUD, List, maps to the GET index action. And then we
have the GET new and GET edit actions, which are basically tools to let the
user make a POST or PATCH request. These 7 actions are what we call **RESTful
actions**. **REST** stands for _REpresentational State Transfer,_ and it's an
approach to designing web services based around HTTP methods.

For now, a good rule of thumb is that for every model in your app, you should
have the seven RESTful routes and controller actions. You can get away with
having less of them sometime: for example, you could get rid of your new page,
and simply put a form for creating a new contact on your `index` page:

`app/views/contacts/index.html.erb`

```
<h1>Contacts</h1>

<ul>
  <% @contacts.each do |contact| %>
    <li><a href="/contacts/<%= contact.id %>"><%= contact.name %></a></li>
  <% end %>
</ul>

<h2>New contact</h2>

<% if @contact.errors.any? %>
  <h3>Please fix these errors:</h3>
  <ul>
    <% @contact.errors.full_messages.each do |message| %>
      <li><%= message %></li>
    <% end %>
  </ul>
<% end %>

<form action="/contacts" method="post">
  <label for="contact_name">Name</label>
  <input id="contact_name" name="name" type="text" value="<%= @contact.name %>">
  <label for="contact_phone">Phone</label>
  <input id="contact_phone" name="phone" type="text" value="<%= @contact.phone %>">
  <label for="contact_email">Email</label>
  <input id="contact_email" name="email" type="text" value="<%= @contact.email %>">
  <button>Create Contact</button>
</form>
```

But you should almost never create an action that isn't one of the seven
RESTful actions. If you think you need to, it almost always means you need to
create a new model for that functionality. You can think of REST as
object-oriented design for the web.

## Better Parameters

For the sake of clarity, I was a bit overly-verbose in how I wrote part of our controller actions. Check out this code:

```ruby
@contact=Contact.new(:name => params[:name],
                     :phone => params[:phone],
                     :email => params[:email])
```

The key in the hash passed to `Contact.new` is the same as the key in the
params hash. For example, `:name => params[:name]`. We can rewrite that as
simply:

```ruby
@contact=Contact.new(params)
```

The only problem with this is that sometimes other stuff gets included in the
params that has nothing to do with the contact (such as `:method => :patch`
when we're faking a PATCH request), and we don't want to pass that into
`Contact.new`. The common Rails solution is to nest our params. We want them to
come in looking like this:

```ruby
{:contact => { :name =>'Eleanor',
               :phone =>'1-800-WHITE-HOUSE',
               :email =>'eleanor@rooselvelt.com' } }
```

And then to access the hash in the controller like this:

```ruby
@contact=Contact.new(params[:contact])
```

To make the params come in that way, we need to change our forms from this:

```
<form action="/contacts/<%=@contact.id %>" method="post">
  <input name="_method" type="hidden" value="patch">
  <label for="contact_name">Name</label>
  <input id="contact_name" name="name" type="text" value="<%=@contact.name %>">
  <label for="contact_phone">Phone</label>
  <input id="contact_phone" name="phone" type="text" value="<%=@contact.phone %>">
  <label for="contact_email">Email</label>
  <input id="contact_email" name="email" type="text" value="<%=@contact.email %>">
  <button>Update contact</button>
</form>
```

to this (note the `name` attributes):

```
<form action="/contacts/<%=@contact.id %>" method="post">
  <input name="_method" type="hidden" value="patch">
  <label for="contact_name">Name</label>
  <input id="contact_name" name="contact[name]" type="text" value="<%=@contact.name %>">
  <label for="contact_phone">Phone</label>
  <input id="contact_phone" name="contact[phone]" type="text" value="<%=@contact.phone %>">
  <label for="contact_email">Email</label>
  <input id="contact_email" name="contact[email]" type="text" value="<%=@contact.email %>">
  <button>Update contact</button>
</form>
```

Rails will parse forms submitted with these names into a hash just like what we
want.

Going forward, you should write all of your forms and controllers this way.

## Heroku

Watch [this screencast on Heroku](http://www.codeschool.com/code_tv/heroku), a
platform that lets you put your Rails sites online. The video is from
[Code School](http://www.codeschool.com/), which offers a lot of mini-courses
on web and mobile development. Don't worry if you don't understand some of the
things the video uses for creating its Rails app, especially scaffolding: we'll
learn more later. Just focus on the Heroku part!

As you go through the video, keep in mind that some of their suggestions don't
apply to the way we've set things up. For example, we're using the
[rubygems-bundler](https://github.com/mpapis/rubygems-bundler) gem instead of
`bundle exec`, and we have installed Postgres through homebrew. Also, the video
shows how to install the Heroku toolbelt with the graphical installer, but on a
Mac, you can just run `brew install heroku-toolbelt` (that's how the computers
at Epicodus are set up).

This video shows how to deploy with a Rails 3 app. The only change for Rails 4
is that you need to include the `rails_12factor` gem for your app to work on
Heroku. The `rails_12factor` gem is only needed in production, so you can put
it in your `Gemfile` like this:

```ruby
group :production do
  gem 'rails_12factor'
end
```

Then run `$ bundle install --without production`. This will configure Bundler
not to install the 12factor gem locally. (Bundler will remember that setting
for your project, so you can just run `$ bundle` after that time.)

When you're working in pairs on a project, it's best to not create a separate
app for each of you. Instead, one of you can make the app on Heroku, and then
on the Heroku website, share it with the other pair.
