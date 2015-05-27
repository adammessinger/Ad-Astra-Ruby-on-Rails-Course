class ContactsController < ApplicationController
  def index
    # get data from model
    @contacts = Contact.all
    # render view
    # NOTE: We could leave next line out. By convention, Rails will automatically
    # look for a view at [class name]/[method name].html.erb
    render 'contacts/index.html.erb'
  end

  def show
    # NOTE: params gives you access to query parameters
    @contact = Contact.find(params[:id])
  end

  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(name: params[:name],
                           email: params[:email],
                           phone: params[:phone])

    # NOTE: Jarret says that redirecting to the just-created record would be
    # more RESTful
    # NOTE: Calling render doesn't leave this method, so all vars available to
    # this method are available to the rendered view.
    if @contact.save
      render 'contacts/success.html.erb'
    else
      render 'contacts/new.html.erb'
    end
  end
end
