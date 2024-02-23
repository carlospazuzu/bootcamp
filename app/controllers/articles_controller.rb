# frozen_string_literal: true

class ArticlesController < ApplicationController
  before_action :set_article, only: %i[show edit update destroy]
  skip_before_action :require_active_user_login, raise: false, only: %i[index show]
  before_action :require_admin_or_mentor_login, except: %i[index show]

  def index
    @articles = list_articles
    @articles = @articles.tagged_with(params[:tag]) if params[:tag]
    render layout: 'welcome'
  end

  def show
    if @article.published? || admin_or_mentor_login?
      render layout: 'welcome'
    else
      redirect_to root_path, alert: '管理者・メンターとしてログインしてください'
    end
  end

  def new
    @article = Article.new
  end

  def edit; end

  def create
    @article = Article.new(article_params)
    @article.user = current_user if @article.user.nil?
    set_wip
    if @article.save
      redirect_to redirect_url(@article), notice: notice_message(@article)
    else
      render :new
    end
  end

  def update
    set_wip
    if @article.update(article_params)
      redirect_to redirect_url(@article), notice: notice_message(@article)
    else
      render :edit
    end
  end

  def destroy
    @article.destroy
    redirect_to articles_url, notice: '記事を削除しました'
  end

  private

  def set_article
    @article = Article.find(params[:id])
  end

  def list_articles
    articles = Article.with_attached_thumbnail.includes(user: { avatar_attachment: :blob }).order(created_at: :desc).page(params[:page])
    admin_or_mentor_login? ? articles : articles.where(wip: false)
  end

  def article_params
    article_attributes = %i[
      title
      body
      tag_list
      user_id
      thumbnail
      thumbnail_type
      summary
      display_thumbnail_in_body
    ]
    article_attributes.push(:published_at) unless params[:commit] == 'WIP'
    params.require(:article).permit(*article_attributes)
  end

  def redirect_url(article)
    article.wip? ? edit_article_url(article) : article
  end

  def set_wip
    @article.wip = params[:commit] == 'WIP'
  end

  def notice_message(article)
    case params[:action]
    when 'create'
      article.wip? ? '記事をWIPとして保存しました' : '記事を作成しました'
    when 'update'
      article.wip? ? '記事をWIPとして保存しました' : '記事を更新しました'
    end
  end
end
