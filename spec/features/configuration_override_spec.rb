# frozen_string_literal: true

RSpec.describe 'configuration override' do
  let(:context) { klass.journable_context }
  let(:journal_records) { configuration.entries_class }
  let(:configuration) { ActiveRecord::Journal.configuration }
  let(:tag) { JournalTag.last }

  describe 'ignore action tracking' do
    let(:klass) { Fixtures::GuestAuthor }
    let(:record) { klass.create!(name: 'Jane', last_name: 'Doe') }
    let(:journal_records) { super().where(action: :read) }

    context 'when actions succeed' do
      before do
        record.reload
        ActiveRecord::Journal.ignore do |c|
          c.actions { record.reload }
        end
      end

      it 'record actions' do
        expect(tag).to be nil
        expect(journal_records.count).to eq 1
      end
    end

    context 'when actions raise error' do
      before do
        record.reload
        ActiveRecord::Journal.ignore do |c|
          c.actions do
            raise 'Something went wrong'
            record.reload
          end
        end
      end

      it 'record actions' do
        expect(tag).to be nil
        expect(journal_records.count).to eq 1
      end

      it 'clears context override' do
        expect(ActiveRecord::Journal.context_override).to be nil
      end
    end
  end

  describe 'actions tagging' do
    let(:klass) { Fixtures::OriginalAuthor }
    let(:record) { klass.create!(last_name: 'Doe') }

    context 'when actions succeed' do
      before do
        ActiveRecord::Journal.tag(description: 'test') do |c|
          c.actions do
            record.update!(name: 'Jane')
            record.destroy!
          end
        end
      end

      it 'record actions' do
        expect(journal_records.where(journal_tag_id: tag.id).count).to eq 3
      end
    end

    context 'when actions raise error' do
      before do
        ActiveRecord::Journal.tag(description: 'test') do |context|
          context.actions do
            record
            raise 'Something went wrong'
            record.update!(name: 'Erich')
            record.destroy!
          end
        end
      end

      it 'record actions' do
        expect(journal_records.where(journal_tag_id: tag.id).count).to eq 1
      end

      it 'clears context override' do
        expect(ActiveRecord::Journal.context_override).to be nil
      end
    end

    context 'when actions raise error in transaction' do
      before do
        ActiveRecord::Journal.tag(description: 'test') do |context|
          context.actions do
            klass.transaction do
              record
              raise 'Something went wrong'
              record.update!(name: 'Erich')
              record.destroy!
            end
          end
        end
      end

      it 'record actions' do
        expect(tag).to be nil
        expect(journal_records.count).to eq 0
      end

      it 'clears context override' do
        expect(ActiveRecord::Journal.context_override).to be nil
      end
    end
  end

  describe 'add one time conditions' do
    let(:klass) { Fixtures::OriginalAuthor }
    let(:record) { klass.create!(last_name: 'Smith') }

    context 'when actions succeed' do
      before do
        record
        ActiveRecord::Journal.context do |c|
          c.record(klass, :writes, if: ->(r) { r.last_name == 'Doe' })
          c.actions do
            record.update!(name: 'Jane')
            record.update!(name: 'Jhon')
            record.update!(last_name: 'Doe')
            record.destroy!
          end
        end
      end

      it 'record actions' do
        expect(tag).to be nil
        expect(journal_records.count).to eq 3
      end
    end

    context 'when actions raise error' do
      before do
        record
        ActiveRecord::Journal.context do |c|
          c.record(klass, :writes, if: ->(r) { r.last_name == 'Doe' })
          c.actions do
            record.update!(name: 'Jane')
            record.update!(name: 'Jhon')
            record.update!(last_name: 'Doe')
            raise 'Something went wrong'
            record.destroy!
          end
        end
      end

      it 'record actions' do
        expect(tag).to be nil
        expect(journal_records.count).to eq 2
      end

      it 'clears context override' do
        expect(ActiveRecord::Journal.context_override).to be nil
      end
    end
  end
end
