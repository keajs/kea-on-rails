module Kea
  class ErrorController < ActionController::Base
    def render_kea_error
      render json: {error: env['kea.error']}
    end
  end
end
