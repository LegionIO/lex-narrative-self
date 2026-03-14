# frozen_string_literal: true

RSpec.describe Legion::Extensions::NarrativeSelf::Runners::NarrativeSelf do
  let(:client) { Legion::Extensions::NarrativeSelf::Client.new }

  describe '#record_episode' do
    it 'returns success with episode data' do
      result = client.record_episode(description: 'completed first build', episode_type: :achievement)
      expect(result[:success]).to be true
      expect(result[:episode][:description]).to eq('completed first build')
      expect(result[:episode][:episode_type]).to eq(:achievement)
    end
  end

  describe '#recent_episodes' do
    before do
      3.times { |i| client.record_episode(description: "event #{i}") }
    end

    it 'returns recent episodes' do
      result = client.recent_episodes(count: 2)
      expect(result[:success]).to be true
      expect(result[:count]).to eq(2)
    end
  end

  describe '#significant_episodes' do
    before do
      client.record_episode(description: 'major', significance: 0.9)
      client.record_episode(description: 'minor', significance: 0.1)
    end

    it 'filters by significance' do
      result = client.significant_episodes(min_significance: 0.5)
      expect(result[:count]).to eq(1)
      expect(result[:episodes].first[:description]).to eq('major')
    end
  end

  describe '#episodes_by_type' do
    before do
      client.record_episode(description: 'win', episode_type: :achievement)
      client.record_episode(description: 'learn', episode_type: :insight)
    end

    it 'filters by type' do
      result = client.episodes_by_type(episode_type: :achievement)
      expect(result[:count]).to eq(1)
    end
  end

  describe '#create_thread' do
    it 'returns success with thread data' do
      result = client.create_thread(theme: :growth, domain: :personal)
      expect(result[:success]).to be true
      expect(result[:thread][:theme]).to eq(:growth)
    end
  end

  describe '#strongest_threads' do
    before do
      client.create_thread(theme: :growth)
      client.create_thread(theme: :mastery)
    end

    it 'returns threads sorted by strength' do
      result = client.strongest_threads(count: 2)
      expect(result[:success]).to be true
      expect(result[:count]).to eq(2)
    end
  end

  describe '#timeline' do
    before do
      3.times { |i| client.record_episode(description: "event #{i}") }
    end

    it 'returns timeline entries' do
      result = client.timeline(window: 10)
      expect(result[:success]).to be true
      expect(result[:count]).to eq(3)
      expect(result[:timeline].first).to be_a(Hash)
    end
  end

  describe '#self_summary' do
    before do
      client.record_episode(description: 'a', episode_type: :achievement, domain: :tech)
      client.record_episode(description: 'b', episode_type: :insight, domain: :personal)
    end

    it 'returns comprehensive summary' do
      result = client.self_summary
      expect(result[:success]).to be true
      expect(result[:summary][:total_episodes]).to eq(2)
      expect(result[:summary]).to have_key(:narrative_richness)
      expect(result[:summary]).to have_key(:self_concept)
    end
  end

  describe '#update_narrative_self' do
    it 'decays and reports counts' do
      client.record_episode(description: 'test')
      result = client.update_narrative_self
      expect(result[:success]).to be true
      expect(result[:episode_count]).to eq(1)
    end
  end

  describe '#narrative_self_stats' do
    it 'returns stats' do
      result = client.narrative_self_stats
      expect(result[:success]).to be true
      expect(result[:stats]).to have_key(:episode_count)
      expect(result[:stats]).to have_key(:thread_count)
    end
  end
end
