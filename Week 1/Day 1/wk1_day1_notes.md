# Ruby on Rails Week 1, Day 1

## How the Web Works

[Video](http://player.vimeo.com/video/90358671)

Before we learn Rails, let's go through a quick overview of how the web works.

Whenever you view a web page in a browser, your browser sends a request to a web
server, which returns a response containing the HTML (and CSS and JavaScript and
whatnot) that your browser renders into the web page. The protocol that
browsers and web servers use to communicate with each other is **HTTP**, or
_Hypertext Transfer Protocol._

Whenever you send an HTTP request, whether you're a web browser or an app,
you're called a client. The service that fulfills your request is called a
server.

First, let's go over HTTP requests. A request includes a method, a path,
headers, and a body.

Your web browser uses the GET method of HTTP to retrieve web pages and other
information from web servers. HTTP methods (also called verbs) indicate the
type of action that is intended to be performed. There are several other HTTP
methods, but the only other one that web browsers implement is the POST method,
which they use to submit forms.

More generally, the GET method retrieves information without changing anything
on the server; the POST method creates something on the server; PATCH or PUT
updates; and DELETE destroys.

For most requests, the path is just the URL, like
`http://www.adastraacademy.com/students.html`.

Headers include optional information, such as the format the client wants to
receive the response in (such as HTML or JSON) or authentication information to
identify who is making the request.

When you submit a form, the contents of the form get put into the body of the
request.

Now, let's move on to responses.

An HTTP response is broken into three parts: status, headers, and body.

The status is a three-digit code. The most common is 200, which means that a
request was successful. Here are some other common statuses, along with their
descriptions:

* 200 OK (successful)
* 201 Created
* 301 Moved Permanently
* 302 Moved Temporarily
* 400 Bad Request
* 403 Forbidden (it exists but you aren't allowed to see it)
* 422 Unprocessable Entity (you put in bad data)
* 404 Not Found
* 500 Internal Server Error
* 502 Bad Gateway (the server sent the request to another server and got an
  invalid response)
* 503 Service Unavailable (the server is overloaded or down for maintenance)

Generally, statuses beginning with a 2 (written as 2xx) are successful, 3xx
are redirects, 4xx means the client did something wrong, and 5xx means the
server did something wrong.

Headers might include the content type (such as HTML or JSON), or the location
to redirect to for a 3xx status.

The body includes the actual HTML, CSS, JavaScript, and so on. Some kinds of
responses, like errors, may not include a body.

To recap, the web uses a client-server model. A client, which could be a web
browser, a script, an application, or anything else, makes an HTTP request to a
server. The request includes the HTTP method, path, headers, and a body. The
method indicates the type of action to be performed, the path indicates what
the resource being accessed is, the headers include extra information (like
format or authentication), and the body includes information like the contents
of a form submission.

The server receives the request and returns a response. The response includes a
status, headers, and a body. The status tells the outcome of the request (such
as success or not found), the headers include extra information (like format or
URL to redirect to), and the body includes the actual content of the response
(like the HTML and CSS).

## Rails Setup, Database, and Models

[video](http://player.vimeo.com/video/90377820)

**NOTE:** With RSpec 3 (the latest version), you'll need to replace
`require 'spec_helper'` with `require 'rails_helper'`.

Ruby on Rails is a Model-View-Controller (MVC) framework -- though some, of
course, argue that it's not. Setting aside such semantic squabbles, here's what
those terms mean in Rails:

* _Models_ -- Represent data data, domain knowledge/logic. Handle talking to &
  updating the database. Though some say this isn't the "right" way to do it,
  models are where the business logic lives in a Rails application.
* _Views_ -- Handle presentation.
* _Controllers_ -- Puts it all together

The shorthand saying for the generally-accepted Rails best practice is "fat
models, skinny controllers." One alternate approach is to have skinny models and
controllers, but keep pieces of business logic in your `lib` directory.

MVC represented visually (by Dustin Brown):

![MVC visualization by Dustin Brown](http://images.learnhowtoprogram.com/mvc.jpg)

The idea is that a web browser makes a request to your web server. The router
parses the request and passes it to the controller, which in turn passes it to
the model to do some work. Then, the controller takes the result of that work
and passes it to the view. And finally, the controller returns the view back to
the browser.

The good news is that your Active Record models, the part of the MVC pattern
that does the work, will work exactly the same in Rails as they have with your
command-line apps from the previous class, so you already know how to build the
logic of a web application! And the views are just HTML with a little bit of
Ruby mixed in, so you already mostly know how to write views. Now, it's largely
just a matter of learning the router and controller glue that puts them
together.

### Starting a New Rails App

Let's make a new rails app -- a user-contributed white pages phonebook. Run
`$ gem install rails`, and then `$ rails new wikipages -d postgresql -T` to
make a new Rails app called `wikipages`. `-d postgresql` tells Rails to use
Postgres for the database, and `-T` tells it not to install its testing tools
-- by default, it uses a library called `test-unit`, whereas we use RSpec. To
make this the default configuration, so you can just run `$ rails new
your_app_name`, create a file called `.railsrc` in your home directory and type
`-d postgresql -T`.

Now, Rails will create a folder called `wikipages`. Let's take a look at it --
some of it should look very familiar. There's a `README`, a `Rakefile`, a
`Gemfile` and `Gemfile.lock`, and a `.gitignore`. `config.ru` is used by the
Rails web server to start your application. As for the folders, let's go
through those one at a time:

* `app`: Your models live in the `models` folder in `app`. There are also
  folders for controllers and views, as well as a few other things we'll touch
  on later.
* `bin`: We used to put the user interfaces in our `bin` folder. Now it holds a
  link to the Rails server and a few other common commands.
* `config`: What used to be `db/config.yml` is now `config/database.yml`. In
  addition, there are a few other configuration files here.
* `db`: This folder will hold your migrations and schema, just like you're used
   to. It also holds a seeds.rb file that you can use to put default values in
   your database.
* `lib`: Sorry to switch this one up on you and move your models to the
   app/models folder. The lib folder now contains a folder called tasks that you
   can put your own Rake tasks in.
* The `assets` folder we'll talk about later.
* `log`: Your web server will store its logs here.
* `public`: Static files for error messages go here.
* `tmp`: This is where your web server's temporary files go.
* `vendor`: Gems can be installed here in some cases (but not any cases we'll deal with).

Realistically, you only need to worry about the `app`, `config`, and `db`
folders. And 99% of your time you'll spend in the app folder. So don't feel
overwhelmed!

There are two, small, temporary configuration changes we need to make before
starting. In `config/application.rb`, we need to add
`config.action_controller.permit_all_parameters = true` just before the last two
`end` keywords. And in `app/controllers/application_controller.rb`, we need to
comment out the line that says `protect_from_forgery with exception`. We'll
discuss these more later.

To finish getting things set up, let's edit our `config/database.yml` to look
like our previous `config.yml`s:

```yaml
development:
  adapter: postgresql
  database: wikipages_development

test:
  adapter: postgresql
  database: wikipages_test
```

Now, we can create our databases just like before with `rake db:create`.

We used to run `$ rake db new_migration name=create_contacts`, but that Rake
task was specific to Standalone Migrations, since we obviously couldn't use the
Rails generator without Rails. Let's use Rails to make a migration:

```
$ rails generate migration create_contacts
```

Or, `rails g migration create_contacts` for short.

Now, let's write our migration.

`db/migrate/20140326234344_create_contacts`:

```ruby
class CreateContacts < ActiveRecord:Migration
  def change
    create_table :contacts do|t|
      t.column :name,  :string
      t.column :phone, :string
      t.column :email, :string

      t.timestamps null: false
    end
  end
end
```

Now we can migrate and prepare our test database just like we did before with
`rake db:migrate`. And just like before, there's now a `schema.rb` file in `db`.

Let's install RSpec and Shoulda now, as well as a few extra gems. Put these 5
gems at the bottom of the `Gemfile` inside the last block.

* `rspec-rails` to use rspec
* `shoulda-matchers` to use in our specs
* `better_errors` to help us debug
* `binding_of_caller` to help with debugging as well
* `quiet_assets` to make our logs easier to read

Here's how my `Gemfile` looks (I've removed the comments, which you can read
another time, the version numbers, the `sdoc` gem, which is only useful for
creating documentation, and `jbuilder`, which we'll learn more about later):

```ruby
source 'https://rubygems.org'

gem 'rails'
gem 'pg'
gem 'sass-rails'
gem 'uglifier'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'turbolinks'

group :test, :development do
  gem 'byebug'
  gem 'web-console'
  gem 'spring'

  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets'

  gem 'rspec-rails'
  gem 'shoulda-matchers'
end
```

After running bundle, let's run `$ rails generate rspec:install`. This creates
our familiar `spec` folder and `spec_helper.rb`. One really cool feature of
`rspec-rails` is the line in `spec_helper.rb` that says
`config.use_transactional_fixtures = true`. This wraps each spec in an Active
Record transaction, which is rolled back after it runs. That way, you don't
have to delete all of the entries in your test database after each spec. Nifty,
huh?

Let's write our first test. Create a `models` folder in `spec` and add a file
called `contact_spec.rb`:

```ruby
require 'rails_helper'

describe Contact do
  it { should validate_presence_of :name }
end
```

Nothing new here. We can run `$ rspec` to watch it fail with the error
`uninitialized constant Contact (NameError)`, just like before. Let's make it
pass, by creating a `contact.rb` file in `app/models` and putting in it:

```ruby
class Contact < ActiveRecord::Base
  validates :name, :presence => true
end
```

Now, here's a cool new feature of Rails. If we run `$ rails console`, we'll get
an IRB shell with our entire Rails development environment loaded. Try some
familiar Ruby and Active Record commands like `>Contact.create(:name => 'Chuck
Norris')`. The Rails console can be really helpful for playing around and
testing things as you're figuring out how to build them.
