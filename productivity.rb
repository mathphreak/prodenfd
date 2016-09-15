module Productivity
  require 'wunderlist'
  require 'yaml'
  require 'time'

  def Productivity.blocks
    secrets = YAML.load_file('secrets.yml')

    wl = Wunderlist::API.new({
      :access_token => secrets['access-token'],
      :client_id => secrets['client-id']
    })

    wl.lists.map do |list|
      list.tasks.map do |task|
        unless task.due_date == nil
          due_date = Time.parse(task.due_date)
          three_half_days_from_now = Time.new + (3 * 12 * 60 * 60)
          "[#{list.title}] #{task.title}" if due_date < three_half_days_from_now
        end
      end.compact
    end.flatten.compact
  end
end
