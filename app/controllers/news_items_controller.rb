class NewsItemsController < ApplicationController
  # before_action :require_user
  before_action :find_news_item_resource_object, only: [:create]

  def index
    if current_user
      @news_items = NewsItem.all
    else
      redirect_to home_path
    end
  end

  def new
    @news_item = NewsItem.new
  end

  def create
    @news_item = NewsItem.new(news_item_params)
    respond_to do |format|
      if @news_item.save
        format.html { redirect_to :index }
      else
        format.html { render :new }
      end
    end
  end

  private
  def find_news_item_resource_object
    @klass = params[:news_item_resource_type].classify.constantize
    @news_item_resource_object = klass.find(params[:news_item_resource_id])
  end

  def news_item_params
    params.require(:news_item).permit(:league_id, :news_item_resource_type, :news_item_resource_id)
  end
end
