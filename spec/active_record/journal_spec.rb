# frozen_string_literal: true

RSpec.describe ActiveRecord::Journal do
  describe '::VERSION' do
    subject { described_class::VERSION }

    it { is_expected.not_to be nil }
  end
end
