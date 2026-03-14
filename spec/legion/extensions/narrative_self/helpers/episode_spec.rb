# frozen_string_literal: true

RSpec.describe Legion::Extensions::NarrativeSelf::Helpers::Episode do
  let(:episode) do
    described_class.new(
      description:       'learned to handle context switches',
      episode_type:      :insight,
      domain:            :cognition,
      emotional_valence: 0.6,
      tags:              %i[learning context performance]
    )
  end

  describe '#initialize' do
    it 'sets description and type' do
      expect(episode.description).to eq('learned to handle context switches')
      expect(episode.episode_type).to eq(:insight)
    end

    it 'sets domain' do
      expect(episode.domain).to eq(:cognition)
    end

    it 'starts with default significance' do
      plain = described_class.new(description: 'test')
      expect(plain.significance).to eq(Legion::Extensions::NarrativeSelf::Helpers::Constants::DEFAULT_SIGNIFICANCE)
    end

    it 'clamps emotional valence to [-1, 1]' do
      extreme = described_class.new(description: 'extreme', emotional_valence: 5.0)
      expect(extreme.emotional_valence).to eq(1.0)
    end

    it 'has a UUID id' do
      expect(episode.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores tags' do
      expect(episode.tags).to eq(%i[learning context performance])
    end

    it 'starts with empty thread_ids' do
      expect(episode.thread_ids).to be_empty
    end
  end

  describe '#boost' do
    it 'increases significance' do
      initial = episode.significance
      episode.boost(0.1)
      expect(episode.significance).to be > initial
    end

    it 'includes emotional factor' do
      low_emotion = described_class.new(description: 'calm', emotional_valence: 0.0)
      high_emotion = described_class.new(description: 'excited', emotional_valence: 0.9)
      low_emotion.boost(0.1)
      high_emotion.boost(0.1)
      expect(high_emotion.significance).to be > low_emotion.significance
    end

    it 'caps at 1.0' do
      10.times { episode.boost(0.5) }
      expect(episode.significance).to be <= 1.0
    end
  end

  describe '#decay' do
    it 'decreases significance' do
      initial = episode.significance
      episode.decay
      expect(episode.significance).to be < initial
    end

    it 'does not go below zero' do
      200.times { episode.decay }
      expect(episode.significance).to be >= 0.0
    end
  end

  describe '#faded?' do
    it 'is not faded when fresh' do
      expect(episode.faded?).to be false
    end

    it 'becomes faded after heavy decay' do
      200.times { episode.decay }
      expect(episode.faded?).to be true
    end
  end

  describe '#label' do
    it 'returns a symbol' do
      expect(episode.label).to be_a(Symbol)
    end

    it 'returns :minor for low significance' do
      200.times { episode.decay }
      expect(episode.label).to eq(:minor)
    end
  end

  describe '#link_thread' do
    it 'adds a thread id' do
      episode.link_thread('thread-1')
      expect(episode.thread_ids).to include('thread-1')
    end

    it 'does not duplicate' do
      episode.link_thread('thread-1')
      episode.link_thread('thread-1')
      expect(episode.thread_ids.count('thread-1')).to eq(1)
    end
  end

  describe '#matches_tags?' do
    it 'returns match ratio for overlapping tags' do
      score = episode.matches_tags?(%i[learning performance])
      expect(score).to be_within(0.01).of(2.0 / 2.0)
    end

    it 'returns 0.0 for no overlap' do
      expect(episode.matches_tags?(%i[sleep eat])).to eq(0.0)
    end

    it 'returns 0.0 for empty input' do
      expect(episode.matches_tags?([])).to be_falsey
    end
  end

  describe '#to_h' do
    it 'contains all expected keys' do
      h = episode.to_h
      expect(h).to have_key(:id)
      expect(h).to have_key(:description)
      expect(h).to have_key(:episode_type)
      expect(h).to have_key(:significance)
      expect(h).to have_key(:emotional_valence)
      expect(h).to have_key(:label)
      expect(h).to have_key(:tags)
      expect(h).to have_key(:thread_ids)
    end
  end
end
