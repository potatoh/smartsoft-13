#encoding: UTF-8
class AdminController < ApplicationController
  protect_from_forgery
  require 'csv'

  layout 'admin'

  include AdminHelper

  before_filter :require_login
  skip_before_filter :require_login, only: [:login, :logout]

  before_filter :check_login, only: [:login]

  # author:
  #     Karim ElNaggar
  # description:
  #     a filter that makes sure the user is logged in
  # params
  #     none
  # success: 
  #     if the user is not logged in redirect to login
  # failure: 
  #     none
  def require_login
    unless logged_in?
      flash[:error] = "يجب تسجيل الدخول"
      redirect_to action: "login"
    end
  end

  # author:
  #     Karim ElNaggar
  # description:
  #     a function that checks if the user is logged in and 
  #     redirects him to /admin/index
  # params
  #     none
  # success: 
  #     redirect to index if the user is logged in
  # failure: 
  #     none
  def check_login
    if logged_in?
      redirect_to action: "index"
    end
  end

  def index
    @message = params[:message]
    @fargs = params[:fargs]
    @trophies_list = Trophy.all
    @prizes_list = Prize.all
  end

  # author:
  #     Karim ElNaggar
  # description:
  #     login action for admin
  # params
  #     username: the username for the admin
  #     password: the password for the admin
  # success: 
  #     redirects to admin/index
  # failure: 
  #     refreshes the page with error displayed
  def login
    if request.post?
      if params[:username] == "admin" && params[:password] == "admin"
        create_session
        redirect_to action: "index"
      else
        flash[:error] = "اسم المستخدم او كلمة السر غير صحيحة"
        @username = params[:username]
      end
    end
  end
  
  # author:
  #     Karim ElNaggar
  # description:
  #     wordadd action for keywords by admin
  # params
  #     name: the name of the new keyword
  # success: 
  #     refreshes the page and displays notification
  # failure: 
  #     refreshes the page with error displayed
  def add_word
    name = params[:keyword][:name]
    is_english = params[:keyword][:is_english]
    success, @keyword = Keyword.add_keyword_to_database(name, true, is_english)
    if success
      flash[:success] = "لقد تم ادخال كلمة #{@keyword.name} بنجاح"
      flash[:successtype] = "addword"
      flash.keep
      redirect_to action: "index", anchor: "admin-add-word"
    else
      flash[:error] = @keyword.errors.messages
      flash[:errortype] = "addword"
      flash.keep
      redirect_to action: "index", anchor: "admin-add-word", fargs: params
    end
  end

  # author:
  #     Karim ElNaggar
  # description:
  #     this action takes a trophy as input and creates one and stores it in
  #     the database and redirects the user to index
  # params
  #     name: name of the trophy
  #     level: the level required to earn the trophy
  #     score: the score required to earn the trophy
  #     image: the photo thumbnail which would be displayed
  # success: 
  #     refreshes the page and displays notification
  # failure: 
  #     refreshes the page with error displayed
  def add_trophy
    params[:name] = params[:name].strip
    params[:level] = params[:level].strip
    params[:score] = params[:score].strip
    success, trophy = Trophy.add_trophy_to_database(params[:name],
                 params[:level], params[:score], params[:image])
    if success
      flash[:success] = "تم ادخال الانجاز #{trophy.name} بنجاح"
      flash[:successtype] = "addtrophy"
    else
      flash[:error] = trophy.errors.messages
      flash[:errortype] = "addtrophy"
    end
    flash.keep
    if success
      redirect_to action: "index", anchor: "admin-list-trophies"
    else
      redirect_to action: "index", anchor: "admin-add-trophy", 
                  fargs: {addtrophy: params}
    end
  end

  # author:
  #     Karim ElNaggar
  # description:
  #     this action takes a prize as input and creates one and stores it in
  #     the database and redirects the user to index
  # params
  #     name: name of the prize
  #     level: the level required to earn the prize
  #     score: the score required to earn the prize
  #     image: the photo thumbnail which would be displayed
  # success: 
  #     refreshes the page and displays notification
  # failure: 
  #     refreshes the page with error displayed
  def add_prize
    params[:name] = params[:name].strip
    params[:level] = params[:level].strip
    params[:score] = params[:score].strip
    success, prize = Prize.add_prize_to_database(params[:name],
               params[:level], params[:score], params[:image])
    if success
      flash[:success] = "تم ادخال جائزة #{prize.name} بنجاح"
      flash[:successtype] = "addprize"
    else
      flash[:error] = prize.errors.messages
      flash[:errortype] = "addprize"
    end
    flash.keep
    if success
      redirect_to action: "index", anchor: "admin-list-prizes"
    else
      redirect_to action: "index", anchor: "admin-add-prize", 
                  fargs: {addprize: params}
    end
  end

  # author:
  #     Karim ElNaggar
  # description:
  #     delete a trophy selected by id
  # params
  #     id the id of the trophy
  # success: 
  #     refreshes the page and displays notification
  # failure: 
  #     refreshes the page with error displayed
  def delete_trophy
    params[:id] = params[:id].strip
    status_trophy = Trophy.find_by_id(params[:id])
    if status_trophy.present?
      name = status_trophy.name
      status_trophy.delete
      flash[:success] = "تم مسح مدالية #{name} بنجاح"
      flash[:successtype] = "deletetrophy"
    else
      flash[:error] = "Trophy number #{params[:id]} is not found"
    end
    flash.keep
    redirect_to action: "index", anchor: "admin-list-trophies"
  end

  # author:
  #     Karim ElNaggar
  # description:
  #     delete a prize selected by id
  # params
  #     id the id of the prize
  # success: 
  #     refreshes the page and displays notification
  # failure: 
  #     refreshes the page with error displayed
  def delete_prize
    params[:id] = params[:id].strip
    status_prize = Prize.find_by_id(params[:id])
    if status_prize.present?
      name = status_prize.name
      status_prize.delete
      flash[:success] = "تم مسح جائزة #{name} بنجاح"
      flash[:successtype] = "deleteprize"
    else
      flash[:error] = "Prize number #{params[:id]} is not found"
    end
    flash.keep
    redirect_to action: "index", anchor: "admin-list-prizes"
  end

  # author:
  #     Karim ElNaggar
  # description:
  #     admin logout action
  # params
  #     none
  # success: 
  #     redirects the user to /admin/login page
  # failure: 
  #     none
  def logout
    destroy_session
    redirect_to action: "login"
  end

  # author:
  #   Amr Abdelraouf
  # description:
  #   method calls parseCSV to return an array of arrays
  #   if the message is zero (file is valid and ready for insertion)
  #   uploadCSV is called and the words are inserted
  # params:
  #   POST csvfile
  # success:
  #   redirected to import_csv and status message is displayed
  # failure:
  #   none
  def upload
    array_of_arrays, message = parseCSV(params[:csvfile])
    if message == 0
      uploadCSV(array_of_arrays)
    end
    redirect_to action: "index", anchor: "admin-import-csv-file", 
                message: message
  end

  # Author:
  #   Omar Hossam
  # Description:
  #   As an admin, I should be able to view all the subscription models in
  #   database.
  # Parameters:
  #   None.
  # Success:
  #   Subscription models appear on the view in a table with all attributes.
  # Failure: 
  #   Nothing appears as there is no Subscription models in database.
  def view_subscription_models
    @models = SubscriptionModel.all
  end

  # Author:
  #   Omar Hossam
  # Description:
  #   As an admin, I should be able to view all the attributes of the
  #   subscription model needed to be edited, and the data they have.
  # Parameters:
  #   errors: list of error messages of subscription model trying to edit.
  #   model_id: id of subscription model to be edited.
  # Success:
  #   error messages appear on top of page, and attributes of subscription model
  #   to be edited appear on page, with their original data.
  # Failure: 
  #   None.
  def edit_subscription_model
    @errors = params[:errors]
    model_id = params[:model_id].to_i
    @model = SubscriptionModel.find_by_id(model_id)
  end

  # Author:
  #   Omar Hossam
  # Description:
  #   As an admin, I should be able edit data of a subscription model.
  # Parameters:
  #   model_id: id of subscription model to be edited.
  #   subscription_model[name]: new name that should replace original name
  #   subscription_model[limit_search]: new limit_search that should replace
  #   original limit_search.
  #   subscription_model[limit_follow]: new limit_follow that should replace
  #   original limit_follow.
  #   subscription_model[limit_project]: new limit_project that should replace
  #   original limit_project.
  # Success:
  #   Subscription model attributes gets updated with new data and go back to
  #   the view of all subscription models in database.
  # Failure: 
  #   Some of the Subscription model's validation prevents the model to be
  #   edited, and the errors appear on the top of the page.
  def update_subscription_model
    @model = SubscriptionModel.find(params[:model_id])
    @model.name = params[:subscription_model][:name]
    @model.limit_search = params[:subscription_model][:limit_search]
    @model.limit_follow = params[:subscription_model][:limit_follow]
    @model.limit_project = params[:subscription_model][:limit_project]
    if @model.save
      redirect_to action: "subscription_model"
    else
      redirect_to action: "edit_subscription_model",
        errors: @model.errors.messages, model_id: @model.id
    end
  end

end