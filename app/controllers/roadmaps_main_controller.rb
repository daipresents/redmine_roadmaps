require 'roadmaps_logic'
require 'roadmaps_v_o'

class RoadmapsMainController < ApplicationController
  unloadable
  before_filter :init
  
  def index

    @results = []
    
    # 親プロジェクト
    logger.debug("get versions from parent project.")
    versions = RoadmapsLogic.get_versions(@project.id)
    if versions
      @results.concat(versions)
    end

    logger.debug("parent versions results = #{@results.size.to_s}")

    # 子プロジェクト
    logger.debug("get versions from child project.")
    Project.find(:all, :conditions => ["parent_id = ?", @project.id]).each do |child_project|
      versions = RoadmapsLogic.get_versions(child_project.id)
      if versions
        @results.concat(versions)
      end
    end

    logger.debug("child versions results = #{@results.size.to_s}")
    
  end

  def init
    @project_id = params[:project_id]
    @project = Project.find(@project_id)
  end
end
