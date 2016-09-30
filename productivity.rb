# Detect productivity
module Productivity
  require 'wunderlist'
  require 'yaml'
  require 'time'
  require 'active_support/core_ext/numeric/time'

  @cache = {}

  private_class_method def self.cache_revision(id)
    @cache[id].andand[:revision]
  end

  private_class_method def self.task_if_problematic(list, task)
    return if task.due_date.nil?
    due_date = Time.parse(task.due_date)
    three_half_days_from_now = 1.5.days.from_now
    "[#{list.title}] #{task.title}" if due_date < three_half_days_from_now
  end

  private_class_method def self.update_cache_for(list)
    unless cache_revision(list.id) == list.revision
      result = list.tasks.map do |task|
        task_if_problematic list, task
      end.compact
      @cache[list.id] = { revision: list.revision, data: result }
    end
  end

  private_class_method def self.update_cache(wl, root)
    id = root['id']
    wl.lists.each { |list| update_cache_for list }
    @cache[id] = { revision: root['revision'], expires: 1.hour.from_now }
  end

  private_class_method def self.cached_problems
    @cache.values.map { |list| list[:data] } .flatten.compact
  end

  private_class_method def self.problems(wl)
    root = wl.get 'api/v1/root'
    id = root['id']
    unless cache_revision(id) == root['revision'] &&
           Time.now < @cache[id][:expires]
      update_cache(wl, root)
    end
    cached_problems
  end

  # Returns a list of pending tasks for the next day and a half
  def self.blocks
    secrets = YAML.load_file('secrets.yml')

    wl = Wunderlist::API.new(
      access_token: secrets['access-token'],
      client_id: secrets['client-id']
    )

    problems wl
  end
end
