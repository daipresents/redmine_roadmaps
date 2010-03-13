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
    unless versions.nil?
      @results.concat(versions)
    end

    logger.debug("parent versions results = #{@results.size.to_s}")

    # 子プロジェクト
    logger.debug("get versions from child project.")
    projects = Project.find(:all, :conditions => ["parent_id = ?", @project.id])
    unless projects.nil?
      projects.each do |child_project|
        versions = RoadmapsLogic.get_versions(child_project.id)
        if versions
          @results.concat(versions)
        end
      end
    end

    @results = @results.sort{|aa, bb|
      aa.name <=> bb.name
    }

    logger.debug("child versions results = #{@results.size.to_s}")
    
  end

  def init
    @project_id = params[:project_id]
    @project = Project.find(@project_id)
  end
end
