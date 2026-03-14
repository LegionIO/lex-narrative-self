# frozen_string_literal: true

RSpec.describe Legion::Extensions::NarrativeSelf::Helpers::Constants do
  it 'defines MAX_EPISODES' do
    expect(described_class::MAX_EPISODES).to eq(500)
  end

  it 'defines MAX_THREADS' do
    expect(described_class::MAX_THREADS).to eq(50)
  end

  it 'defines EPISODE_TYPES' do
    expect(described_class::EPISODE_TYPES).to include(:achievement, :failure, :discovery, :insight)
  end

  it 'defines SIGNIFICANCE_LABELS covering 0.0..1.0' do
    labels = described_class::SIGNIFICANCE_LABELS
    [0.0, 0.1, 0.3, 0.5, 0.7, 0.9, 1.0].each do |val|
      matched = labels.any? { |range, _| range.cover?(val) }
      expect(matched).to be(true), "Expected #{val} to match a label range"
    end
  end

  it 'has all expected SIGNIFICANCE_LABELS values' do
    values = described_class::SIGNIFICANCE_LABELS.values
    expect(values).to contain_exactly(:pivotal, :important, :routine, :minor)
  end
end
