# frozen_string_literal: true

module PreviewsHelper
  DEFAULT_ICON_FILEPATH= Rails.root.join('public', 'dc_image-icon.png').to_s.freeze

  def send_icon(filename)
    send_file DEFAULT_ICON_FILEPATH,
              :filename => "#{filename}.png",
              :type => :png,
              :disposition => 'inline'
  end

  def send_image(filename, file_path)
    send_file file_path,
              :filename => "#{filename}.jpg",
              :type => :jpg,
              :disposition => 'inline'
  end
end
