# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module NarrativeSelf
      module Helpers
        class NarrativeThread
          include Constants

          attr_reader :id, :theme, :domain, :strength, :episode_ids, :created_at

          def initialize(theme:, domain: :general)
            @id          = SecureRandom.uuid
            @theme       = theme
            @domain      = domain
            @strength    = 0.5
            @episode_ids = []
            @created_at  = Time.now.utc
          end

          def add_episode(episode_id)
            return if @episode_ids.include?(episode_id)

            @episode_ids << episode_id
            @episode_ids.shift if @episode_ids.size > MAX_CHAPTER_SIZE
            reinforce
          end

          def reinforce
            @strength = [@strength + 0.1, 1.0].min
          end

          def decay
            @strength = [(@strength - THREAD_DECAY), 0.0].max
          end

          def weak?
            @strength < SIGNIFICANCE_FLOOR
          end

          def size
            @episode_ids.size
          end

          def to_h
            {
              id:         @id,
              theme:      @theme,
              domain:     @domain,
              strength:   @strength,
              episodes:   @episode_ids.size,
              created_at: @created_at
            }
          end
        end
      end
    end
  end
end
