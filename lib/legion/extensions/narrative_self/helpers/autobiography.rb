# frozen_string_literal: true

module Legion
  module Extensions
    module NarrativeSelf
      module Helpers
        class Autobiography
          include Constants

          attr_reader :episodes, :threads, :self_concept

          def initialize
            @episodes     = []
            @threads      = []
            @self_concept = {}
          end

          def record_episode(description:, episode_type: :insight, domain: :general,
                             significance: nil, emotional_valence: 0.0, tags: [])
            episode = Episode.new(
              description:       description,
              episode_type:      episode_type,
              domain:            domain,
              significance:      significance,
              emotional_valence: emotional_valence,
              tags:              tags
            )
            @episodes << episode
            auto_link_threads(episode)
            update_self_concept(episode)
            trim_episodes
            episode
          end

          def find_episode(id)
            @episodes.find { |e| e.id == id }
          end

          def recent_episodes(count = 10)
            @episodes.last(count)
          end

          def significant_episodes(min_significance: 0.6)
            @episodes.select { |e| e.significance >= min_significance }
                     .sort_by { |e| -e.significance }
          end

          def episodes_by_type(episode_type)
            @episodes.select { |e| e.episode_type == episode_type }
          end

          def episodes_in_domain(domain)
            @episodes.select { |e| e.domain == domain }
          end

          def create_thread(theme:, domain: :general)
            thread = NarrativeThread.new(theme: theme, domain: domain)
            @threads << thread
            trim_threads
            thread
          end

          def find_thread(id)
            @threads.find { |t| t.id == id }
          end

          def find_threads_by_theme(theme)
            @threads.select { |t| t.theme == theme }
          end

          def strongest_threads(count = 5)
            @threads.sort_by { |t| -t.strength }.first(count)
          end

          def timeline(window: MAX_TIMELINE_WINDOW)
            @episodes.last(window).map(&:to_h)
          end

          def self_summary
            top_types = episode_type_distribution.first(3).map(&:first)
            top_domains = domain_distribution.first(3).map(&:first)
            top_threads = strongest_threads(3).map(&:theme)
            {
              total_episodes:     @episodes.size,
              dominant_types:     top_types,
              dominant_domains:   top_domains,
              active_threads:     top_threads,
              self_concept:       @self_concept.dup,
              pivotal_count:      @episodes.count { |e| e.label == :pivotal },
              narrative_richness: narrative_richness
            }
          end

          def decay_all
            @episodes.each(&:decay)
            @episodes.reject!(&:faded?)
            @threads.each(&:decay)
            @threads.reject!(&:weak?)
          end

          def to_h
            {
              episode_count:    @episodes.size,
              thread_count:     @threads.size,
              self_concept:     @self_concept.dup,
              by_type:          @episodes.group_by(&:episode_type).transform_values(&:size),
              by_domain:        @episodes.group_by(&:domain).transform_values(&:size),
              avg_significance: avg_significance
            }
          end

          private

          def auto_link_threads(episode)
            @threads.each do |thread|
              relevance = episode.matches_tags?([thread.theme])
              relevance += 0.2 if episode.domain == thread.domain
              next unless relevance >= THREAD_MATCH_THRESHOLD

              thread.add_episode(episode.id)
              episode.link_thread(thread.id)
            end
          end

          def update_self_concept(episode)
            trait = episode.episode_type
            current = @self_concept.fetch(trait, 0.0)
            signal = episode.significance
            @self_concept[trait] = ((TRAIT_ALPHA * signal) + ((1.0 - TRAIT_ALPHA) * current)).clamp(0.0, 1.0)
            trim_self_concept
          end

          def trim_self_concept
            return unless @self_concept.size > MAX_SELF_CONCEPT_TRAITS

            sorted = @self_concept.sort_by { |_, v| v }
            @self_concept = sorted.last(MAX_SELF_CONCEPT_TRAITS).to_h
          end

          def trim_episodes
            return unless @episodes.size > MAX_EPISODES

            @episodes.sort_by!(&:significance)
            @episodes.shift(@episodes.size - MAX_EPISODES)
          end

          def trim_threads
            return unless @threads.size > MAX_THREADS

            @threads.sort_by!(&:strength)
            @threads.shift(@threads.size - MAX_THREADS)
          end

          def episode_type_distribution
            @episodes.group_by(&:episode_type)
                     .transform_values(&:size)
                     .sort_by { |_, count| -count }
          end

          def domain_distribution
            @episodes.group_by(&:domain)
                     .transform_values(&:size)
                     .sort_by { |_, count| -count }
          end

          def avg_significance
            return 0.0 if @episodes.empty?

            @episodes.sum(&:significance) / @episodes.size
          end

          def narrative_richness
            return 0.0 if @episodes.empty?

            type_diversity = @episodes.map(&:episode_type).uniq.size.to_f / EPISODE_TYPES.size
            thread_activity = @threads.empty? ? 0.0 : @threads.count { |t| t.size > 1 }.to_f / @threads.size
            ((type_diversity + thread_activity) / 2.0).clamp(0.0, 1.0)
          end
        end
      end
    end
  end
end
