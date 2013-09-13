class Site < ActiveRecord::Base
#  attr_accessible :homepage, :query_params, :site, :tna_timestamp
  belongs_to :organisation
  has_many :hosts
  has_many :hits, through: :hosts
  has_many :totals, through: :hosts
  has_many :mappings
  has_many :urls, dependent: :restrict

  # grab the closest urls either side of the given url
  def adjacent_urls(url, count = 15)
    ordered_urls = urls.order('urls.id ASC')
    earlier_urls = ordered_urls.where('urls.id < ?', url.id).last(count - 1)
    later_urls = ordered_urls.where('urls.id > ?', url.id).first(count - 1)
    url_list = earlier_urls + [url] + later_urls

    url_position = url_list.find_index(url)
    start_slice = [url_position - (count / 2), 0].max
    end_slice = start_slice + count
    if end_slice > url_list.size
      start_slice = [url_list.size - count, 0].max
      end_slice = url_list.size + 1
    end
    url_list.slice(start_slice...end_slice)
  end

  def aggregated_hits
    hits.aggregated
  end

  def aggregated_totals
    totals.aggregated
  end

  def weekly_totals
    totals.aggregated_by_week_and_site
  end

  def default_host
    hosts.order(:id).first
  end

  # def to_param
  #   site
  # end
end
