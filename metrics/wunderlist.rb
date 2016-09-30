require 'wunderlist'
require 'time'
require 'active_support/core_ext/numeric/time'

OGWunderlist = Wunderlist

module Metrics
  # Check if Wunderlist reports no upcoming tasks due.
  class Wunderlist
    def initialize(settings)
      @cache = {}
      @wl = OGWunderlist::API.new(
        access_token: settings['access-token'],
        client_id: settings['client-id']
      )
      @ignore_tag = settings['ignore-tag']
    end

    def blocks
      root = @wl.get 'api/v1/root'
      id = root['id']
      unless cache_revision(id) == root['revision'] &&
             Time.now < @cache[id][:expires]
        update_cache(root)
      end
      cached_problems
    end

    private

    def cache_revision(id)
      @cache[id].andand[:revision]
    end

    def task_if_problematic(list, task)
      return if task.due_date.nil?
      return if task.title.include? @ignore_tag
      due_date = Time.parse(task.due_date)
      "[#{list.title}] #{task.title}" if due_date < 1.5.days.from_now
    end

    def update_cache_for(list)
      return if cache_revision(list.id) == list.revision
      result = list.tasks.map do |task|
        task_if_problematic list, task
      end.compact
      @cache[list.id] = { revision: list.revision, data: result }
    end

    def update_cache(root)
      id = root['id']
      @wl.lists.each { |list| update_cache_for list }
      @cache[id] = { revision: root['revision'], expires: 30.minutes.from_now }
    end

    def cached_problems
      @cache.values.map { |list| list[:data] } .flatten.compact
    end
  end
end
