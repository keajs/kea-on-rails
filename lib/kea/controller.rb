module Kea
  module Controller
    attr_accessor :running_via_kea

    def run_kea_action
      active_method = params['method']
      if self.respond_to? active_method
        @running_via_kea = true
        self.send(active_method)
      else
        raise Kea::ActionNotFoundError
      end
    end

    def params
      if @running_via_kea
        if request.env['kea.params'].present?
          request.env['kea.params']['params']
        else
          request.params['params']
        end
      else
        if request.env['kea.params'].present?
          request.env['kea.params']
        else
          request.params
        end
      end
    end

    def render_props_or_component
      respond_to do |format|
        format.html { render 'kea/component' }
        format.json { render json: @props }
      end
    end
  end
end
