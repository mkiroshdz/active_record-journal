module ActiveRecord
  module Journal
    class Configuration
      attr_writer :journal_class_name, :journable_class_names, :allowed_on, :autorecording_enabled

      DEFAULT_JOURNAL = 'JournalRecord'
      DEFAULT_JOURNABLES = ['ActiveRecord::Base']
      DEFAULT_ALLOWED_ON = %w[reads writes].freeze

      def journal
        class_name = @journal_class_name.presence || DEFAULT_JOURNAL
        class_name.constantize
      end

      def journables
        class_names = @journable_class_names.presence || DEFAULT_JOURNABLES
        class_names.map(&:constantize)
      end

      def allowed_on
        @allowed_on&.map(&:to_s) || DEFAULT_ALLOWED_ON
      end

      def autorecording_enabled
        return true if @autorecording_enabled.nil?
        @autorecording_enabled
      end
    end
  end
end
