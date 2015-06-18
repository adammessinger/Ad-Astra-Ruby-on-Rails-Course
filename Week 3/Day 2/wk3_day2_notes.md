# Ruby on Rails Week 3, Day 2

## Paperclip

Often you'll need to handle file uploads to your app. The most popular gem for
helping out with this is Paperclip. Read [the Paperclip README](https://github.com/thoughtbot/paperclip)
carefully and thoroughly. Note that they use the example of a user's image
being called an "avatar". You can call the image on a model whatever you want,
though; there's nothing special about the word "avatar".

On your development machine, file uploads will be saved locally. In a
production application, your web servers should be independent from your
databases, so that you can add, remove, and restart web servers without
affecting your data. Read [Heroku's article about using S3 with
Paperclip](https://devcenter.heroku.com/articles/paperclip-s3) to see how to
set up Paperclip with Heroku. (S3 is a special database specifically for
storing files.) You should only use S3 in production; in development, stick
with Paperclip's defaults that upload files to your local filesystem.

The Heroku article mentions using config variables to store your S3
credentials. You should also read [Heroku's article about config
variables](https://devcenter.heroku.com/articles/config-vars).

## APIs & Twillio

**NOTE:** I forgot to mention in the video that you can set environmental
variables on Heroku like this:

```
$ heroku config:set TWILIO_ACCOUNT_SID=AC3e0af22b6b772460f352ba8c6586fbde
```

One of the great things about how the web has evolved is that there are now
thousands of services that you can program using HTTP requests. You'll often
hear these services referred to as **web service APIs**, or simply **APIs.**
API stands for application programming interface. API is a bit of an
over-abbreviation for a web service API, because any time that you make a
method on an object, you've made an API for it: methods are interfaces to
objects that let you program them. But the common parlance is that, when
talking about the web, API means a service that lets you program it by making
HTTP requests.

Most modern APIs use a RESTful design. Just like a method is an API to an
object, RESTful APIs make HTTP methods APIs to a URL. You're already familiar
with this pattern: `GET /contacts` means to retrieve a list of all the contacts,
`PUT /contacts/1` means to update contact #1, etc. But now, we're going to
start using other people's RESTful APIs. We'll start with
[Twilio](https://www.twilio.com/), a service for making and receiving text
messages and phone calls.

To start off learning about Twilio, read [their documentation on sending text
messages](https://www.twilio.com/docs/api/rest/sending-messages). Towards the
bottom, you'll see an example of how to use the Twilio Ruby library, but let's
stick with making the requests manually, so that you know what it's doing under
the hood. We'll use the [REST
client](https://github.com/rest-client/rest-client) gem to make HTTP requests.
Read the [examples in the
README](https://github.com/rest-client/rest-client#usage-raw-url) to see the
basic idea of how it works. Here's an example of how to send a text message
using REST client:

```
> require 'rest_client'
> RestClient.post('https://AC3e0af22b6b772460f352ba8c6586fbde:e04f17e88eb7b8c81feb1b951dcd7a2f@api.twilio.com/2010-04-01/Accounts/AC3e0af22b6b772460f352ba8c6586fbde/Messages.json', :Body => 'Hello world!', :To => '5038629187', :From => '5039463641')
```

`:Body`, `:To`, and `:From` are simply the Twilio parameters for the text
message's sender, recipient, and actual message.

As for the URL, the part after the `@` is just the URL from the documentation.
The `.json` extension tells Twilio to send the response back in JSON (as
opposed to XML -- JSON is much easier to work with). The part before the URL is
the Twilio Account Sid and Auth Token. If you noticed in the RESTclient
documentation, there was an example like this:

```
> RestClient.get 'https://user:password@example.com/private/resource'
```

The Account Sid maps to the user, and the Auth Token maps to the password. This
authentication scheme of passing two tokens that represent a username and
password is very common for APIs and is called **HTTP Basic Auth**.

When you create your own Twilio account, it will give you your own Account Sid
and Auth Token. For testing purposes, don't overlook the [test
credentials](https://www.twilio.com/user/account/developer-tools/test-credentials)
and [magic numbers](https://www.twilio.com/docs/api/rest/test-credentials#test-sms-messages)
that will let you test out sending messages for free. (Twilio gives you a $20
credit when you sign up, but you can use that up pretty quickly!) In your apps,
make sure that you store the credentials in environmental variables and not in
your source code.

REST Client has another syntax that I think makes it a bit more clear what is
going on:

```
> RestClient::Request.new(:method => :post, :url => 'https://api.twilio.com/2010-04-01/Accounts/AC3e0af22b6b772460f352ba8c6586fbde/Messages.json', :user => 'AC3e0af22b6b772460f352ba8c6586fbde', :password => 'e04f17e88eb7b8c81feb1b951dcd7a2f', :payload => {:Body => 'Hello world!', :To => '5038629187', :From => '5039463641'}).execute
```

`:payload` refers to the request body.

Okay, so now we've made a request. What about the response? It looks something
like this:

```
=> "{\"sid\": \"SMaae33aa216bd472bb11252938d6ac05a\", \"date_created\": null, \"date_updated\": null, \"date_sent\": null, \"account_sid\": \"AC3e0af22b6b772460f352ba8c6586fbde\", \"to\": \"+15038629187\", \"from\": \"+15039463641\", \"body\": \"Hello world!\", \"status\": \"queued\", \"num_segments\": null, \"num_media\": \"0\", \"direction\": \"outbound-api\", \"api_version\": \"2010-04-01\", \"price\": null, \"price_unit\": \"USD\", \"uri\": \"/2010-04-01/Accounts/AC3e0af22b6b772460f352ba8c6586fbde/Messages/SMaae33aa216bd472bb11252938d6ac05a.json\", \"subresource_uris\": {\"media\": \"/2010-04-01/Accounts/AC3e0af22b6b772460f352ba8c6586fbde/Messages/SMaae33aa216bd472bb11252938d6ac05a/Media.json\"}}"
```

This is pretty hard to see what's going on, but that's because it's all one
line. The response is in the **JSON** format, which stands for JavaScript
Object Notation. The JSON format looks an awful lot like objects in JavaScript
and hashes in Ruby. In fact, it's trivial to convert a JSON response into a
Ruby hash. Let's make a request again and save the response:

```
> response = RestClient::Request.new(:method => :post, :url => 'https://api.twilio.com/2010-04-01/Accounts/AC3e0af22b6b772460f352ba8c6586fbde/Messages.json', :user => 'AC3e0af22b6b772460f352ba8c6586fbde', :password => 'e04f17e88eb7b8c81feb1b951dcd7a2f', :payload => {:Body => 'Hello world!', :To => '5038629187', :From => '5039463641'}).execute
```

Now, we can parse the response using the Ruby JSON library:

```
> parsed_response = JSON.parse(response)
=> {"sid" => "SM0025dc49bcc2476b8b25043df36bfdf4", "date_created" => nil, "date_updated" => nil, "date_sent" => nil, "account_sid" => "AC3e0af22b6b772460f352ba8c6586fbde", "to" => "+15038629187", "from" => "+15039463641", "body" => "Hello world!", "status" => "queued", "num_segments" => nil, "num_media" => "0", "direction" => "outbound-api", "api_version" => "2010-04-01", "price" => nil, "price_unit" => "USD", "uri" => "/2010-04-01/Accounts/AC3e0af22b6b772460f352ba8c6586fbde/Messages/SM0025dc49bcc2476b8b25043df36bfdf4.json", "subresource_uris" => {"media" => "/2010-04-01/Accounts/AC3e0af22b6b772460f352ba8c6586fbde/Messages/SM0025dc49bcc2476b8b25043df36bfdf4/Media.json"}}
> parsed_response['status']
=> "queued"
```

The hash that's returned is really easy to work with in Ruby. You can see that
when we access the `'status'` key, that the message was queued, which for
Twilio, means that it was successful. (Twilio doesn't send out messages
immediately, but queues them and usually sends them out within a matter of
seconds.) In this case, we don't really need to do anything with what we got
back, but in other situations, you may use the response to initialize an
object. For example, we might have a `Message` class:

```ruby
class Message
  def initialize(attributes)
    @to = attributes['to']
    @from = attributes['from']
    @body = attributes['body']
    @status = attributes['status']
  end
end
```

And then, maybe we want to get all of the text messages we've ever sent:

```
> response = RestClient::Request.new(:method => :get, :url => 'https://api.twilio.com/2010-04-01/Accounts/AC3e0af22b6b772460f352ba8c6586fbde/Messages.json', :user => 'AC3e0af22b6b772460f352ba8c6586fbde', :password => 'e04f17e88eb7b8c81feb1b951dcd7a2f').execute
> parsed_response = JSON.parse(response)
> messages_data = parsed_response['messages']
> messages = messages_data.map {|data| Message.new(data)}
```

Now we've got all of the message information stored in objects, where they're
nice and easy to work with.

Let's make a Rails app where users can send texts to their friends. We'll
create a new Rails app, add the `'rest_client'` gem to the `Gemfile` and then
create a `Message` model:

`app/models/message.rb`

```ruby
class Message < ActiveRecord::Base
  before_create :send_message

private
  def send_message
    response = RestClient::Request.new(:method => :post, :url => 'https://api.twilio.com/2010-04-01/Accounts/AC3e0af22b6b772460f352ba8c6586fbde/Messages.json', :user => 'AC3e0af22b6b772460f352ba8c6586fbde', :password => 'e04f17e88eb7b8c81feb1b951dcd7a2f', :payload => {:Body => body, :To => to, :From => from}).execute
  end
end
```

Now, we can make `new`, `create`, `show`, and `index` views and controller
actions for messages. When a message is created, a text gets sent. Pretty sweet!

There are two huge flaws with our implementation, though. First, we have no
tests! Second, we're storing our Account Sid and Auth Token in our code, which
is not secure - for an open source project, you're leaving your credentials in
plain sight to the world, and even in a closed-source project, it's very easy
for contractors or disgruntled employees to walk off with access to services
they shouldn't.

Let's tackle the second problem first. Generally, the best practice is to store
sensitive information in **environmental variables**. Here's how to use
environmental variables in our example app:

`app/models/message.rb`

```ruby
class Message < ActiveRecord::Base
  before_create :send_message

private
  def send_message
    response = RestClient::Request.new(:method => :post, :url => "https://api.twilio.com/2010-04-01/Accounts/#{ENV['TWILIO_ACCOUNT_SID']}/Messages.json", :user => ENV['TWILIO_ACCOUNT_SID'], :password => ENV['TWILIO_AUTH_TOKEN'], :payload => {:Body=> body, :To=> to, :From=> from}).execute
  end
end
```

Now, we need to set the variables somewhere outside of our application. One way
to do this is to store them in a `.env` file in your project directory:

`.env`

```
TWILIO_ACCOUNT_SID=AC3e0af22b6b772460f352ba8c6586fbde
TWILIO_AUTH_TOKEN=e04f17e88eb7b8c81feb1b951dcd7a2f
```

We need to make sure that Git doesn't track our `.env` file, by simply adding
`.env` to the end of the `.gitignore` file.

Now, we need a way to load the variables from our .env file. There's a nice gem
for that called [dotenv](https://github.com/bkeepers/dotenv):

`Gemfile`

```
group :development, :test do
  gem 'dotenv-rails'
  gem 'rspec-rails'
end
```

Now our app is secure. But how do we test it?

Let's start out on a new feature and test-drive it. Here's the spec:

`spec/models/message_spec.rb`

```ruby
require 'rails_helper'

describe Message do
  it "doesn't save the message if twilio gives an error" do
    message = Message.new(:body => 'hi', :to => '1111111', :from => '5039463641')
    message.save.should be false
  end
end
```

Now, here's my code to make it pass:

`app/models/message.rb`

```ruby
class Message < ActiveRecord::Base
  before_create :send_message

private
  def send_message
    begin
      response = RestClient::Request.new(:method => :post, :url => "https://api.twilio.com/2010-04-01/Accounts/#{ENV['TWILIO_ACCOUNT_SID']}/Messages.json", :user => ENV['TWILIO_ACCOUNT_SID'], :password => ENV['TWILIO_AUTH_TOKEN'], :payload => {:Body=> body, :To=> to, :From=> from}).execute
    rescue
      false
    end
  end
end
```

Returning `false` from a callback causes Active Record to stop saving it.

This is fine, but our tests run awfully slow now. That's because every test
makes a call to Twilio, which takes far more time than running code locally on
our machine. What we want to do is to **stub** out all of our external web
requests, so that instead of actually making the request we can return sample
data for use in our testing. It used to be really annoying to write out stubs
for all of the HTTP calls our tests made, but now there's a gem called
[VCR](https://github.com/vcr/vcr) that simply records every request that's made
and what the response was, and then replays it back for subsequent tests.

To use VCR, add `vcr` and `webmock` to your `Gemfile`'s `test` group, and then
add these lines your `rails_helper`:

`spec/rails_helper.rb`

```ruby
VCR.configure do |c|
  c.cassette_library_dir ='spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
end
```

Now, whenever you have a spec that will make HTTP calls, simply tell it to use
VCR like this:

`spec/models/message_spec.rb`

```ruby
describe Message, :vcr => true do...
```

The first time we run a spec with VCR, it will be slow, because VCR still has
to make the request to record what happens. But subsequent test runs will be
much faster!

Let's work on another feature:

`spec/models/message_spec.rb`

```ruby
describe Message, :vcr => true do
  it 'adds an error if the to number is invalid' do
    message = Message.new(:body => 'hi', :to => '1111111', :from => '5039463641')
    message.save
    expect(message.errors.messages[:base]).to eq ["The 'To' number 1111111 is not a valid phone number."]
  end
end
```

Here's how we can make it pass:

`app/models/message.rb`

```ruby
class Message < ActiveRecord::Base
  before_create :send_message

private
  def send_message
    begin
      response = RestClient::Request.new(:method => :post, :url => "https://api.twilio.com/2010-04-01/Accounts/#{ENV['TWILIO_ACCOUNT_SID']}/Messages.json", :user => ENV['TWILIO_ACCOUNT_SID'], :password => ENV['TWILIO_AUTH_TOKEN'], :payload => {:Body=> body, :To=> to, :From=> from}).execute
    rescue RestClient::BadRequest => error
      message = JSON.parse(error.response)['message']
      errors.add(:base, message)false
    end
  end
end
```

It's not always straightforward what format the response will come in, what
classes different objects will be, and how to deal with all the different parts
in here. I'd suggest watching the video to see how I approach it, but basically
it boils down to a liberal dose of `binding.pry`.

There's one last problem we need to address. VCR records our requests and the
responses in `spec/cassettes`, which we'll be checking into Git. But our
Account Sid and Auth Token are in the requests and responses, and so will be
recorded by VCR by default. Here's how we tell VCR to replace them with the
text `<twilioaccountsid>` and `<twilioauthtoken>`:

`spec/rails_helper.rb`

```ruby
VCR.configure do |c|
  c.cassette_library_dir ='spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.filter_sensitive_data('<twilio account sid>'){ ENV['TWILIO_ACCOUNT_SID'] }
  c.filter_sensitive_data('<twilio auth token>'){ ENV['TWILIO_AUTH_TOKEN'] }
end
```

The block is the text to match and replace, the argument is the text to replace
it with.

Now, if we delete the `spec/cassettes` folder and run our specs again, VCR will
scrub out our sensitive information.

## Building an API

[Video](http://player.vimeo.com/video/92897215)

**NOTE:** When you're trying out your API with RestClient, you might also take
the opportunity to [learn how to use cURL](http://blogs.plexibus.com/2009/01/15/rest-esting-with-curl/),
a very common command-line utility for making web requests.

So now you know how to use other sites' APIs; what about building your own?
Turns out it's pretty trivial. Let's build an API for Wikipages. Here's how our
controller looked, pre-API:

`app/controllers/contacts_controller.rb`

```ruby
class ContactsController < ApplicationController
  def index
    @contacts=Contact.all
  end

  def new
  @contact=Contact.new
  end

  def create
    @contact=Contact.new(contact_params)
    if @contact.save
      flash[:notice]="Contact created."
      redirect_to contacts_path
    else
      render 'new'
    end
  end

  def show
    @contact=Contact.find(params[:id])
  end

  def edit
    @contact=Contact.find(params[:id])
  end

  def update
    @contact=Contact.find(params[:id])
    if @contact.update(contact_params)
      flash[:notice]="Contact updated."
      redirect_to contact_path(@contact)
    else
      render 'edit'
    end
  end

  def destroy
    @contact = Contact.find(params[:id])
    @contact.destroy
    flash[:notice]="Contact deleted."
    redirect_to contacts_path
  end

private

  def contact_params
    params.require(:contact).permit(:name,:email,:phone)
  end
end
```

Let's start out our API by allowing our users to get a JSON representation of a
single contact. Here's all we need to do to update our `show` action:

`app/controllers/contacts_controller.rb`

```ruby
class ContactsController < ApplicationController
  def show
    @contact=Contact.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render :json => @contact}
    end
  end
end
```

When we make a request from the browser, it will by default behave the same as
before, implicitly rendering `show.html.erb`. When we make a request that
specifies the JSON format, either through a header or by adding the `.json`
extension to the URL, it will render back a JSON representation of the object.
(Internally, this calls the `.to_json` method on the object - check it out in
the Rails console to see for yourself! Thanks, Active Record.)

We can check this out in the browser by visiting
`http://localhost:3000/contacts/1.json`:

```json
{"id": 1, "name": "Jill", "phone": "5035551212", "email": "jill@example.com"}
```

The `index` action is similarly trivial:

```ruby
class ContactsController < ApplicationController
  def index
    @contacts=Contact.all

    respond_to do |format|
      format.html
      format.json { render :json => @contacts }
    end
  end
end
```

There's no need to make JSON version of our `new` and `edit` actions, because
an API needs to be pre-programmed as to what it should be submitting to the
server.

Let's move on to another HTTP method: DELETE. Here's the updated `destroy`
action:

```ruby
class ContactsController < ApplicationController
  def destroy
    @contact=Contact.find(params[:id])
    @contact.destroy

    respond_to do |format|
      format.html do
        flash[:notice]="Contact deleted."
        redirect_to contacts_path
      end
      format.json { head :no_content }
    end
  end
end
```

`head :no_content` means to return the `200 OK` status with nothing in the
response body.

We can't test this in the browser, but we can make a request using Rest Client
to check it out:

```
> RestClient.delete('http://localhost:3000/contacts/3.json')
=> RestClient::UnprocessableEntity :422UnprocessableEntity
```

Uh-oh, what went wrong here? In our server logs, we can see that it says
**"Can't verify CSRF token authenticity."** CSRF is only useful for web
browsers that have cookies, but when we have an API, we use API keys, not
cookies. Rails's suggested way to handle this is to switch from raising an
exception if there's no CSRF, to instead clearing any set cookies if there's no
CSRF. Since APIs don't have cookies to begin with, this has no effect on them,
but still protects users from CSRF, since any malicious requests that don't
include the CSRF token will simply result in logging the user out of the site.

Here's how to make that change:

`app/controllers/application_controller.rb`

```ruby
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
end
```

Let's try our DELETE request again:

```
> RestClient.delete('http://localhost:3000/contacts/3.json')
=>""
```

Got it! Now let's work on `create`:

`app/controllers/contacts_controller.rb`

```ruby
class ContactsController < ApplicationController
  def create
    if @contact.save
      respond_to do |format|
        format.html do
          flash[:notice] = "Contact created."
          redirect_to contacts_path
        end
        format.json { render :json => @contact,:status => 201 }
      end
    else
      respond_to do |format|
        format.html { render 'new'}
        format.json { render :json => @contact.errors, :status => 422 }
      end
    end
  end
end
```

Here, if the record is saved successfully, we render back a JSON representation
of it, and return the `201 Created` status:

```
> response = RestClient.post('http://localhost:3000/contacts.json', :contact => {:name => 'sasha fierce'})
=> "{\"id\":16,\"name\":\"sasha fierce\",\"phone\":null,\"email\":null}"
```

If it's not saved successfully, we render a JSON representation of the errors,
and return the `422 Unprocessable Entity` HTTP status code. Rest Client will
throw an exception when returned a `4xx` response, so we'll catch it and return
the error message:

```
>begin
  response = RestClient.post('http://localhost:3000/contacts.json', :contact => {:name => ''})
rescue RestClient::UnprocessableEntity => error
  error.response
end
=> "{\"name\":[\"can't be blank\"]}"
```

Finally, the `update` action looks pretty similar:

```ruby
class ContactsController < ApplicationController
  def update
    @contact = Contact.find(params[:id])
    if @contact.update(contact_params)
      respond_to do |format|
        format.html do
          flash[:notice] = "Contact updated."
          redirect_to contact_path (@contact)
        end
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { render 'edit'}
        format.json { render :json => @contact.errors, :status => 422}
      end
    end
  end
end
```

And that's 90% of what you need to know to make a RESTful JSON API!

One other important thing is choosing which attributes from your model get
added to your JSON responses, in case there are certain things you don't want
exposed to the outside world. [Watch the Railscast on ActiveModel Serializers](http://railscasts.com/episodes/409-active-model-serializers)
to see how to do that.

And of course, you'll want to secure your API; there are a lot of different
approaches to this, and [the Railscast on securing an
API](http://railscasts.com/episodes/352-securing-an-api)
will introduce you to a fairly straightforward, basic approach.
