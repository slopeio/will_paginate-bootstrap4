require 'will_paginate/view_helpers/action_view'

module WillPaginate
  module ActionView
    def will_paginate(collection = nil, options = {})
      options, collection = collection, nil if collection.is_a? Hash
      collection ||= infer_collection_from_controller

      options = options.symbolize_keys
      options[:renderer] ||= BootstrapLinkRenderer
      options[:list_classes] ||= ['pagination']
      options[:previous_label] ||= '&larr;'
      options[:next_label] ||= '&rarr;'

      super(collection, options)
    end

    class BootstrapLinkRenderer < LinkRenderer
      ELLIPSIS = '&hellip;'

      def to_html
        list_items = pagination.map do |item|
          case item
            when (1.class == Integer ? Integer : Fixnum)
              page_number(item)
            else
              send(item)
          end
        end.join(@options[:link_separator])

        list_wrapper = tag :ul, list_items, class: @options[:list_classes].join(' ').to_s
        tag :nav, list_wrapper
      end

      def container_attributes
        super.except(*[:link_options])
      end

      protected

      def page_number(page)
        link_options = @options[:link_options] || {}

        if page == current_page
          tag :li, tag(:span, page, class: 'page-link'), class: 'page-item active'
        else
          link_options.merge! class: 'page-link', rel: rel_value(page)
          tag :li, link(page, page, link_options), class: 'page-item'
        end
      end

      def previous_or_next_page(page, text, classname)
        link_options = @options[:link_options] || {}

        if page
          link_wrapper = link(text, page, link_options.merge(class: 'page-link'))
          tag :li, link_wrapper, class: 'page-item'
        else
          span_wrapper = tag(:span, text, class: 'page-link')
          tag :li, span_wrapper, class: 'page-item disabled'
        end
      end

      def gap
        tag :li, tag(:i, ELLIPSIS, class: 'page-link'), class: 'page-item disabled'
      end

      def previous_page
        num = @collection.current_page > 1 && @collection.current_page - 1
        previous_or_next_page num, @options[:previous_label], 'previous'
      end

      def next_page
        num = @collection.current_page < @collection.total_pages && @collection.current_page + 1
        previous_or_next_page num, @options[:next_label], 'next'
      end
    end

    class BootstrapSpecialLinkRenderer < LinkRenderer
      ELLIPSIS = '&hellip;'

      def to_html
        list_items = pagination.map do |item|
          case item
            when (1.class == Integer ? Integer : Fixnum)
              page_number(item)
            else
              send(item)
          end
        end.join(@options[:link_separator])

        list_wrapper = tag :ul, list_items, class: @options[:list_classes].join(' ').to_s
        tag :nav, list_wrapper
      end

      def container_attributes
        super.except(*[:link_options])
      end

      protected

      def page_number(page)
        link_options = @options[:link_options] || {}

        if page == current_page
          tag :li, tag(:span, page, class: 'page-link'), class: 'page-item active'
        else
          link_options.merge! class: 'page-link', rel: rel_value(page)
          tag :li, link(page, page, link_options), class: 'page-item'
        end
      end

      def previous_or_next_page(page, text, classname)
        link_options = @options[:link_options] || {}

        if page
          link_wrapper = link(text, page, link_options.merge(class: 'page-link'))
          tag :li, link_wrapper, class: 'page-item'
        else
          span_wrapper = tag(:span, text, class: 'page-link')
          tag :li, span_wrapper, class: 'page-item disabled'
        end
      end

      def gap
        tag :li, tag(:i, ELLIPSIS, class: 'page-link'), class: 'page-item disabled'
      end

      def previous_page
        num = @collection.current_page > 1 && @collection.current_page - 1
        previous_or_next_page num, @options[:previous_label], 'previous'
      end

      def next_page
        num = @collection.current_page < @collection.total_pages && @collection.current_page + 1
        previous_or_next_page num, @options[:next_label], 'next'
      end

      def url(page)
        @base_url_params ||= begin
          url_params = merge_get_params(default_url_params)
          url_params[:only_path] = true
          merge_optional_params(url_params)
        end

        url_params = @base_url_params.dup
        # Get the tab param and remove it from params
        tab = url_params[:tab]
        url_params.except!(:tab)
        # Remove old page params
        url_params.except!(*Rails.configuration.page_params)
        # Remove ignored params
        url_params.except!(*Rails.configuration.ignored_params)
        add_current_page_param(url_params, page)

        url = @template.url_for(url_params)
        # Append #tab to the url, which is used to choose the active tab on page reload
        "#{url}##{tab}"
      end
    end
  end
end
