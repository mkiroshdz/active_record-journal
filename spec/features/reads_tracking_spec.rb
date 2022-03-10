# frozen_string_literal: true

RSpec.describe 'reads tracking' do
  let(:user) { Fixtures::User.create!(username: 'jane-doe') }
  let(:context) { klass.journable_context }
  let(:klass) { Fixtures::GuestAuthor }
  let(:journal_records) { configuration.entries_class }
  let(:configuration) { ActiveRecord::Journal.configuration }

  context 'when write actions triggered' do
    let(:record) { klass.create!(name: 'Jane') }
    let(:journal_records) { record.journal_records }

    before do
      record.update!(last_name: 'Emily')
      record.destroy!
    end

    it 'does not track actions' do
      expect(journal_records.count).to eq 0
    end
  end

  context 'when read actions triggered' do
    let(:records) do
      [
        klass.create!(name: 'Jane', last_name: 'Doe'),
        klass.create!(name: 'Jonh', last_name: 'Doe')
      ]
    end

    let(:journal_records) { super().where(action: :read) }

    before do
      ActiveRecord::Journal.ignore do |c|
        c.actions do
          records.each(&:reload)
          records.each { |r| klass.find(r.id) }
        end
      end
      records.each { |r| klass.find(r.id) }
    end

    it 'records actions' do
      expect(journal_records.count).to eq 2
    end
  end

  context 'when autorecording disabled', autorecording_enabled: false do
    let(:record) { klass.create!(name: 'Jane', last_name: 'Doe') }
    let(:journal_records) { super().where(action: :read) }
    let(:tag) { JournalTag.first }

    before do
      2.times { record.reload }
      ActiveRecord::Journal.tag(user: user, description: 'test') do |context|
        context.actions { record.reload }
      end
    end

    it 'records actions' do
      expect(journal_records.count).to eq 1
    end

    it 'creates tag with context data' do
      expect(tag.user).to eq user
    end

    it 'associates tag to actions' do
      count = journal_records.where(journal_tag_id: tag.id).count
      expect(count).to be 1
    end
  end

  context 'when tracked with one time condition' do
    let(:author) { klass.create!(last_name: 'Austin') }

    before do
      ActiveRecord::Journal.tag(user: user, description: 'test') do |context|
        context.record(klass, :reads, if: ->(r) { r.last_name == 'Doe' })
        context.actions do
          2.times { author.reload }
        end
      end
      author.reload
    end

    it 'records journal' do
      expect(journal_records.where(action: :read, journable: author).count).to eq 1
    end
  end
end
