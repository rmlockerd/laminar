module FlowSpecHelpers
  def flow_factory(&block)
    flow = Class.new.send(:include, Laminar::Flow)
    flow.class_eval(&block) if block
    flow.send(:define_method, :true_condition) { true }
    flow.send(:define_method, :false_condition) { false }
    flow
  end
end

RSpec.configure do |c|
  c.include FlowSpecHelpers
end
