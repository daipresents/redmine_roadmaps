require 'date'
require 'common_logic'

class RoadmapsLogic

  def self.get_versions(project_id)
    
    results = []
    
    versions = Version.find(:all, :conditions => ["project_id = ?", project_id])
    if versions.nil?
      return results
    end

    versions.each do |version|

      next unless CommonLogic.is_valid_version(version.id, version.effective_date)

      vo = RoadmapsVO.new

      project = Project.find(:first, :conditions => ["id = ?", version.project_id])
      unless project.nil?
        vo.project_identifier = project.identifier
        vo.project_name = project.name
      end
      
      Rails.logger.debug "set version information"
      vo.version_id = version.id
      vo.name = version.name
      vo.description = version.description
      vo.effective_date = version.effective_date
      
      Rails.logger.debug "set closed num"
      vo.finish_num = CommonLogic.get_closed_num(version.id, 1)

      Rails.logger.debug "set unfinish_num"
      vo.unfinish_num = CommonLogic.get_closed_num(version.id, 0)

      Rails.logger.debug "set ticket num"
      vo.ticket_num = vo.finish_num + vo.unfinish_num

      Rails.logger.debug "set finish percentage"
      if vo.ticket_num != 0
        vo.finish_percentage = CommonLogic.size_round(vo.finish_num.to_f / vo.ticket_num.to_f, 2) * 100
      else
        vo.finish_percentage = 0
      end
      Rails.logger.debug "finish percentage = #{vo.finish_percentage.to_s}"

      Rails.logger.debug "set unfinish percentage"
      if vo.ticket_num != 0
        vo.unfinish_percentage = CommonLogic.size_round(vo.unfinish_num.to_f / vo.ticket_num.to_f, 2) * 100
      else
        vo.unfinish_percentage = 0
      end
      Rails.logger.debug "unfinish percentage = #{vo.unfinish_percentage.to_s}"

      Rails.logger.debug "set start date"
      vo.start_date = get_start_date(version.id)
      Rails.logger.debug "start date = #{vo.start_date.to_s}"
      Rails.logger.debug "start date = #{vo.start_date.class.to_s}"

      Rails.logger.debug "set due date"
      vo.due_date = get_due_date(version.id)
      Rails.logger.debug "due date = #{vo.due_date.to_s}"
      Rails.logger.debug "due date = #{vo.due_date.class.to_s}"
      
      Rails.logger.debug "set late"
      vo.late = get_late(vo.effective_date)

      Rails.logger.debug "set done ratio"
      vo.done_ratio = get_all_done_ratio(version.id)
      Rails.logger.debug "done ratio = #{vo.done_ratio.to_s}"

      Rails.logger.debug "set estimated hours"
      vo.estimated_hours = CommonLogic.size_round(get_estimated_hours(version.id), 2)
      Rails.logger.debug "estimated hours = #{vo.estimated_hours.to_s}"

      Rails.logger.debug "set passed hours"
      vo.passed_hours = CommonLogic.size_round(get_passed_hours(version.id), 2)
      Rails.logger.debug "passed hours = #{vo.passed_hours.to_s}"

      Rails.logger.debug "set assigned user"
      vo.assigned_users = get_assigned_users(version.id)
      
      results.push(vo)
      
    end

    return results
    
  end

  private
  def self.get_start_date(version_id)
    issues = Issue.find_by_sql([
          "select start_date from issues
            where fixed_version_id = :version_id and start_date is not NULL order by start_date asc limit 0, 1",
            {:version_id => version_id}])

    unless issues.nil?
      issues.each do |field|
        return field.start_date
      end
    end
          
    return nil
  end

  private
  def self.get_due_date(version_id)
    issues = Issue.find_by_sql([
          "select due_date from issues
            where fixed_version_id = :version_id order by due_date desc limit 0, 1",
            {:version_id => version_id}])

    unless issues.nil?
      issues.each do |field|
        return field.due_date
      end
    end
    
    return nil
  end

  private
  def self.get_all_done_ratio(version_id)
    sum = 0.0
    
    issues = Issue.find_by_sql(
      ["select sum(done_ratio) as sum from issues where fixed_version_id = :version_id",
        {:version_id => version_id}])

    unless issues.nil?
      issues.each do |field|
        sum = field.sum.to_f
      end
    end
    
    Rails.logger.debug "sum = #{sum.to_s}"
    
    count = Issue.count(:all, :conditions => ["fixed_version_id = ?", version_id])
    Rails.logger.debug "count = #{count.to_s}"
    
    if count.to_i != 0
      return CommonLogic.size_round(sum / count, 2)
    end

    return 0
    
  end

  private
  def self.get_estimated_hours(version_id)
    issues = Issue.find_by_sql(
          ["select sum(estimated_hours) as sum from issues where fixed_version_id = :version_id",
            {:version_id => version_id}])

    unless issues.nil?
      issues.each do |field|
        return field.sum.to_f
      end
    end
    
    return 0
  end

  private
  def self.get_passed_hours(version_id)
    passed_hours = 0.0
    issues = Issue.find(:all, :conditions => ["fixed_version_id = ?", version_id])
    unless issues.nil?
      issues.each do |issue|
        time_entries = TimeEntry.find_by_sql(
            ["select sum(hours) as sum from time_entries where issue_id = :issue_id",
              {:issue_id => issue.id}])
        unless time_entries.nil?
          time_entries.each do |field|
              passed_hours += field.sum.to_f
            break
          end
        end
      end
    end
    
    return passed_hours
  end
  
  private
  def self.get_late(due_date)
    if due_date
      return (due_date - Date::today).to_i
    end

    return 0
  end

  private
  def self.get_assigned_users(version_id)
    return Issue.find_by_sql(
      ["select users.id, lastname, count(*) as count from issues, users
        where issues.assigned_to_id = users.id and
          fixed_version_id = :version_id
          group by assigned_to_id order by count desc",
        {:version_id => version_id}])
  end
end
