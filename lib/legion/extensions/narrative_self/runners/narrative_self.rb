# frozen_string_literal: true

module Legion
  module Extensions
    module NarrativeSelf
      module Runners
        module NarrativeSelf
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def record_episode(description:, episode_type: :insight, domain: :general,
                             significance: nil, emotional_valence: 0.0, tags: [], **)
            episode = autobiography.record_episode(
              description:       description,
              episode_type:      episode_type,
              domain:            domain,
              significance:      significance,
              emotional_valence: emotional_valence,
              tags:              tags
            )
            Legion::Logging.debug "[narrative_self] recorded episode=#{episode_type} domain=#{domain} sig=#{episode.significance.round(3)}"
            { success: true, episode: episode.to_h }
          end

          def recent_episodes(count: 10, **)
            episodes = autobiography.recent_episodes(count)
            { success: true, episodes: episodes.map(&:to_h), count: episodes.size }
          end

          def significant_episodes(min_significance: 0.6, **)
            episodes = autobiography.significant_episodes(min_significance: min_significance)
            { success: true, episodes: episodes.map(&:to_h), count: episodes.size }
          end

          def episodes_by_type(episode_type:, **)
            episodes = autobiography.episodes_by_type(episode_type)
            { success: true, episodes: episodes.map(&:to_h), count: episodes.size }
          end

          def create_thread(theme:, domain: :general, **)
            thread = autobiography.create_thread(theme: theme, domain: domain)
            Legion::Logging.debug "[narrative_self] created thread=#{theme} domain=#{domain}"
            { success: true, thread: thread.to_h }
          end

          def strongest_threads(count: 5, **)
            threads = autobiography.strongest_threads(count)
            { success: true, threads: threads.map(&:to_h), count: threads.size }
          end

          def timeline(window: nil, **)
            w = window || Helpers::Constants::MAX_TIMELINE_WINDOW
            entries = autobiography.timeline(window: w)
            { success: true, timeline: entries, count: entries.size }
          end

          def self_summary(**)
            summary = autobiography.self_summary
            Legion::Logging.debug "[narrative_self] summary: episodes=#{summary[:total_episodes]} richness=#{summary[:narrative_richness].round(3)}"
            { success: true, summary: summary }
          end

          def update_narrative_self(**)
            autobiography.decay_all
            Legion::Logging.debug "[narrative_self] tick: episodes=#{autobiography.episodes.size} threads=#{autobiography.threads.size}"
            { success: true, episode_count: autobiography.episodes.size, thread_count: autobiography.threads.size }
          end

          def narrative_self_stats(**)
            { success: true, stats: autobiography.to_h }
          end

          private

          def autobiography
            @autobiography ||= Helpers::Autobiography.new
          end
        end
      end
    end
  end
end
