# Ruby on Rails Week 2, Day 2

## The Layout

Have you noticed how your views actually contain a valid HTML document, but you
never write the `<body>` and `<title>` and other tags like that yourself? That's
because they're in the `app/views/layouts/application.html.erb` file, which
looks something like this:

```html
<!DOCTYPE html>
<html>
<head>
  <title>Wikipages</title>
  <%= stylesheet_link_tag    "application", media: "all", "data-turbolinks-track" => true %>
  <%= javascript_include_tag "application", "data-turbolinks-track" => true %>
  <%= csrf_meta_tags %>
</head>
<body>

<%= yield %>

</body>
</html>
```

We'll learn about the `stylesheet_link_tag` and `javascript_include_tag` next lesson, and `csrf_meta_tags` soon after.

The `<%= yield %>` bit of code is where your views are inserted. If you ever
want to change something on all of your pages -- such as adding a logo or nav
bar -- this layout file is the place to do it.

If we want to make every page have a different `<title>` we need a way to set
it in each view, and then retrieve it in the layout. Here's how to set it in
the `app/views/contacts/show.html.erb` view:

```html
<% content_for(:title, "New contact | Wikipages") %>

<h1>New contact</h1>
...
```

Then, here's how to retrieve it in the layout:

```html
<title><%= yield(:title) %></title>
```

When your layouts get more complex, such as with nav bars that change depending
on what page you're on, you can write longer `content_fors` like this:

```html
<% content_for(:navbar) do %>
<li><a href="/">Home</a></li>
<li><a href="something/else">Something else</a></li>
<li><a href="etc">Etc.</a></li>
<% end %>
```

## Flash Messages

Now that you've gotten to play around with redirects a bit, you might be
wishing you could add a message to the user after something is created,
updated, or destroyed, letting them know that the change was successfully made.
Rails provides a tool for doing this called **flash messages.** (Unrelated to
the Flash plugin, by the way.)

