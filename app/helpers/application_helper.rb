# frozen_string_literal: true

# General view helpers
module ApplicationHelper
  def sidebar_menu_items(advanced=Rails.configuration.x.advanced_mode)
    Rails.configuration.x.menu_items[advanced]
  end

  def bootstrap_flash
    flash.collect do |type, message|
      # Skip empty messages
      next if message.blank?

      context = case type.to_sym
      when :notice
        :success
      when :alert
        :warning
      when :error
        :danger
      else
        :secondary
      end
      render 'layouts/flash', context: context, message: message
    end.join.html_safe
  end

  def custom_image_exists?(filename)
    base_path = Rails.root.join('vendor', 'assets', 'images')
    File.exist?(File.join(base_path, "#{filename}.svg"))   ||
      File.exist?(File.join(base_path, "#{filename}.png")) ||
      File.exist?(File.join(base_path, "#{filename}.jpg"))
  end

  def tip_icon
    tag.i('lightbulb_outline', class: 'eos-icons text-warning align-middle',
                               title: 'Tip',
                               data:  { toggle: 'tooltip' }
    )
  end

  def source_footer
    render('layouts/source_footer')
      .gsub("\n", ' ').strip
      .gsub("'", '"')
      .html_safe
  end

  def markdown(text, escape_html: true)
    return '' if text.blank?

    markdown_options = {
      autolink:            true,
      space_after_headers: true,
      no_intra_emphasis:   true,
      fenced_code_blocks:  true,
      strikethrough:       true,
      superscript:         true,
      underline:           true,
      highlight:           true,
      quote:               true
    }
    render_options = {
      filter_html: true,
      no_images:   true,
      no_styles:   true
    }
    render_options[:escape_html] = true if escape_html

    # Redcarpet doesn't remove HTML comments even with `filter_html: true`
    # https://github.com/vmg/redcarpet/issues/692
    uncommented_text = text.gsub(/<!--(.*?)-->/, '')

    markdown = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(render_options),
      markdown_options
    )
    markdown.render(uncommented_text).html_safe
  end
end
