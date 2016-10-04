require 'wunderlist'
require 'time'
require 'andand'
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
      @list_times = settings['list-times']
    end

    def blocks
      root = @wl.get 'api/v1/root'
      id = root['id']
      update_cache(root) unless up_to_date(id, root['revision'])
      cached_problems
    end

    private

    def up_to_date(id, revision)
      return false unless @cache.key? id
      return false unless @cache[id].andand[:revision] == revision
      return false unless @cache[id].andand[:expires] > Time.now
      true
    end

    def task_due_date(task, list)
      result = Time.parse(task.due_date)
      time = @list_times[list.id]
      return result if time.nil?
      h, m = time.split ':'
      result += h.to_i.hours
      result += m.to_i.minutes
      result
    end

    def task_if_problematic(list, task)
      return if task.due_date.nil?
      return if task.title.include? @ignore_tag
      due_date = task_due_date(task, list)
      return nil unless due_date < 2.days.from_now
      "[#{list.title}] #{task.title} (#{due_date.ctime})"
    end

    def update_cache_for(list)
      return if up_to_date(list.id, list.revision)
      result = list.tasks.map do |task|
        task_if_problematic list, task
      end.compact
      @cache[list.id] = {
        revision: list.revision,
        data: result,
        expires: rand(10..30).minutes.from_now
      }
    end

    def update_cache(root)
      id = root['id']
      @wl.lists.each { |list| update_cache_for list }
      @cache[id] = {
        revision: root['revision'],
        expires: rand(10..30).minutes.from_now
      }
    end

    def cached_problems
      @cache.values.map { |list| list[:data] } .flatten.compact
    end
  end
end
