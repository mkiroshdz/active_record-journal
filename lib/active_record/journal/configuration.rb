# frozen_string_literal: true

module ActiveRecord
  module Journal
    class Configuration
      attr_writer :entries_class, :tags_class, :autorecording_enabled

      def entries_class
        return @entries_class if @entries_class.is_a?(Class)

        @entries_class = @entries_class.constantize
      end

      def tags_class
        return @tags_class if @tags_class.is_a?(Class)

        @tags_class = @tags_class.constantize
      end

      def autorecording_enabled
        return true if @autorecording_enabled.nil?

        @autorecording_enabled
      end
    end
  end
end
