# frozen_string_literal: true

RSpec.describe 'inherited tracking' do
  let(:context) { klass.journable_context }
  let(:configuration) { ActiveRecord::Journal.configuration }
  let(:journal_records) { configuration.entries_class }
  let(:klass) { Fixtures::SelfPublisher }
  let(:record) { klass.create!(name: 'Gustav', author_id: 1) }

  before do
    ActiveRecord::Journal.tag(description: 'Rename and destroy') do |c|
      c.actions do
        record.reload
      end
    end

    record.update!(name: 'Friederich')
    record.destroy!

    ActiveRecord::Journal.ignore do |c|
      c.actions { klass.create!(name: 'Karl', author_id: 1).reload.destroy }
    end
  end

  it 'record for read' do
    expect(journal_records.where(action: :read).count).to eq 1
  end

  it 'record for create' do
    expect(journal_records.where(action: :create).count).to eq 1
  end

  it 'record for update' do
    expect(journal_records.where(action: :update).count).to eq 1
  end

  it 'record for destroy' do
    expect(journal_records.where(action: :destroy).count).to eq 1
  end

  it 'creates tag' do
    tag = JournalTag.first
    expect(tag.description).to eq 'Rename and destroy'
    expect(journal_records.where(journal_tag_id: tag.id).count).to eq 2
  end
end
