module ActivitiesHelper
  def sort_link(title, action)
    direction = nil
    if action == params[:sort]
      direction = params[:dir] == 'down' ? nil : 'down'        
    end
    link_to(title, activities_path(:sort => action, :dir => direction), :class => 'sort-header')
  end
end
