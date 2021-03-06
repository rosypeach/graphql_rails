# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'

require 'graphql_rails/router/schema_builder'
require 'graphql_rails/router/mutation_route'
require 'graphql_rails/router/query_route'
require 'graphql_rails/router/resource_routes_builder'

module GraphqlRails
  # graphql router that mimics Rails.application.routes
  class Router
    RAW_ACTION_NAMES = %i[
      rescue_from query_analyzer instrument cursor_encoder default_max_page_size
    ].freeze

    def self.draw(&block)
      router = new
      router.instance_eval(&block)
      router.graphql_schema
    end

    attr_reader :routes, :namespace_name, :raw_graphql_actions

    def initialize(module_name: '')
      @module_name = module_name
      @routes ||= Set.new
      @raw_graphql_actions ||= []
    end

    def scope(**options, &block)
      full_module_name = [module_name, options[:module]].reject(&:empty?).join('/')
      scoped_router = self.class.new(module_name: full_module_name)
      scoped_router.instance_eval(&block)
      routes.merge(scoped_router.routes)
    end

    def resources(name, **options, &block)
      builder_options = default_route_options.merge(options)
      routes_builder = ResourceRoutesBuilder.new(name, **builder_options)
      routes_builder.instance_eval(&block) if block
      routes.merge(routes_builder.routes)
    end

    def query(name, **options)
      routes << build_route(QueryRoute, name, **options)
    end

    def mutation(name, **options)
      routes << build_route(MutationRoute, name, **options)
    end

    RAW_ACTION_NAMES.each do |action_name|
      define_method(action_name) do |*args, &block|
        add_raw_action(action_name, *args, &block)
      end
    end

    def graphql_schema
      SchemaBuilder.new(
        queries: routes.select(&:query?),
        mutations: routes.select(&:mutation?),
        raw_actions: raw_graphql_actions
      ).call
    end

    private

    attr_reader :module_name

    def add_raw_action(name, *args, &block)
      raw_graphql_actions << { name: name, args: args, block: block }
    end

    def build_route(route_builder, name, **options)
      route_options = default_route_options.merge(options)
      route_builder.new(name, route_options)
    end

    def default_route_options
      { module: module_name, on: :member }
    end
  end
end
