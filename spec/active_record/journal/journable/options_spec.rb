# frozen_string_literal: true

RSpec.describe ActiveRecord::Journal::Journable::Options do
  subject { described_class.new(**kwargs) }
  let(:configurations) { ActiveRecord::Journal.configuration }
  let(:error_type) { ActiveRecord::Journal::Journable::OptionError }

  shared_examples 'contains options' do
    it 'has entries_class' do
      expect(subject.entries_class).to eq options[:entries_class]
    end
    it 'has on' do
      expect(subject.on).to eq options[:on]
    end
    it 'has if' do
      expect(subject.if).to eq options[:if]
    end
    it 'has unless' do
      expect(subject.unless).to eq options[:unless]
    end
    it 'has only' do
      expect(subject.only).to eq options[:only]
    end
    it 'has except' do
      expect(subject.except).to eq options[:except]
    end
    it 'has mask' do
      expect(subject.mask).to eq options[:mask]
    end
    it 'has type' do
      expect(subject.type).to eq options[:type]
    end
  end

  describe 'defaults' do
    context 'when type is reads' do
      let(:kwargs) { { type: :reads } }
      let(:options) do
        {
          entries_class: configurations.entries_class,
          on: ActiveRecord::Journal::ACTIONS[:reads],
          type: :reads
        }
      end
      include_examples 'contains options'
    end
    context 'when type is writes' do
      let(:kwargs) { { type: :writes } }
      let(:options) do
        {
          entries_class: configurations.entries_class,
          on: ActiveRecord::Journal::ACTIONS[:writes],
          type: :writes
        }
      end
      include_examples 'contains options'
    end
  end

  describe 'normalized' do
    let(:kwargs) do
      { type: :reads, on: %i[create], only: %i[foo], except: %i[foo], mask: %i[foo] }
    end
    let(:options) do
      { type: :reads, on: %w[create], only: %w[foo], except: %w[foo], mask: %w[foo],
        entries_class: configurations.entries_class }
    end
    include_examples 'contains options'
  end

  describe '#check_actions!' do
    shared_examples 'validate allowed actions' do
      it 'verifies if actions are valid for type' do
        valid_options.check_actions!
        expect { invalid_options.check_actions! }.to raise_error error_type
      end
    end

    context 'when reads allowed' do
      let(:valid_options) { described_class.new(type: :reads, on: %i[read]) }
      let(:invalid_options) { described_class.new(type: :reads, on: %i[create]) }
      include_examples 'validate allowed actions'
    end

    context 'when writes allowed' do
      let(:valid_options) { described_class.new(type: :writes, on: %i[create]) }
      let(:invalid_options) { described_class.new(type: :writes, on: %i[read]) }
      include_examples 'validate allowed actions'
    end
  end
end
