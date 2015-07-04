class CommentsController < ApplicationController
  before_action :set_bug

  def index
    @comments = @bug.comments
  end

  # def show
  # end

  def new
    @comment = Comment.new(author_id: current_user.id, bug_id: @bug.id)
  end

  def edit
    @comment = @bug.comments.find(params[:id])
  end

  def create
    @comment = @bug.comments.create(comment_params)

    respond_to do |format|
      if @comment.save
        format.html { redirect_to @bug, notice: 'Comment was successfully created.' }
        format.json { render :show, status: :created, location: @comment }
      else
        format.html { render :new }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @comment = @bug.comments.find(params[:id])

    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @bug, notice: 'Comment was successfully updated.' }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @comment = @bug.comments.find(params[:id])

    @comment.destroy
    respond_to do |format|
      format.html { redirect_to @bug, notice: 'Comment was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bug
      @bug = Bug.find(params[:bug_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:author_id, :bug_id, :body)
    end
end
