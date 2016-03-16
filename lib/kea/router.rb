module Kea
  class Router
    def self.do_route
      new
    end

    def initialize
    end

    def call(env)
      @env = env
      params = (@env['rack.request.form_hash'] || Rack::Utils.parse_nested_query(@env['QUERY_STRING'])).deep_symbolize_keys

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
      @env['KEA_ERROR'] = error
      Kea::ErrorController.action(:render_kea_error).call(@env)
    end
  end
end
