# frozen_string_literal: true

module Laminar
  # Callback hooks for particles
  module Callbacks
    def self.included(klass)
      klass.class_eval do
        extend ClassMethods
        include InstanceMethods
      end
    end

    # Class methods and attributes.
    module ClassMethods
      def before(*args, &block)
        before_list.concat(args)
        before_list << block if block
      end
      alias before_call before

      def after(*args, &block)
        after_list.concat(args)
        after_list << block if block
      end
      alias after_call after

      def before_list
        @before_list ||= []
      end

      def after_list
        @after_list ||= []
      end
    end

    # Additional instance methods
    module InstanceMethods
      private

      def run_before_callbacks
        run_callbacks(self.class.before_list)
      end

      def run_after_callbacks
        run_callbacks(self.class.after_list)
      end

      def run_callbacks(list)
        list.each { |cb| cb.is_a?(Symbol) ? send(cb) : instance_exec(&cb) }
      end
    end
  end
end
