desc 'notify burndownchart'
task notify: :environment do
  client = Slack::Web::Client.new
  user = User.find 1
  dataset = user.get_burndownchart_dataset(ENV['TARGET_REPO'], Date.today.beginning_of_week.strftime('%Y-%m-%d'))

  g = Gruff::Line.new
  g.title = 'Burn Down Chart'
  g.labels = Hash[*[*0..4].zip(dataset[:data_labels]).flatten]
  g.data :Plan, dataset[:dataset1]
  g.data :Result, dataset[:dataset2]
  g.theme_pastel
  filename = "#{Time.current.strftime('%Y%m%d%H%M%S')}.png"
  filepath = Rails.root.join('tmp',filename)
  g.write(filepath)

comment =<<EOS
今日のバーンダウン

今日の消化ポイント: #{dataset[:dataset2][-2].to_i - dataset[:dataset2][-1].to_i}

残りポイント合計: #{dataset[:open_total_points]}
消化ポイント合計: #{dataset[:closed_total_points]}
EOS

  client.files_upload(
    channels: ENV['TARGET_CHANNEL'],
    as_user: true,
    file: Faraday::UploadIO.new(filepath.to_s, 'image/png'),
    title: 'BurnDownChart',
    filename: filename,
    initial_comment: comment
  )

  File.unlink filepath
end
