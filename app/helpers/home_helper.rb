module HomeHelper
  def thumbnail_image(filename)
    directory = "/images/tour/"
    thumb = "#{directory}thumb-#{filename}"
    filename = "#{directory}#{filename}"

    content_tag(:div, link_to(image_tag(thumb), filename, :rel => "thumbnail"), :class => "image")
  end
end
