RSpec.describe ActiveRecord::Journal::Journable::Options do
  subject { described_class.new(**kwargs) }
  let(:configurations) { ActiveRecord::Journal.configuration }
  let(:error_type) { ActiveRecord::Journal::Journable::OptionError }

  shared_examples 'contains options' do
    it { expect(subject.journal).to eq options[:journal] }
    it { expect(subject.on).to eq options[:on] }
    it { expect(subject.if).to eq options[:if] }
    it { expect(subject.unless).to eq options[:unless] }
    it { expect(subject.only).to eq options[:only] }
    it { expect(subject.except).to eq options[:except] }
    it { expect(subject.journable).to eq options[:journable] }
    it { expect(subject.type).to eq options[:type] }
  end

  describe 'defaults' do
    context 'when type is reads' do
      let(:kwargs) { { type: :reads } }
      let(:options) do
        {
          journal: configurations.journal,
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
          journal: configurations.journal,
          on: ActiveRecord::Journal::ACTIONS[:writes],
          type: :writes
        }
      end
      include_examples 'contains options'
    end
  end

  describe 'normalization' do
    let(:kwargs) do 
      { type: :reads, on: %i[create], only: %i[foo], except: %i[foo] }
    end
    let(:options) do
      { type: :reads, on: %w[create], only: %w[foo], except: %w[foo], journal: configurations.journal }
    end
    include_examples 'contains options'
  end

  describe '#check_type!' do
    shared_examples 'validate allowed types' do
      it 'only allowed in configuration' do
        valid_options.check_type!
        expect { invalid_options.check_type! }.to raise_error error_type
      end
    end

    context 'reads allowed' do
      before { configurations.allowed_on = %w[reads] }
      let(:valid_options) { described_class.new(type: :reads) }
      let(:invalid_options) { described_class.new(type: :writes) }  
      include_examples 'validate allowed types'
    end

    context 'writes allowed' do
      before { configurations.allowed_on = %w[writes] }
      let(:valid_options) { described_class.new(type: :writes) }
      let(:invalid_options) { described_class.new(type: :reads) }
      include_examples 'validate allowed types'
    end
  end

  describe '#check_actions!' do
    shared_examples 'validate allowed actions' do
      it 'only allowed in configuration' do
        valid_options.check_actions!
        expect { invalid_options.check_actions! }.to raise_error error_type
      end
    end

    context 'reads allowed' do
      before { configurations.allowed_on = %w[reads] }
      let(:valid_options) { described_class.new(type: :reads, on: %i[read]) }
      let(:invalid_options) { described_class.new(type: :reads, on: %i[create]) }  
      include_examples 'validate allowed actions'
    end

    context 'writes allowed' do
      before { configurations.allowed_on = %w[writes] }
      let(:valid_options) { described_class.new(type: :writes, on: %i[create]) }
      let(:invalid_options) { described_class.new(type: :writes, on: %i[read]) }  
      include_examples 'validate allowed actions'
    end
  end
end