Here's how it works: Before you redirect to another page, you set a flash
message in the controller. The flash message is stored as a temporary cookie on
the user's browser. When the next page loads, the server sees the flash
message, adds it to the page (it's usually included in the layout), and clears
the cookie. If the user reloads the page or browses to a new page, the message
disappears.

Let's add a flash to Wikipages:

`app/controllers/contacts_controller.rb`

```ruby
class ContactsController < ApplicationController
  def create
    @contact = Contact.new(params[:contact])
    if@contact.save
      flash[:notice]="Your contact was added to Wikipages."
      redirect_to("/contacts/#{@contact.id}")
    else
      render('contacts/new.html.erb')
    end
  end
end
```

The flash acts very much like a hash, and the two keys you're allowed to set
are `flash[:notice]` and `flash[:alert]` (the latter usually being for errors).

Now, let's add the flash message to the layout, right above the page content:

`app/views/layouts/application.html.erb`

```html
<body>
<%= flash[:alert] %>
<%= flash[:notice] %>

<%= yield %>

</body>
```

If we create a contact, we can see our flash message. And if we refresh the
page, it disappears.

I'll leave it as an exercise for you to add flash messages to your update and
destroy methods in your apps.

## Template Partials

It's been bothering me that our `new.html.erb` and `edit.html.erb` views tend
to look almost exactly the same:

`app/views/contacts/new.html.erb`

```html
<% content_for(:title, "New contact | Wikipages") %>

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
  <input id="contact_name" name="contact[name]" type="text" value="<%= @contact.name %>">
  <label for="contact_phone">Phone</label>
  <input id="contact_phone" name="contact[phone]" type="text" value="<%= @contact.phone %>">
  <label for="contact_email">Email</label>
  <input id="contact_email" name="contact[email]" type="text" value="<%= @contact.email %>">
  <button>Create Contact</button>
</form>
```

`app/views/contacts/edit.html.erb`

```html
<% content_for(:title, "Edit contact | Wikipages") %>

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
  <input id="contact_name" name="contact[name]" type="text" value="<%= @contact.name %>">
  <label for="contact_phone">Phone</label>
  <input id="contact_phone" name="contact[phone]" type="text" value="<%= @contact.phone %>">
  <label for="contact_email">Email</label>
  <input id="contact_email" name="contact[email]" type="text" value="<%= @contact.email %>">
  <button>Update Contact</button>
</form>
```

I'd like to DRY them up. To do that, we'll make a partial that can be included
in multiple views. Partials **must** have a file name that begins with an
underscore. I'm going to start out by creating a partial for the common parts
of the form:

`app/views/contacts/_form.html.erb`

```html
<label for="contact_name">Name</label>
<input id="contact_name" name="contact[name]" type="text" value="<%= @contact.name %>">
<label for="contact_phone">Phone</label>
<input id="contact_phone" name="contact[phone]" type="text" value="<%= @contact.phone %>">
<label for="contact_email">Email</label>
<input id="contact_email" name="contact[email]" type="text" value="<%= @contact.email %>">
```

Then, I'll replace those common parts like this:

`app/views/contacts/new.html.erb`

```html
<form action="/contacts" method="post">
  <%= render('form') %>
  <button>Create Contact</button>
</form>
```

`app/views/contacts/edit.html.erb`

```html
<form action="/contacts/<%= @contact.id %>" method="post">
  <input name="_method" type="hidden" value="patch">
  <%= render('form') %>
  <button>Update Contact</button>
</form>
```

Let's do something similar with errors. The code for errors could actually be
used in any form, so I want to make it general-purpose and be able to use it
for contacts, phones, emails, and anything else where a form might have errors.
Since this partial could be used anywhere in our application, let's put it in
our layouts folder. Here's the code for it:

`app/views/layouts/_errors.html.erb`

```html
<% if object.errors.any? %>
  <h3>Please fix these errors:</h3>
  <ul>
  <% object.errors.full_messages.each do |message| %>
    <li><%= message %></li>
  <% end %>
  </ul>
<% end %>
```

Notice I've changed `@contact` to object so that it has a general name and is a
local variable instead of an instance variable. Now, here's how I use the
partial above my forms:

`app/views/contacts/edit.html.erb`

```html
<h1>Edit contact</h1>

<%= render('layouts/errors', object: @contact) %>

<form action="/contacts/<%= @contact.id %>" method="post">
...
```

Thanks Rails for helping us keep our code DRY!

## Sass, the Asset Pipeline, and Bootstrap

Rails includes a feature called the asset pipeline for managing your CSS and
JavaScript. The asset pipeline does two things, [according to the Rails
Guide](http://guides.rubyonrails.org/asset_pipeline.html): "The asset pipeline
provides a framework to concatenate and minify or compress JavaScript and CSS
assets. It also adds the ability to write these assets in other languages such
as CoffeeScript, Sass and ERB."

First, let's learn about one of these other languages: Sass. Start off by
reading [the official introduction to Sass](http://sass-lang.com/guide).

Next, let's learn about the other main language supported by the asset
pipeline: CoffeeScript. Check out [the CoffeeScript
overview](http://coffeescript.org/) on its homepage.

Sass (and its cousin [Less](http://lesscss.org/)) are becoming very popular,
because CSS is so limited in its abilities (e.g. lack of variables) and
encourages poor organization (e.g. lack of nesting). CoffeeScript has become
somewhat popular, but I think it's popularity has started to wane somewhat, as
only Rubyists make such a fuss about semicolons and curly braces.

Now, let's learn about the asset pipeline. The [asset pipeline Rails
Guide](http://guides.rubyonrails.org/asset_pipeline.html) is great, but a bit
dense and parts of it may be over your head right now. So, I'm going to point
you to a few specific sections to read:

* [Manifest Files and Directives](http://guides.rubyonrails.org/asset_pipeline.html#manifest-files-and-directives)
* [Preprocessing](http://guides.rubyonrails.org/asset_pipeline.html#preprocessing)
* [Use in development](http://guides.rubyonrails.org/asset_pipeline.html#in-development)
* [Use in production](http://guides.rubyonrails.org/asset_pipeline.html#in-production) (just the intro section)

When you push to Heroku, Heroku automatically precompiles your asset pipeline
for you. Pretty sweet!

Finally, let's learn how to use Bootstrap with the asset pipeline. Bootstrap
has [a Sass-based gem](https://github.com/twbs/bootstrap-sass). The Readme is a
little confusing, so again, I'm going to point you to specific sections:

* [Installing with Rails](https://github.com/twbs/bootstrap-sass#a-ruby-on-rails)
* [Usage with Sass](https://github.com/twbs/bootstrap-sass#sass) (note: you
  need to rename application.css to application.css.scss for the asset pipeline
  to correctly interpret it as Sass)
* [Usage with JavaScript](https://github.com/twbs/bootstrap-sass#javascript)

Now, you can add Bootstrap classes to your views!

## Integration Testing

We've stressed unit testing on our models very heavily throughout Ad Astra. But
what about the other parts of your application? You could have a typo in your
views, controllers, or routes that causes an error to show up for your users,
and if you forget to manually check a single page, you could miss an important
bug. Or you could improperly integrate a gem into your app, and have some
functionality not work properly.

To help catch these kinds of problems, developers use ***integration
testing.*** The type of integration tests we'll write will simulate a user
using your app, clicking links, and filling out forms. To write integration
tests, we'll use a gem called _Capybara._ Add `'capybara'` to your `Gemfile` in
the `test` section, run `bundle install`, add `require 'capybara/rails'` to
your `rails_helper`, and then create a `spec/features` folder for your
integration tests. Now, you can create files in that folder with tests for each
of the flows through your app. For example:

`signin_pages_spec.rb`

```ruby
require 'rails_helper'

describe "the signin process" do
  it "signs a user in who uses the right password" do
    visit '/sessions/new'
    user = User.create(:email => 'user@example.com', :password => 'password')
    fill_in 'Login', :with => 'user@example.com'
    fill_in 'Password', :with => 'password'
    click_button 'Sign in'
    page.should have_content 'Welcome!'
  end

  it "gives a user an error who uses the wrong password" do
    visit '/sessions/new'
    user = User.create(:email => 'user@example.com', :password => 'password')
    fill_in 'Login', :with => 'user@example.com'
    fill_in 'Password', :with => 'wrong'
    click_button 'Sign in'
    page.should have_content 'wrong'
  end
end
```

Here are a couple things to note:

* Notice how I have two specs, one for each possible flow through the signin
  process.
* Presumably, in some other test I'm testing the pages and forms where users
  get created, so I'm skipping that step and just creating users directly with
  Ruby, rather than filling out the forms again. Integration tests run slowly,
  so you only want to test each flow once. Also, if you change the flow, you
  don't want to have to change a bunch of tests.
* My assertion (`page.should have_content`) just tests for one snippet of text
  on the page. Again, this makes it easier to change our app (e.g. if we want to
  update the welcome or failure messages) without changing a lot of tests.
* I'm only testing one error -- wrong password. I'm not bothering to check for
  the wrong email. My model tests already cover how authentication should work,
  and I don't need to duplicate every single model test in an integration test.
  I just want to make sure the general flows of the app work properly, and I'll
  trust my model tests to cover the rest.
* The filename ends in `_pages_spec.rb`. This is fairly conventional.

Let's look at one more example:

`votes_pages_spec.rb`

```ruby
require 'spec_helper'

describe "voting for your favorite celebrity" do
  it "allows a signed-in user to upvote" do
    User.create(:email => 'test@email.com', :password => 'password')
    visit '/'
    fill_in 'Email', :with => 'test@email.com'
    fill_in 'Password', :with => 'password'
    click_on 'Log in'
    Celebrity.create(:name => 'Madonna')
    visit '/celebrities'
    click_button 'Cast your vote!'
    page.should have_content 'You voted for Madonna!'
  end

  it "redirects users who are not signed in to create an account" do
    Celebrity.create(:name => 'Madonna')
    visit '/celebrities'
    click_button 'Cast your vote!'
    page.should have_content 'create an account'
  end
end
```

For more info on what you can do with Capybara, [check out the Capybara
README](https://github.com/jnicklas/capybara); the good stuff comes at
[Using Capybara with RSpec](https://github.com/jnicklas/capybara#using-capybara-with-rspec) and
[The DSL](https://github.com/jnicklas/capybara#the-dsl).

Also, be sure to check out
[the launch gem](https://github.com/copiousfreetime/launchy), which makes
debugging Capybara tests much easier.

Your goal should be to write an integration test for every flow through your
app: make sure every page gets visited, that every form gets submitted
correctly one time and incorrectly one time, and test each flow for different
types of users who may have different permissions (to make sure they can visit
the pages they're allowed to, and not visit the pages they're not allowed to).
You should have a lot of integration tests for your apps!
