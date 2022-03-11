# frozen_string_literal: true

RSpec.describe 'writes tracking' do
  let(:user) { Fixtures::User.create!(username: 'jane-doe') }
  let(:context) { klass.journable_context }
  let(:klass) { Fixtures::OriginalAuthor }
  let(:journal_records) { configuration.entries_class }
  let(:configuration) { ActiveRecord::Journal.configuration }

  context 'when read actions' do
    let(:journal_records) { configuration.entries_class.where(action: :read) }

    before do
      klass.create!(last_name: 'Garcia Marquez')
      klass.create!(last_name: 'Allende')
    end

    it 'does not trigger read callbacks' do
      expect(journal_records.count).to eq 0
    end
  end

  context 'when writing actions' do
    let(:record) { klass.create!(last_name: 'Austin') }
    let(:journal_records) { configuration.entries_class.where(journable: record) }

    before do
      record.update!(last_name: 'Wrong')
      ActiveRecord::Journal.ignore do |c|
        c.actions do
          record.update!(last_name: 'Anon')
          record.update!(last_name: 'Anonymous')
        end
      end
      record.destroy!
    end

    it 'records create action' do
      expect(journal_records.where(action: :create).count).to eq 1
    end

    it 'records update action' do
      expect(journal_records.where(action: :update).count).to eq 1
    end

    it 'records destroy action' do
      expect(journal_records.where(action: :destroy).count).to eq 1
    end
  end

  context 'when autorecording disabled', autorecording_enabled: false do
    let(:record1) { klass.create!(last_name: 'Austin') }
    let(:record2) { klass.create!(last_name: 'King') }
    let(:journal_records) { configuration.entries_class }
    let(:tag) { JournalTag.last }

    before do
      record1.update!(name: 'Jane')
      ActiveRecord::Journal.tag(user: user) do |context|
        context.actions do
          klass.create!(last_name: 'Smith')
          record1.update!(name: 'Erick')
          record1.destroy!
        end
      end
      record2.destroy!
      record1.destroy!
    end

    it 'records create action' do
      expect(journal_records.where(action: :create).count).to eq 1
    end

    it 'records update action' do
      expect(journal_records.where(action: :update).count).to eq 1
    end

    it 'records destroy action' do
      expect(journal_records.where(action: :destroy).count).to eq 1
    end

    it 'creates tag with data' do
      expect(tag.user).to eq user
    end

    it 'associates actios with tag' do
      expect(journal_records.where(journal_tag_id: tag.id).count).to eq 3
    end
  end

  context 'when one time condition' do
    let(:record) { klass.create!(last_name: 'Austin') }
    let(:journal_records) { configuration.entries_class.where(journable: record) }

    before do
      ActiveRecord::Journal.tag(user: user, description: 'test') do |context|
        context.record(klass, :writes, on: %i[destroy], if: ->(_) { false })
        context.actions do
          record.update!(name: 'Jane')
          record.update!(name: 'Erick')
          record.destroy!
        end
      end
      klass.create!(last_name: 'Smith')
      record.destroy!
    end

    it 'records create action' do
      expect(journal_records.where(action: :create).count).to eq 1
    end

    it 'records update action' do
      expect(journal_records.where(action: :update).count).to eq 2
    end

    it 'records destroy action' do
      expect(journal_records.where(action: :destroy).count).to eq 1
    end
  end
end
