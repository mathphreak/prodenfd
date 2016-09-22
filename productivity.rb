# Detect productivity
module Productivity
  require 'wunderlist'
  require 'yaml'
  require 'time'

  def task_if_problematic(task)
    return if task.due_date.nil?
    due_date = Time.parse(task.due_date)
    three_half_days_from_now = Time.new + (3 * 12 * 60 * 60)
    "[#{list.title}] #{task.title}" if due_date < three_half_days_from_now
  end

  def problems_from(lists)
    lists.map do |list|
      list.tasks.map do |task|
        task_if_problematic task
      end.compact
    end.flatten.compact
  end

  # Returns a list of pending tasks for the next day and a half
  def self.blocks
    secrets = YAML.load_file('secrets.yml')

    wl = Wunderlist::API.new(
      access_token: secrets['access-token'],
      client_id: secrets['client-id']
    )

    problems_from wl.lists
  end
end
