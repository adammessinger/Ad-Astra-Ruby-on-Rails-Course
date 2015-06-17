class ContactsController < ApplicationController
  def index
    @contacts = Contact.all
  end

  def show
    # NOTE: params gives you access to query parameters
    @contact = Contact.find(params[:id])
  end

  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(params[:contact])

    # NOTE: Jarret says that redirecting to the just-created record would be
    # more RESTful
    # NOTE: Calling render doesn't leave this method, so all vars available to
    # this method are available to the rendered view.
    if @contact.save
      flash[:notice] = 'Huzzah! Contact created.'
      redirect_to @contact
    else
      render 'new'
    end
  end

  def edit
    @contact = Contact.find(params[:id])
  end

  def update
    @contact = Contact.find(params[:id])

    if @contact.update(params[:contact])
      flash[:notice] = 'Boo yah! Contact created.'
      redirect_to @contact
    else
      render 'edit'
    end
  end

  def destroy
    @contact = Contact.find(params[:id])
    @contact.destroy
  end
end
