module ActiveRecord
  module Journal
    class Configuration
      attr_accessor :default_journal_class_name

      def default_journal
        class_name = default_journal_class_name || 'Journal'
        @default_journal = class_name.constantize
      end
    end
  end
end
