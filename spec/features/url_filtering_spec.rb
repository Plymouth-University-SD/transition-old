require 'features/features_helper'

feature 'Filter urls for a site' do
  before :each do
    host = create :natural_england_host
    @site1 = host.site
    @site2 = create :site
    @content_type1 = create :content_type, type: 'Bling', subtype: nil, scrapable: false
    @content_type2 = create :content_type, type: 'Publication', subtype: nil
    @url1 = create :url, url: 'http://www.naturalengland.org.uk/site', site: @site1, 
      content_type: @content_type1, state: 'finished', for_scraping: true
    @url2 = create :url, url: 'http://www.naturalengland.org.uk/about_us/default.aspx', site: @site1, 
      content_type: @content_type2, for_scraping: false
    @url3 = create :url, url: 'http://www.naturalengland.org.uk/contact_us', site: @site1, 
      content_type: @content_type1, state: 'submitted', for_scraping: true
    @url4 = create :url, url: 'http://www.dfid.org.uk/please_contact_us', site: @site2
    @url5 = create :url, url: 'http://www.naturalengland.org.uk/help', site: @site1, 
      content_type: @content_type1, for_scraping: true

    login_as_stub_user
  end

  scenario 'View all urls for a site and filter them by content type and state', js: true do
    debugger
    visit site_urls_path(@site1)
debugger
    page.should have_url_list_in_this_order ['/site', '/about_us/default.aspx', '/contact_us', '/help']
   debugger
    select 'Bling', from: 'filter_by_content_type'
debugger
    page.should have_url_list_in_this_order ['/site', '/contact_us', '/help']
debugger
    # check that filter is preserved on links and form submission
    page.should have_link(@url3.url, href: site_url_path(@site1, @url3, content_type: @content_type1.id))
    click_link @url3.url
    page.should_not have_link(@url3.url)
    debugger
    save_and_open_page
    page.should have_url_list_in_this_order ['/site', '/contact_us', '/help']
    

    click_button 'Save for review later'

    # we should have moved on to the next url and when selected, a url is not linked
    page.should_not have_link(@url5.url)
    page.should have_url_list_in_this_order ['/site', '/contact_us', '/help']

    # filter by both content type and state
    select 'not started', from: 'filter_by_state'
    
    page.should have_url_list_in_this_order ['/help']
    select 'submitted', from: 'filter_by_state'
    page.should have_url_list_in_this_order ['/contact_us']
    select 'migrated', from: 'filter_by_state'
    page.should have_url_list_in_this_order ['/site']
  end

  scenario 'Filter urls by scrape status and url, and then reset filters', js: true do
    (1..3).each do |i| 
      instance_variable_set("@url_site#{i}", create(:url, url: "http://www.naturalengland.org.uk/site#{i}", 
        site: @site1, for_scraping: true, content_type: @content_type1))
    end
    visit site_urls_path(@site1)

    select 'Not for scrape', from: 'filter_by_scrape_status'

    page.should have_url_list_in_this_order ['/about_us/default.aspx']

    select 'For scrape', from: 'filter_by_scrape_status'
    page.should have_url_list_in_this_order ['/site', '/contact_us', '/help', '/site1', '/site2', '/site3']

    fill_in 'q', with: 'site'
    click_button 'Find'

    page.should have_url_list_in_this_order ['/site', '/site1', '/site2', '/site3']

    # check that filter is preserved on links and form submission
    page.should have_link(@url_site1.url, href: site_url_path(@site1, @url_site1, for_scrape: 'true', q: 'site'))
    click_link @url_site1.url
    page.should_not have_link(@url_site1.url) # used for waiting until page loads
    page.should have_url_list_in_this_order ['/site', '/site1', '/site2', '/site3']

    click_button 'Save for review later'

    # we should have moved on to the next url and when selected, a url is not linked
    page.should_not have_link(@url_site2.url) # used for waiting until page loads
    # /site1 no longer appears since the for_scraping attribute is set to null
    # when the Scrape radio buttons are not displayed and the form is submitted
    page.should have_url_list_in_this_order ['/site', '/site2', '/site3']

    click_button 'Reset'

    page.should have_url_list_in_this_order(
      ['/site', '/about_us/default.aspx', '/contact_us', '/help', '/site1', '/site2', '/site3'])
  end

  scenario 'Filter urls so that no url meets the filter criteria', js: true do
    visit site_urls_path(@site1)

    select 'Not for scrape', from: 'filter_by_scrape_status'
    select 'Bling', from: 'filter_by_content_type'

    page.should have_content 'No Urls were found'
    page.should have_url_list_in_this_order []
  end
end
