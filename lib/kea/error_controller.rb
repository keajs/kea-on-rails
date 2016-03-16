module Kea
  class ErrorController < ActionController::Base
    def render_kea_error
      render json: {error: env['KEA_ERROR']}
    end
  end
end
