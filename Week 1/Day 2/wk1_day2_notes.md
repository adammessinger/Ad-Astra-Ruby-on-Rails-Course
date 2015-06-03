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
looks pretty similar to before, but look closely at the parameters:

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

To-Do List:

* Get Day 2 Notes from Canvas
* Look ahead for the Rails shortcuts we're going to start using
* Check out Heroku
