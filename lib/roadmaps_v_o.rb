# To change this template, choose Tools | Templates
# and open the template in the editor.

class RoadmapsVO
  def initialize

    @project_identifier = nil
    @project_name = nil

    @version_id = nil
    @name = nil
    @description = nil
    @effective_date = nil
    
    @ticket_num = 0
    @finish_num = 0
    @unfinish_num = 0

    @finish_percentage = 0.00
    @unfinish_percentage = 0.00
    @done_ratio = 0.00
    
    @estimated_hours = 0.00
    @passed_hours = 0.00

    @start_date = nil
    @due_date = nil
    @late = 0

    @assigned_users = nil
  end

  attr_accessor :version_id, :project_identifier, :project_name, :name, :description, :effective_date, :ticket_num, :finish_num, :unfinish_num,
    :finish_percentage, :unfinish_percentage, :done_ratio, :estimated_hours, :passed_hours,
    :start_date, :due_date, :late, :assigned_users
end
