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
models, skinny controllers." Represented visually (by Dustin Brown):

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
