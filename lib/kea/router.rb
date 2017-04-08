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
      request.body.rewind

      if body.blank? && env['rack.request.form_vars'].present?
        body = env['rack.request.form_vars']
      end

      params = nil

      if body.present? && body =~ /\A{.*}\z/
        params = JSON.parse(body).with_indifferent_access
      elsif env['rack.request.form_hash'].present? && env['rack.request.form_hash']['endpoint'].present?
        params = env['rack.request.form_hash'].with_indifferent_access
      else
        return render_error({ request: 'Request params not found' })
      end

      @env['kea.params'] = params

      begin
        @endpoint = params[:endpoint].classify.constantize

        unless @endpoint.ancestors.include? Kea::Controller
          return render_error({ endpoint: 'does not descend from Kea::Controller' })
        end
      rescue => e
        return render_error({ exception: e.message })
      end

      @endpoint.action(:run_kea_action).call(env)
    end

    def render_error(error)
      @env['kea.error'] = error
      Kea::ErrorController.action(:render_kea_error).call(@env)
    end
  end
end
