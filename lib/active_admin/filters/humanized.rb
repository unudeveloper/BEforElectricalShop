module ActiveAdmin
  module Filters

    class Humanized
      include ActiveAdmin::ViewHelpers

      def initialize(param)
        @body = param[0]
        @value = param[1]
      end

      def value
        @value
      end

      def body
        predicate = ransack_predicate_translation

        if translation_missing?(predicate)
          predicate = active_admin_predicate_translation
        end

        "#{parse_parameter_body} #{predicate}"
      end

      private

      def parse_parameter_body
        @body.split(current_predicate)
          .first
          .gsub('_', ' ')
          .strip
          .titleize
          .gsub('Id', 'ID')
      end

      def current_predicate
        predicates.detect { |p| @body.include?(p) }
      end

      def predicates
        Ransack::Predicate.names_by_decreasing_length
      end

      def ransack_predicate_translation
        I18n.t("ransack.predicates.#{current_predicate}")
      end

      def active_admin_predicate_translation
        I18n.t("active_admin.filters.predicates.#{current_predicate}").downcase
      end

      def translation_missing?(predicate)
        predicate.downcase.include?('translation missing')
      end

    end

  end
end
