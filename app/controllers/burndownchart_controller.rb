class BurndownchartController < ApplicationController
  def index
    if session[:access_token]
      token = session[:access_token]
      client = Octokit::Client.new access_token: token
      client.auto_paginate = true

      monday = Date.today.beginning_of_week

      sprint_backlog_issues = client.issues(params["repo"], state: 'open', labels: 'sprint backlog')
      in_progress_issues = client.issues(params["repo"], state: 'open', labels: 'in progress')
      in_review_issues = client.issues(params["repo"], state: 'open', labels: 'in review')
      closed_issues = client.issues(params["repo"], state: 'closed', since: monday)
      open_issues = sprint_backlog_issues + in_progress_issues + in_review_issues

      @open_total_points = open_issues.map(&:labels).flatten.map(&:name)
        .select { |label| label.start_with?('point') }
        .map { |label| label.delete('point').to_i }
        .reduce(:+)
      @closed_total_points = closed_issues.map(&:labels).flatten.map(&:name)
        .select { |label| label.start_with?('point') }
        .map { |label| label.delete('point').to_i }
        .reduce(:+)
      @sprint_total_points = @open_total_points.to_i + @closed_total_points.to_i

      sprint = monday..(monday+4.days)

      @data_labels = sprint.map { |d| d.strftime("%Y年%m月%d日") }

      # 計画
      @dataset1 = [*0..4].map { |i| @sprint_total_points - @sprint_total_points/4.to_f*i }

      # 実績
      closed_issues_with_point =
        closed_issues
          .select { |i| i.labels.map(&:name).to_s.include?('point') }
          .map do |i|
            {
              closed_at: i.closed_at,
              point: i.labels.select { |l| l.name.start_with?('point') }.first.name.delete!('point').to_i
            }
          end
      @closed_point = sprint.map do |day|
        closed_issues_with_point
          .select { |i| i[:closed_at].try(:in_time_zone, 'Tokyo').between?(day, day.next_day) }
          .map { |i| i[:point] }
          .reduce(:+).to_i
      end
      @dataset2 = []
      performance = @sprint_total_points
      @closed_point.each do |p|
        performance = performance - p
        @dataset2 << performance
      end
    end
  end
end
