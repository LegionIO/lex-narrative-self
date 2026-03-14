# frozen_string_literal: true

require 'legion/extensions/narrative_self/helpers/constants'
require 'legion/extensions/narrative_self/helpers/episode'
require 'legion/extensions/narrative_self/helpers/narrative_thread'
require 'legion/extensions/narrative_self/helpers/autobiography'
require 'legion/extensions/narrative_self/runners/narrative_self'

module Legion
  module Extensions
    module NarrativeSelf
      class Client
        include Runners::NarrativeSelf

        attr_reader :autobiography

        def initialize(autobiography: nil, **)
          @autobiography = autobiography || Helpers::Autobiography.new
        end
      end
    end
  end
end
