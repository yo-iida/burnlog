class IssuesController < ApplicationController
  def index
    if session[:access_token]
      token = session[:access_token]
      client = Octokit::Client.new access_token: token
      client.auto_paginate = true
      @sprint_backlog_issues = client.issues(params["repo"], state: 'open', labels: 'sprint backlog')
      @in_progress_issues = client.issues(params["repo"], state: 'open', labels: 'in progress')
      @in_review_issues = client.issues(params["repo"], state: 'open', labels: 'in review')
      @closed_issues = client.issues(params["repo"], state: 'closed', since: Date.today.beginning_of_week)
    end
  end
end
