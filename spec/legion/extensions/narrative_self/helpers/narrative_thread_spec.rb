# frozen_string_literal: true

RSpec.describe Legion::Extensions::NarrativeSelf::Helpers::NarrativeThread do
  let(:thread) { described_class.new(theme: :growth, domain: :cognition) }

  describe '#initialize' do
    it 'sets theme and domain' do
      expect(thread.theme).to eq(:growth)
      expect(thread.domain).to eq(:cognition)
    end

    it 'starts with strength 0.5' do
      expect(thread.strength).to eq(0.5)
    end

    it 'starts with empty episode_ids' do
      expect(thread.episode_ids).to be_empty
    end

    it 'has a UUID id' do
      expect(thread.id).to match(/\A[0-9a-f-]{36}\z/)
    end
  end

  describe '#add_episode' do
    it 'adds an episode id' do
      thread.add_episode('ep-1')
      expect(thread.episode_ids).to include('ep-1')
    end

    it 'does not duplicate' do
      thread.add_episode('ep-1')
      thread.add_episode('ep-1')
      expect(thread.episode_ids.count('ep-1')).to eq(1)
    end

    it 'caps at MAX_CHAPTER_SIZE' do
      max = Legion::Extensions::NarrativeSelf::Helpers::Constants::MAX_CHAPTER_SIZE
      (max + 5).times { |i| thread.add_episode("ep-#{i}") }
      expect(thread.episode_ids.size).to eq(max)
    end

    it 'reinforces the thread' do
      initial = thread.strength
      thread.add_episode('ep-1')
      expect(thread.strength).to be > initial
    end
  end

  describe '#decay' do
    it 'reduces strength' do
      initial = thread.strength
      thread.decay
      expect(thread.strength).to be < initial
    end
  end

  describe '#weak?' do
    it 'is not weak when fresh' do
      expect(thread.weak?).to be false
    end

    it 'becomes weak after heavy decay' do
      100.times { thread.decay }
      expect(thread.weak?).to be true
    end
  end

  describe '#size' do
    it 'returns the episode count' do
      thread.add_episode('ep-1')
      thread.add_episode('ep-2')
      expect(thread.size).to eq(2)
    end
  end

  describe '#to_h' do
    it 'contains expected keys' do
      h = thread.to_h
      expect(h).to have_key(:id)
      expect(h).to have_key(:theme)
      expect(h).to have_key(:domain)
      expect(h).to have_key(:strength)
      expect(h).to have_key(:episodes)
    end
  end
end
