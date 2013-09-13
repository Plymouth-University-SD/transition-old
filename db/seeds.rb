# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'yaml'
require 'htmlentities'

unless User.find_by_email("test@example.com")
  u = User.new
  u.email = "test@example.com"
  u.name = "Test User"
  u.permissions = ["signin"]
  u.save
end
#
#  load sites
#
# seeding requires a local checkout of the redirector project in the data directory
# git clone git@github.com:alphagov/redirector.git

#dirs = Dir.glob("data/redirector-new/data/sites/*.yml")
dirs = Dir.glob("data/redirector-new/data/sites/ukef.yml")

dirs.each do |file|
  s = YAML.load_file file

  abbr = s['site'].sub(/_.*$/, '')
  title = HTMLEntities.new.decode s['title']

  organisation = Organisation.find_or_initialize_by_abbr(abbr)
  organisation.update_attributes({
    title: title,
    launch_date: s['redirection_date'],
    homepage: s['homepage'],
    furl: s['furl'],
    css: s['css'] || nil
  })

  query_params = s['options'] ? s['options'].sub(/^.*--query-string /, '') : ""

  if s['global'] && (s['host'] != 'cdn.hm-treasury.gov.uk')
    # cdn.hm-treasury.gov.uk has a regex in the global value, which Bouncer
    # implements as a "rule", so we can ignore it.

    # There are two expected formats of the 'global' value:
    # global: =301 https://secure.fera.defra.gov.uk/nonnativespecies/beplantwise/
    #
    # or:
    # global: =410
    global_http_status = s['global'].split(' ')[0].gsub("=", "")
    global_new_url     = s['global'].split(' ')[1]
  else
    global_http_status = nil
    global_new_url     = nil
  end

  # site = Site.find_or_initialize_by_site(s['site'])
  site = Site.find_or_initialize_by_homepage(s['homepage'])
  site.organisation = organisation
  site.tna_timestamp = s['tna_timestamp']
  site.query_params = query_params
  site.global_http_status = global_http_status
  site.global_new_url = global_new_url
  site.homepage = s['homepage']
  site.save

  [s['host'], s['aliases']].flatten.each do |name|
    if name
      host = Host.find_or_initialize_by_host(name)
      host.site = site
      host.save
    end
  end
end

Transition::Import::ContentTypes.from_csv!('data/seeds/content_types.csv')
Transition::Import::ScrapableFields.seed!

# # seed url group types
Transition::UrlGroups.seed_group_types
