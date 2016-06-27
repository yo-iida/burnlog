class IssuesController < ApplicationController
  def index
    if session[:access_token]
      token = session[:access_token]
      client = Octokit::Client.new access_token: token
      client.auto_paginate = true

      base_day = params['base_day'] ? Date.parse(params['base_day']) : Date.today

      @sprint_backlog_issues = client.issues(params["repo"], state: 'open', labels: 'sprint backlog')
      @in_progress_issues = client.issues(params["repo"], state: 'open', labels: 'in progress')
      @in_review_issues = client.issues(params["repo"], state: 'open', labels: 'in review')
      @closed_issues = client.issues(params["repo"], state: 'closed', since: base_day.beginning_of_week)
      @closed_issues_with_point = @closed_issues.select { |i| i.labels.map(&:name).to_s.include?('point') }
    end
  end
end
