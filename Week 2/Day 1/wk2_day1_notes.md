# Ruby on Rails Week 2, Day 1

## Relationships

Let's continue with our Wikipages app and add support for multiple phone
numbers and addresses. We'll create a migration and model for phones:

`db/migrate/20140330221933_create_phones.rb`

```ruby
class CreatePhones < ActiveRecord::Migration
  def change
    create_table :phones do |t|
      t.column :number, :string
      t.column :contact_id, :integer
    end
  end
end
```

We'll create a model, some specs, and a couple features:

`spec/models/phone_spec.rb`

```ruby
require 'rails_helper'

describe Phone do
  it { should validate_presence_of :number }
  it { should validate_presence_of :contact_id }

  it { should belong_to :contact }
end
app/models/phone.rb
class Phone < ActiveRecord::Base
  belongs_to :contact

  validates :number, :presence => true
  validates :contact_id, :presence => true
end
```

And also create the `has_many` association from contacts to phones:

`spec/models/contact_spec.rb`

```ruby
require 'rails_helper'

describe Contact do
  it { should have_many :phones }
end
spec/models/contact.rb
class Contact < ActiveRecord::Base
  has_many :phones
end
```

Now that we have the models set up, let's create views, controllers, and
routes. Let's start by updating our `contacts/show.html.erb` view:

`app/views/contacts/show.html.erb`

```
<h1><%= @contact.name %></h1>

<a href="/contacts/<%= @contact.id %>/phones/new">Add phone</a>
```

The embedded Ruby will turn into a link that looks something like
`/contacts/1/phones/new`. This is called a nested route, because the route for
the phone is nested within the route for the contact. Let's write a route for
it now:

```ruby
match('contacts/:contact_id/phones/new', {:via => :get, :to => 'phones#new'})
```

Here's our controller method:

`app/controllers/phones_controller.rb`

```ruby
class PhonesController < ApplicationController
  def new
    contact = Contact.find(params[:contact_id])
    @phone = contact.phones.new
    render('phones/new.html.erb')
  end
end
```

And a view:

`app/views/phones/new.html.erb`

```
<h1>New phone number for <%= @phone.contact.name %></h1>

<% if @phone.errors.any? %>
  <h3>Please fix these errors:</h3>
  <ul>
    <% @phone.errors.full_messages.each do |message| %>
      <li><%= message %></li>
    <% end %>
  </ul>
<% end %>

<form action="/contacts/<%= @phone.contact.id %>/phones" method="post">
  <label for="phone_number">Number</label>
  <input id="phone_number" name="number" type="text" value="<%= @phone.number %>">
  <button>Add phone</button>
</form>
```

When we submit the form, it will create a POST request to `/contacts/1/phones`
(assuming the contact's ID is 1). Let's make a route for that form submission:

```ruby
match('contacts/:contact_id/phones', {:via => :post, :to => 'phones#create'})

```

And a controller action:

`app/controllers/phones_controller.rb`

```ruby
class PhonesController < ApplicationController
  def create
    @phone = Phone.new(:number => params[:number],
                       :contact_id => params[:contact_id])
    if @phone.save
      render('phones/success.html.erb')
    else
      render('phones/new.html.erb')
    end
  end
end
```

I'll leave it to you to write the `success.html.erb` view.

Here's an update to `show.html.erb` to allow editing and deleting phones:

`app/views/contacts/show.html.erb`

```
<h1><%= @contact.name %></h1>

<p>Phones:</p>

<ul>
  <% @contact.phones.each do |phone| %>
    <li>
      <%= phone.number %> |
      <a href="/contacts/<%= @contact.id %>/phones/<%= phone.id %>/edit">Edit</a> |
      <a href="/contacts/<%= @contact.id %>/phones/<%= phone.id %>"
         data-confirm="You sure?"
         data-method="delete"
         rel="nofollow">Delete</a>
    </li>
  <% end %>
</ul>
```

Now, we've got the first two of the seven RESTful actions built out -- `new` and
`create`. I'll leave it to you to write routes, controllers, and views for
editing, updating, and deleting phones. I don't think it's necessary to write
`show` or `index` actions: I don't think anybody would ever want to see all of
the phones listed outside of each individual contact, and phones are so simple
that they don't need a dedicated `show` page outside of listing them on the
contact's `show` page.

## Redirecting

[Video](http://player.vimeo.com/video/90711234)

So far, our apps always render back an HTML document to the browser after a
request is made. But often this isn't an ideal response. In Wikipages, for
example, when we create a new contact, we are given a success page, from which
we have to click a link to go somewhere else. The current setup looks something
like this:

![](http://images.learnhowtoprogram.com/redirecting/post-and-render-success.png)

The browser makes a POST request to `/contacts` with the form contents. The
server returns a 200 response, and renders the `success.html.erb` view into
HTML that the browser displays.

Wouldn't it be nice if instead we displayed the contact that was created? We
could do something like this:

`app/controllers/contacts_controller.rb`

```ruby
class ContactsController < ApplicationController
  def create
    @contact = Contact.new(params[:contact])
    if @contact.save
      render ('contacts/show.html.erb')
    else
      render ('contacts/new.html.erb')
    end
  end
end
```

In terms of HTTP requests, it would look like this:

![](http://images.learnhowtoprogram.com/redirecting/post-and-render-show.png)

But then the URL in the address bar will be `http://localhost:3000/contacts`,
since that is the path that the form was submitted to. If the user presses the
refresh button, it will submit the form again and create another contact. And
if they bookmark or share the URL, when it's visited again, the browser will
make a GET request to /contacts, since the URL doesn't store what HTTP method
was used and browsers will make a GET request by default. We want the URL to
match what's on the page.

We can do that by redirecting. Here's how it looks in terms of HTTP requests.
First, the browser makes a POST to create the contact, and the server returns a
302 redirect response and the URL of the contact that was created, then the
browser makes a new GET request for the newly-created contact.

Here's the whole redirect cycle all together:

![](http://images.learnhowtoprogram.com/redirecting/full-redirect-cycle.png)

Here's the controller code to make it happen:

`app/controllers/contacts_controller.rb`

```ruby
class ContactsController < ApplicationController
  def create
    @contact = Contact.new(params[:contact])
    if @contact.save
      redirect_to("/contacts/#{@contact.id}")
    else
      render('contacts/new.html.erb')
    end
  end
end
```

Redirects are typically used after successfully creating, updating, and
destroying. Unsuccessful creates/updates are usually followed by a render, so
that the problematic information can be displayed on the screen to be fixed.

Remember, `redirect_to` takes a URL as its argument, while `render` takes a
view. Also `redirect_to` causes the browser to make an _entirely new_ request,
while `render` simply returns HTML as a response to the current request.
