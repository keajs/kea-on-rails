module ActionDispatch::Routing
  class Mapper
    def kea_endpoint(*resources)
      path = resources[0]

      match path, to: Kea::Router.do_route, as: :kea, via: [:post]
    end

    def kea_bundle(*resources)
      options = resources.extract_options!
      bundle = options[:bundle] || resources[0] || 'common'
      component = options[:component] || 'AppContainer'
      prerender = options[:prerender].nil? ? true : options[:prerender]

      constraint = lambda do |request|
        request.env["kea.bundle"] = bundle
        request.env["kea.component"] = component
        request.env["kea.prerender"] = prerender
        true
      end

      constraints(constraint) do
        yield
      end
    end
  end
end
