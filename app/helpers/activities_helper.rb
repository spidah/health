module ActivitiesHelper
  def sort_link(title, action)
    direction = params[:dir] == 'down' ? nil : 'down' if action == params[:sort]
    link_to(title, activities_url(:sort => action, :dir => direction), :class => 'sort-header')
  end
end
