module UrlsHelper
  ##
  # Create a link classed to URL state, or text if current
  def classy_link(url, current_url)
    link_to_if(
        url != current_url,
        url.url,
        site_url_path(current_url.site, url),
        { title: url.url, class: url.state }
    )
  end

  def entry_for_content_type(content_type)
    [
      content_type.subtype.presence || content_type.type,
      content_type.id,
      {
        'data-user_need_required' => content_type.user_need_required,
        'data-scrapable'          => content_type.scrapable,
        'data-mandatory_guidance' => content_type.mandatory_guidance
      }
    ]
  end

  def options_for_url_state_select(state)
    
    options = UrlsController::URL_FILTER_QUERY_TO_STATE.to_a
    options_for_select(options, state)
  end

  def options_for_scrape_select(for_scrape)
    options = [['For scrape', 'true'], ['Not for scrape', 'false']]
    options_for_select(options, for_scrape)
  end

  def grouped_options_for_content_type_select(url_or_content_type_id)
    content_type_id = url_or_content_type_id.is_a?(Url) ? url_or_content_type_id.content_type_id : url_or_content_type_id
    ContentType.order(:position).group_by(&:type).map do |type, content_types|
      if content_types.one? && (content_type = content_types.first).subtype.blank?
        options_for_select([entry_for_content_type(content_type)], content_type_id)
      else
        grouped_options_for_select({ type => content_types.map { |content_type| entry_for_content_type(content_type) } }, content_type_id)
      end
    end.join.html_safe
  end

  def guidance_select(url)
    url_group_select(url, UrlGroupType::GUIDANCE, url.guidance_id)
  end

  def series_select(url)
    url_group_select(url, UrlGroupType::SERIES, url.series_id)
  end

  def url_group_select(url, url_group_type, selected)
    url_group_type = UrlGroupType.find_by_name(url_group_type)
    options = if url_group_type
      url_group_type.url_groups.for_organisation(url.site.organisation).map {|url_group| [url_group.name, url_group.id]}
    else
      []
    end
    options_for_select(options, selected)
  end

  # optgroup and options for user needs where needs are grouped by the given url's organisation and then all other organisations' user needs
  def grouped_options_for_user_needs_group_select(url)
    options = {}
    options[url.site.organisation.title] = url.site.organisation.user_needs.map {|user_need| [user_need.name, user_need.id]}
    options['Other'] = UserNeed.where('organisation_id <> ? or organisation_id is null', url.site.organisation.id).map {|user_need| [user_need.name, user_need.id]}
    grouped_options_for_select(options, url.user_need_id)
  end

  def url_filter_hash
    filter_hash = {content_type: params[:content_type], state: params[:state], for_scrape: params[:for_scrape], q: params[:q], last_saved_url: params[:last_saved_url]}
    filter_hash.delete_if { |k, v| v.blank? }
    filter_hash
  end
end
