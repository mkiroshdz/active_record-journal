# frozen_string_literal: true

RSpec.describe ActiveRecord::Journal::Journable do
  describe '::journal_reads' do
    context 'when class is not journable' do
      subject { Fixtures::AppRecord }
      it { is_expected.not_to respond_to(:journal_reads) }
    end

    context 'when class is journable' do
      subject { Fixtures::JournableAppRecord }
      it { is_expected.to respond_to(:journal_reads) }
    end
  end

  describe '::journal_writes' do
    context 'when class is not journable' do
      subject { Fixtures::AppRecord }
      it { is_expected.not_to respond_to(:journal_writes) }
    end

    context 'when class is journable' do
      subject { Fixtures::JournableAppRecord }
      it { is_expected.to respond_to(:journal_writes) }
    end
  end

  describe '::journable_context' do
    subject(:context) { klass.journable_context }

    context 'when inherited from STI' do
      let(:klass) { Fixtures::OriginalAuthor }
      it 'points to the correct configuration' do
        is_expected.to be Fixtures::Author.journable_context
      end
    end

    context 'when config inherited from STI and overriden' do
      subject(:klass) { Fixtures::GuestAuthor }
      it 'points to the correct configuration' do
        is_expected.not_to be nil
        is_expected.not_to be Fixtures::Author.journable_context
      end
    end

    context 'when inherited from abstract model' do
      let(:klass) { Fixtures::SelfPublisher }
      it 'points to the correct configuration' do
        is_expected.to be Fixtures::Publisher.journable_context
      end
    end

    context 'when config inherited from abstract model and overriden' do
      let(:klass) { Fixtures::PublisherCompany }
      it 'points to the correct configuration' do
        is_expected.not_to be nil
        is_expected.not_to be Fixtures::Publisher.journable_context
      end
    end
  end
end
