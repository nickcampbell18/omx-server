module Omx
  class Search

    def reindex!
      # TODO This command must be run as root
      `updatedb -U '/media/zeus'`
    end

    def run(query='')
      locate glob tokenize query
    end

    private

      def locate(string)
        # return ['/some/filename.mp4']
        `locate #{string}`.split /\n/
      end

      def tokenize(str)
        str.split.map {|t| t.tr '^A-Za-z0-9.\\-', ''}
      end

      def glob(arr)
        '*' << arr.join('*') << '*'
      end

  end
end