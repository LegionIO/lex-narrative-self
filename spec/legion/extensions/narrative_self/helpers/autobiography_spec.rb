# frozen_string_literal: true

RSpec.describe Legion::Extensions::NarrativeSelf::Helpers::Autobiography do
  let(:auto) { described_class.new }

  describe '#record_episode' do
    it 'creates and stores an episode' do
      episode = auto.record_episode(description: 'first task completed', episode_type: :achievement)
      expect(episode).to be_a(Legion::Extensions::NarrativeSelf::Helpers::Episode)
      expect(auto.episodes.size).to eq(1)
    end

    it 'updates self-concept with episode type' do
      auto.record_episode(description: 'test', episode_type: :achievement)
      expect(auto.self_concept).to have_key(:achievement)
    end

    it 'trims episodes when exceeding MAX_EPISODES' do
      max = Legion::Extensions::NarrativeSelf::Helpers::Constants::MAX_EPISODES
      (max + 5).times { |i| auto.record_episode(description: "episode #{i}") }
      expect(auto.episodes.size).to eq(max)
    end
  end

  describe '#find_episode' do
    it 'finds by id' do
      ep = auto.record_episode(description: 'test')
      expect(auto.find_episode(ep.id)).to eq(ep)
    end

    it 'returns nil for unknown id' do
      expect(auto.find_episode('nonexistent')).to be_nil
    end
  end

  describe '#recent_episodes' do
    it 'returns the last N episodes' do
      5.times { |i| auto.record_episode(description: "ep #{i}") }
      recent = auto.recent_episodes(3)
      expect(recent.size).to eq(3)
      expect(recent.last.description).to eq('ep 4')
    end
  end

  describe '#significant_episodes' do
    it 'returns episodes above threshold' do
      auto.record_episode(description: 'big deal', significance: 0.9)
      auto.record_episode(description: 'small thing', significance: 0.2)
      significant = auto.significant_episodes(min_significance: 0.5)
      expect(significant.size).to eq(1)
      expect(significant.first.description).to eq('big deal')
    end
  end

  describe '#episodes_by_type' do
    it 'filters by episode type' do
      auto.record_episode(description: 'win', episode_type: :achievement)
      auto.record_episode(description: 'loss', episode_type: :failure)
      auto.record_episode(description: 'another win', episode_type: :achievement)
      expect(auto.episodes_by_type(:achievement).size).to eq(2)
    end
  end

  describe '#episodes_in_domain' do
    it 'filters by domain' do
      auto.record_episode(description: 'code', domain: :technical)
      auto.record_episode(description: 'meeting', domain: :social)
      expect(auto.episodes_in_domain(:technical).size).to eq(1)
    end
  end

  describe '#create_thread' do
    it 'creates a narrative thread' do
      thread = auto.create_thread(theme: :growth, domain: :personal)
      expect(thread.theme).to eq(:growth)
      expect(auto.threads.size).to eq(1)
    end
  end

  describe '#strongest_threads' do
    it 'returns threads sorted by strength' do
      auto.create_thread(theme: :growth)
      t2 = auto.create_thread(theme: :mastery)
      t2.reinforce
      strongest = auto.strongest_threads(2)
      expect(strongest.first).to eq(t2)
    end
  end

  describe '#timeline' do
    it 'returns recent episodes as hashes' do
      auto.record_episode(description: 'first')
      auto.record_episode(description: 'second')
      tl = auto.timeline(window: 10)
      expect(tl.size).to eq(2)
      expect(tl.first).to be_a(Hash)
    end
  end

  describe '#self_summary' do
    it 'returns a comprehensive summary' do
      auto.record_episode(description: 'a', episode_type: :achievement, domain: :tech)
      auto.record_episode(description: 'b', episode_type: :insight, domain: :tech)
      summary = auto.self_summary
      expect(summary).to have_key(:total_episodes)
      expect(summary).to have_key(:dominant_types)
      expect(summary).to have_key(:dominant_domains)
      expect(summary).to have_key(:self_concept)
      expect(summary).to have_key(:narrative_richness)
      expect(summary[:total_episodes]).to eq(2)
    end
  end

  describe '#decay_all' do
    it 'decays episodes and removes faded ones' do
      ep = auto.record_episode(description: 'old', significance: 0.06)
      200.times { ep.decay }
      auto.decay_all
      expect(auto.episodes).not_to include(ep)
    end

    it 'decays threads and removes weak ones' do
      t = auto.create_thread(theme: :test)
      100.times { t.decay }
      auto.decay_all
      expect(auto.threads).not_to include(t)
    end
  end

  describe '#to_h' do
    it 'returns summary statistics' do
      auto.record_episode(description: 'test', episode_type: :insight, domain: :tech)
      h = auto.to_h
      expect(h).to have_key(:episode_count)
      expect(h).to have_key(:thread_count)
      expect(h).to have_key(:self_concept)
      expect(h).to have_key(:by_type)
      expect(h).to have_key(:by_domain)
      expect(h).to have_key(:avg_significance)
    end
  end

  describe 'auto-linking' do
    it 'links episodes to matching threads' do
      thread = auto.create_thread(theme: :learning, domain: :cognition)
      episode = auto.record_episode(
        description: 'learned something new',
        domain:      :cognition,
        tags:        %i[learning growth]
      )
      expect(thread.episode_ids).to include(episode.id)
      expect(episode.thread_ids).to include(thread.id)
    end
  end
end
