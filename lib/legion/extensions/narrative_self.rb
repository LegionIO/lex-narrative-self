# frozen_string_literal: true

require 'legion/extensions/narrative_self/version'
require 'legion/extensions/narrative_self/helpers/constants'
require 'legion/extensions/narrative_self/helpers/episode'
require 'legion/extensions/narrative_self/helpers/narrative_thread'
require 'legion/extensions/narrative_self/helpers/autobiography'
require 'legion/extensions/narrative_self/runners/narrative_self'
require 'legion/extensions/narrative_self/client'

module Legion
  module Extensions
    module NarrativeSelf
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
