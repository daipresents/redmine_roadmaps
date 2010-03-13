require 'redmine'

Redmine::Plugin.register :redmine_roadmaps do
  name 'Redmine Roadmaps plugin'
  author 'Dai Fujihara'
  description 'This is a plugin for Redmine'
  url 'http://daipresents.com/weblog/fujihalab/archives/2009/03/redmine-roadmaps-plugin.php'
  author_url 'http://daipresents.com/weblog/fujihalab/'

  requires_redmine :version_or_higher => '0.9.0'
  version '0.4.2'

  #permission :roadmaps, {:roadmaps_main => [:index]}, :public => true
  #permission :view_roadmaps, :roadmaps_main => :index
  project_module :roadmaps do
    permission :view_roadmaps, :roadmaps_main => :index
  end

  menu :project_menu, :roadmaps, { :controller => 'roadmaps_main', :action => 'index' },
  :caption => :roadmaps_name, :after => :roadmap, :param => :project_id
end
