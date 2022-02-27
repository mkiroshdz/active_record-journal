module ActiveRecord
  module Journal
    class Configuration
      attr_writer :journal_class_name, :journable_class_names

      DEFAULT_JOURNAL = 'Journal'
      DEFAULT_JOURNABLES = ['ActiveRecord::Base']

      def journal
        class_name = @journal_class_name || DEFAULT_JOURNAL
        class_name.constantize
      end

      def journables
        class_names = @journable_class_names || DEFAULT_JOURNABLES
        class_names.map(&:constantize)
      end
    end
  end
end
