module HomeHelper
  def thumbnail_image(directory, filename, align)
    directory = "/images/#{directory}/"
    thumb = "#{directory}thumb-#{filename}"
    filename = "#{directory}#{filename}"

    content_tag(:div, link_to(image_tag(thumb), filename, :rel => "thumbnail"), :class => "image-#{align}")
  end
end
