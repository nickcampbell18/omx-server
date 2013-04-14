module Omx
  module Stream
    class Youtube

      def self.url_from(web_url)
        `youtube-dl -g #{web_url}`
      end

    end
  end
end