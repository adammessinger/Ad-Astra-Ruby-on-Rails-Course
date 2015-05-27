class ContactsController < ApplicationController
  def index
    # get data from model
    @contacts = Contact.all
    # render view
    # NOTE: We could leave next line out. By convention, Rails will automatically
    # look for a view at [class name]/[method name].html.erb
    render('contacts/index.html.erb')
  end

  def show
    @contact = Contact.find(params[:id])
  end
end
