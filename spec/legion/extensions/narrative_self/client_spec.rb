# frozen_string_literal: true

RSpec.describe Legion::Extensions::NarrativeSelf::Client do
  let(:client) { described_class.new }

  it 'can be instantiated' do
    expect(client).to be_a(described_class)
  end

  it 'includes all runner methods' do
    expect(client).to respond_to(:record_episode)
    expect(client).to respond_to(:recent_episodes)
    expect(client).to respond_to(:significant_episodes)
    expect(client).to respond_to(:create_thread)
    expect(client).to respond_to(:self_summary)
    expect(client).to respond_to(:update_narrative_self)
    expect(client).to respond_to(:narrative_self_stats)
  end

  it 'exposes the autobiography' do
    expect(client.autobiography).to be_a(Legion::Extensions::NarrativeSelf::Helpers::Autobiography)
  end

  describe 'full lifecycle' do
    it 'builds a narrative from episodes and threads' do
      # Create narrative threads
      client.create_thread(theme: :learning, domain: :cognition)
      client.create_thread(theme: :mastery, domain: :technical)

      # Record experiences
      client.record_episode(
        description:       'built first extension',
        episode_type:      :achievement,
        domain:            :technical,
        emotional_valence: 0.7,
        tags:              %i[building mastery]
      )
      client.record_episode(
        description:  'learned about EMA',
        episode_type: :insight,
        domain:       :cognition,
        tags:         %i[learning math]
      )
      client.record_episode(
        description:       'test failure taught me about edge cases',
        episode_type:      :discovery,
        domain:            :technical,
        emotional_valence: -0.3,
        tags:              %i[learning debugging]
      )

      # Check timeline
      tl = client.timeline
      expect(tl[:count]).to eq(3)

      # Check self-summary
      summary = client.self_summary[:summary]
      expect(summary[:total_episodes]).to eq(3)
      expect(summary[:self_concept]).not_to be_empty

      # Tick
      client.update_narrative_self
      stats = client.narrative_self_stats[:stats]
      expect(stats[:episode_count]).to eq(3)
    end
  end
end
