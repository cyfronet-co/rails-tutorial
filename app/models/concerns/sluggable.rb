module Sluggable
    extend ActiveSupport::Concern

    included do
      before_create :slugify
    end

    private
      def slugify
        self.slug ||= name.to_s.parameterize
      end
end
