# frozen_string_literal: true

module GraphqlRails
  module Model
    # stores information about model specific config, like attributes and types
    class GraphqlTypeBuilder
      def initialize(name:, description: nil, attributes:)
        @name = name
        @attributes = attributes
        @description = description
      end

      def call
        type_name = name
        type_description = description
        type_attributes = attributes

        GraphQL::ObjectType.define do
          name(type_name)
          description(type_description)

          type_attributes.each_value do |attribute|
            field(*attribute.field_args)
          end
        end
      end

      private

      attr_reader :model_configuration, :attributes, :name, :description
    end
  end
end
