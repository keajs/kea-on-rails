module Kea
  class Router
    def self.do_route
      new
    end

    def initialize
    end

    def call(env)
      @env = env

      request = Rack::Request.new(env)
      body = request.body.read

      params = nil

      if body.present?
        params = JSON.parse(body).with_indifferent_access
        request.body.rewind
      else
        # googlebot seems to have given us data in this format
        if env['rack.request.form_vars'].present?
          json_params = JSON.parse(env['rack.request.form_vars']) rescue nil
          params = json_params.with_indifferent_access if json_params.present?

          if params.blank? && env['rack.request.form_hash'].present?
            params = env['rack.request.form_hash'].with_indifferent_access
          end
        end
      end

      @env['kea.params'] = params.with_indifferent_access

      begin
        @endpoint = params[:endpoint].classify.constantize

        unless @endpoint.ancestors.include? Kea::Controller
          return render_error({endpoint: 'does not descend from Kea::Controller'})
        end
      rescue => e
        return render_error({exception: e.message})
      end

      @endpoint.action(:run_kea_action).call(env)
    end

    def render_error(error)
      @env['kea.error'] = error
      Kea::ErrorController.action(:render_kea_error).call(@env)
    end
  end
end
