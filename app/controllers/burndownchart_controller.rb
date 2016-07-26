class BurndownchartController < ApplicationController
  def index
    if current_user
      client = Octokit::Client.new access_token: current_user.access_token
      client.auto_paginate = true

      dataset = current_user.get_burndownchart_dataset(params['repo'], params['base_day'])

      @open_total_points = dataset[:open_total_points]
      @closed_total_points = dataset[:closed_total_points]
      @data_labels = dataset[:data_labels]
      @dataset1 = dataset[:dataset1]
      @dataset2 = dataset[:dataset2]
    end
  end
end
