class QuestioningsController < ApplicationController
  def new
    @qing = Questioning.new_with_question(:form_id => params[:form_id])
    render_and_setup("create")
  end
  
  def edit
    @qing = Questioning.find(params[:id])
    render_and_setup("update")
  end
  
  def show
    @qing = Questioning.find(params[:id])
    @title = "Question: #{@qing.question.code}"
  end
  
  def destroy
    @qing = Questioning.find(params[:id])
    @form = @qing.form
    begin
      @form.destroy_questionings([@qing])
      flash[:success] = "Question removed successfully." 
    rescue 
      flash[:error] = $!.to_s 
    end
    redirect_to(edit_form_path(@form))
  end
  
  def create; crupdate; end
  
  def update; crupdate; end
  
  private
    def crupdate
      action = params[:action]
      # find or create the questioning
      @qing = action == "create" ? Questioning.new_with_question : Questioning.find(params[:id])
      @qing.question.attributes = params[:questioning].delete(:question)
      # try to save
      begin
        @qing.update_attributes!(params[:questioning])
        flash[:success] = "Question #{action}d successfully."
        redirect_to(edit_form_path(@qing.form))
      rescue ActiveRecord::RecordInvalid
        render_and_setup(action)
      end
    end
    
    def render_and_setup(action)
      @title = action == "create" ? "Create Question" : "Edit Question: #{@qing.question.code}"
      @js << 'questions'
      render(:action => action == "create" ? :new : :edit)
    end
end