module Kea
  class ErrorController < ActionController::Base
    def render_kea_error
      render json: {error: request.env['kea.error']}
    end
  end
end
