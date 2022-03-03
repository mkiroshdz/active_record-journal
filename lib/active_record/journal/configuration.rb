module ActiveRecord
  module Journal
    class Configuration
      attr_writer :journal_class_name, :allowed_on, :autorecording_enabled

      DEFAULT_JOURNAL = 'JournalRecord'
      DEFAULT_ALLOWED_ON = %w[reads writes].freeze

      def journal
        class_name = @journal_class_name.presence || DEFAULT_JOURNAL
        class_name.constantize
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
