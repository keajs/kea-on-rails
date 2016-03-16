module Kea
  module Controller
    attr_accessor :running_via_kea

    def run_kea_action
      active_method = params['method']
      @running_via_kea = true
      self.send(active_method)
    end

  protected

    def params
      if @running_via_kea
        request.params['params']
      else
        request.params
      end
    end
  end
end
