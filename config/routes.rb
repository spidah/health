ActionController::Routing::Routes.draw do |map|
  map.open_id_complete  'session',                :controller => 'sessions',            :action => 'create',  :requirements => {:method => :get}
  map.resource :session
  map.resource :user
  map.link_openid       'openid_links',           :controller => 'openid_links',        :action => 'create',  :requirements => {:method => :get}
  map.resources :openid_links
  map.resources :weights,                         :member     => {:destroy => :get}
  map.resources :measurements,                    :member     => {:destroy => :get}
  map.resources :targetweights,                   :controller => 'target_weights',      :member => {:destroy => :get}
  map.resources :meals, :member => {:destroy => :get} do |meal|
    meal.resources :food_items,                   :member     => {:destroy => :get}
  end
  map.resources :foods,                           :member     => {:destroy => :get}
  map.resources :exercises,                       :member     => {:destroy => :get}
  map.resources :activities,                      :member     => {:destroy => :get}
  map.resource :calendar,                         :controller => 'calendar'

  map.admin             '/admin',                 :controller => 'admin/admin',         :action => 'index'
  map.namespace(:admin) do |admin|
    admin.resources :users,                       :controller => 'admin_users',         :member => {:destroy => :get}
    admin.resources :user_logins,                 :controller => 'admin_user_logins',   :member => {:destroy => :get}
    admin.resources :news,                        :controller => 'admin_news',          :member => {:destroy => :get}
  end

  map.home              '',                       :controller => 'home',                :action => 'index'
  map.dashboard         '/dashboard',             :controller => 'users',               :action => 'index'
  map.change_date       '/calendar/changedate',   :controller => 'calendar',            :action => 'change_date'
  map.change_month      '/calendar/changemonth',  :controller => 'calendar',            :action => 'change_month'
  map.login             '/login',                 :controller => 'sessions',            :action => 'new'
  map.logout            '/logout',                :controller => 'sessions',            :action => 'destroy'
  map.signup            '/signup',                :controller => 'sessions',            :action => 'signup'
  map.news              '/news',                  :controller => 'news',                :action => 'index'
  map.news_page         '/news/page/:page',       :controller => 'news',                :action => 'index'
  map.tour              '/tour',                  :controller => 'home',                :action => 'tour'
  map.about             '/about',                 :controller => 'home',                :action => 'about'
  map.contact           '/contact',               :controller => 'home',                :action => 'contact'

  map.profile           'users/:loginname',       :controller => 'users',               :action => 'show'
  map.help              'help/:action',           :controller => 'help'

  map.connect           '',                       :controller => 'home',                :action => 'index'
  map.connect           '*path',                  :controller => 'home',                :action => 'index'
end
