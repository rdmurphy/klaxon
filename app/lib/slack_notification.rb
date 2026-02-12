class SlackNotification
  def self.perform(url, payload)
    unless Rails.env.production?
      puts "[dev] Skipping Slack notification to #{url}: #{payload.to_json}"
      return true
    end

    json = payload.to_json
    request = HTTParty.post(url, body: json, headers: { "Content-Type" => "application/json" })
    if request.code == 200
      request.body
    else
      puts "Error sending webhook to url=#{url} for payload=#{payload.to_json}"

      false
    end
  end
end
