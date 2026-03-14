# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module NarrativeSelf
      module Helpers
        class Episode
          include Constants

          attr_reader :id, :description, :episode_type, :domain, :significance,
                      :emotional_valence, :tags, :created_at, :thread_ids

          def initialize(description:, episode_type: :insight, domain: :general,
                         significance: nil, emotional_valence: 0.0, tags: [])
            @id                = SecureRandom.uuid
            @description       = description
            @episode_type      = episode_type
            @domain            = domain
            @significance      = significance || DEFAULT_SIGNIFICANCE
            @emotional_valence = emotional_valence.clamp(-1.0, 1.0)
            @tags              = tags
            @created_at        = Time.now.utc
            @thread_ids        = []
          end

          def boost(amount)
            emotional_factor = @emotional_valence.abs * EMOTIONAL_BOOST
            @significance = [(@significance + amount + emotional_factor), 1.0].min
          end

          def decay
            @significance = [(@significance - EPISODE_DECAY), 0.0].max
          end

          def faded?
            @significance < SIGNIFICANCE_FLOOR
          end

          def label
            SIGNIFICANCE_LABELS.each do |range, lbl|
              return lbl if range.cover?(@significance)
            end
            :minor
          end

          def link_thread(thread_id)
            @thread_ids << thread_id unless @thread_ids.include?(thread_id)
          end

          def matches_tags?(query_tags)
            return false if query_tags.empty? || @tags.empty?

            overlap = (@tags & query_tags).size
            overlap.to_f / query_tags.size
          end

          def to_h
            {
              id:                @id,
              description:       @description,
              episode_type:      @episode_type,
              domain:            @domain,
              significance:      @significance,
              emotional_valence: @emotional_valence,
              label:             label,
              tags:              @tags.dup,
              thread_ids:        @thread_ids.dup,
              created_at:        @created_at
            }
          end
        end
      end
    end
  end
end
