class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, :trackable, :omniauthable

  def get_burndownchart_dataset(repo, base_day)
    client = Octokit::Client.new access_token: access_token
    client.auto_paginate = true

    base_day = base_day ? Date.parse(base_day) : Date.today.beginning_of_week

    sprint_backlog_issues = client.issues(repo, state: 'open', labels: 'sprint backlog')
    in_progress_issues = client.issues(repo, state: 'open', labels: 'in progress')
    in_review_issues = client.issues(repo, state: 'open', labels: 'in review')
    closed_issues = client.issues(repo, state: 'closed', since: base_day)
    open_issues = sprint_backlog_issues + in_progress_issues + in_review_issues

    open_total_points = total_point(open_issues).to_i
    closed_total_points = total_point(closed_issues).to_i
    sprint_total_points = open_total_points + closed_total_points

    sprint = base_day..(base_day+4.days)

    data_labels = sprint.map { |d| d.strftime('%Y-%m-%d') }

    # 計画
    dataset1 = [*0..4].map { |i| sprint_total_points - sprint_total_points/4.to_f*i }

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
    closed_point =
      sprint.map do |day|
        closed_issues_with_point
          .select { |i| i[:closed_at].try(:in_time_zone, 'Tokyo').between?(day, day.next_day) }
          .map { |i| i[:point] }
          .reduce(:+).to_i
      end
    dataset2 = []
    performance = sprint_total_points
    closed_point.each do |p|
      performance = performance - p
      dataset2 << performance
    end
    dataset2.pop(slice_num)
    {
      open_total_points: open_total_points,
      closed_total_points: closed_total_points,
      data_labels: data_labels,
      dataset1: dataset1,
      dataset2: dataset2
    }
  end

  private

  def slice_num
    # 実績datasetの未確定dataを削るための基準
    Date.today.wday > 0 ? 5 - Date.today.wday : 0
  end

  def total_point(issues)
    # issuesのポイントを合計する
    issues.map(&:labels).flatten.map(&:name)
      .select { |label| label.start_with?('point') }
      .map { |label| label.delete('point').to_i }
      .reduce(:+)
  end
end
