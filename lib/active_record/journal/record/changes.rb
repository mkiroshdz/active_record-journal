module ActiveRecord
  module Journal    
    module Record
      Changes = Struct.new(:subject, :action, :keys) do
        def call
          case action
          when 'create'
            non_persisted_diff
          when 'update'
            persisted_diff
          when 'destroy'
            destroy_diff
          else
            none
          end
        end

        def none
          {}
        end

        private

        def destroy_diff
          subject.attributes.select {|k, v| keys.include?(k) && v.present? }
        end

        def non_persisted_diff
          diff.select {|k, v| keys.include?(k) && v.last.present? }
        end

        def persisted_diff
          diff.select {|k, v| keys.include?(k) }
        end

        def diff
          subject.changes.any? ? subject.changes : subject.previous_changes
        end
      end
    end
  end
end