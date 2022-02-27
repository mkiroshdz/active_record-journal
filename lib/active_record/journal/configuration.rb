module ActiveRecord
  module Journal
    class Configuration
      attr_writer :journal_class_name, :journable_class_names, :allowed_on

      DEFAULT_JOURNAL = 'Journal'
      DEFAULT_JOURNABLES = ['ActiveRecord::Base']
      DEFAULT_ACTIONS = %w[reads writes].freeze

      def journal
        class_name = @journal_class_name || DEFAULT_JOURNAL
        class_name.constantize
      end

      def journables
        class_names = @journable_class_names || DEFAULT_JOURNABLES
        class_names.map(&:constantize)
      end

      def allowed_on
        @allowed_on&.map(&:to_s) || DEFAULT_ACTIONS
      end
    end
  end
end
