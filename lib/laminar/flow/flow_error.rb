# frozen_string_literal: true

module Laminar
  module Flow
    # Exception to immediately terminate rule processing
    class FlowError < StandardError
    end
  end
end
