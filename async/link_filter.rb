class LinkFilter
  include Sidekiq::Worker

  def perform(email_link_id)
    begin
      states = Aws::States::Client.new
      json_hsh = {id: email_link_id}

      states.start_execution({
        state_machine_arn: ENV['AWS_STEP_FUNCTION_LINK_PROCESSING_ARN'],
        input: "#{json_hsh.to_json}",
      })

      el = EmailLink.find(email_link_id)
      el.check_and_reject
    rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
      Bugsnag.notify(e)
      puts "[ERROR] LinkFilter can not find #{email_link_id}"
      return true
    end

  end
end
