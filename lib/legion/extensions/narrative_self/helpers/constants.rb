# frozen_string_literal: true

module Legion
  module Extensions
    module NarrativeSelf
      module Helpers
        module Constants
          MAX_EPISODES        = 500
          MAX_THREADS         = 50
          MAX_CHAPTER_SIZE    = 20
          EPISODE_DECAY       = 0.005
          THREAD_DECAY        = 0.01
          SIGNIFICANCE_FLOOR  = 0.05
          SIGNIFICANCE_ALPHA  = 0.15
          DEFAULT_SIGNIFICANCE = 0.5
          EMOTIONAL_BOOST = 0.3
          THREAD_MATCH_THRESHOLD = 0.3
          MAX_SELF_CONCEPT_TRAITS = 30
          TRAIT_ALPHA         = 0.1
          MAX_TIMELINE_WINDOW = 100

          SIGNIFICANCE_LABELS = {
            (0.8..)     => :pivotal,
            (0.6...0.8) => :important,
            (0.3...0.6) => :routine,
            (..0.3)     => :minor
          }.freeze

          EPISODE_TYPES = %i[
            achievement failure discovery connection
            conflict resolution insight surprise
            decision transition reflection
          ].freeze
        end
      end
    end
  end
end
