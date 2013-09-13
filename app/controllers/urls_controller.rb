class UrlsController < ApplicationController

  include UrlsHelper
  URL_FILTER_QUERY_TO_STATE = {'not started' => 'new', 'submitted' => 'submitted', 'sent back' => 'returned', 'approved' => 'approved', 'review' => 'unfinished', 'migrated' => 'finished', 'not required' => 'n-a'}

  before_filter :find_site

  def index
    @urls = url_filter(@site.urls)
    @url = @urls.first
    flash.now[:error] = 'No Urls were found' if @url.nil?
    render 'show'
  end

  def show
    @urls = url_filter(@site.urls)
    @url = @urls.find_by_id(params[:id])
    if @url.nil?
      @url = url_filter(@site.urls).first
      redirect_to site_url_path(@site, @url, url_filter_hash) and return if @url
    end
    @last_saved_url = @site.urls.find(params[:last_saved_url]) if params[:last_saved_url].present?
    flash.now[:error] = 'No Urls were found' if @url.nil?
  end

  def update
    destiny = params[:destiny].try(:to_sym)
    @url = @site.urls.find(params[:id])

    # update @url and any other urls that have been selected, with the same values
    selected_urls = [@url]
    selected_urls += @site.urls.find(params[:url_select].keys) if params[:url_select].present?
    Url.transaction do
      selected_urls.each do |url|
        url.state = destiny if destiny
        url.for_scraping = nil if params[:url] && params[:url][:for_scraping].nil?
      end
      if selected_urls.all? {|url| url.update_attributes(params[:url]) }
        redirect_to site_url_path(@url.site, @url.next(url_filter(@site.urls)), url_filter_hash.merge(last_saved_url: @url.id)) and return
      else
        @urls = url_filter(@site.urls)
        raise ActiveRecord::Rollback
      end
    end
    render 'show'
  end

  protected

  def url_filter(urls)
    urls = urls.where(content_type_id: params[:content_type]) if params[:content_type].present?
    urls = urls.where(state: params[:state]) if params[:state].present?
    urls = urls.where(for_scraping: params[:for_scrape] == 'true') if params[:for_scrape].present?
    urls = urls.where("url like ?", "%#{params[:q]}%") if params[:q].present?
    urls = urls.order(:id)
    urls
  end
end
