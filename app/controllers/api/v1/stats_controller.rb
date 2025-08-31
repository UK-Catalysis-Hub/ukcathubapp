module Api
  module V1
    class StatsController < ApplicationController
      # open API; JSON by default from your existing ApplicationController tweak

      def summary
        render json: {
          data: {
            totals: {
              articles:       Article.count,
              institutions:   Organisation.count, # "institutions" == Organisations
              authors:        Author.count,
              data_objects:   Dataset.count
            },
            # optional: handy for caching / display
            last_updated: {
              articles:     Article.maximum(:updated_at),
              organisations: Organisation.maximum(:updated_at),
              authors:      Author.maximum(:updated_at),
              datasets:     Dataset.maximum(:updated_at)
            }
          }
        }
      end
    end
  end
end
