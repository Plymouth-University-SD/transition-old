require 'csv-mapper'

module Transition
  module Import
    class Urls
      def self.from_csv!(site_abbr, filename)
        site = Site.find_by_site!(site_abbr)
        logger, logfilename = new_logger(site)
        logger.info "Importing site urls for #{site.organisation.title} - #{site.site}"
        successes, failures = 0, 0
        CsvMapper.import(filename) do
          map_to Url
          named_columns

          url('Url')

          after_row lambda { |row, url|
            logger.warn('ignoring empty row') and return if row.empty?
            url.url = BLURI(url.url).canonicalize!(allow_query: :all).to_s
            url.site = site
            if (url.save rescue false)
              successes += 1
            else
              logger.error "#{url.errors.messages.inspect}: #{row.inspect}"
              failures += 1
            end
          }
        end

        logger.info "Urls - #{successes} successfully imported, #{failures} failed."
        logger.close
        logfilename
      end

      def self.new_logger(site)
        FileUtils.mkdir_p Rails.root.join('log', 'import_urls')
        logfilename = "#{site.site.gsub(' ', '_')}-#{Time.now.strftime('%Y%m%d-%H:%M:%S')}-#{rand(1...100).to_s}.log"
        logger = AuditLogger.new(Rails.root.join('log', 'import_urls', logfilename), 'Import urls')
        [logger, logfilename]
      end

      def self.from_hostpath_rows!(rows)
        cached_hosts = {}
        hits = rows.map do |hostname, path, _|
          host = cached_hosts[hostname] ||= Host.find_by_host(hostname)
          case host
          when nil then nil
          else Hit.new(host_id: host.id, path: path, path_hash: Digest::SHA1.hexdigest(path), http_status: 0, count: 0, hit_on: Hit::NEVER)
          end
        end.compact
        Hit.import hits
      end
    end
  end
end
