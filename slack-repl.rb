require 'rubygems'
require 'bundler/setup'
require 'json'
require 'open3'
require 'cgi'
Bundler.require

TOKEN = ARGV[0]

PLAYPEN_ARGS = ["playpen",
                "sandbox",
                "--tasks-max=1",
                "--mount-proc",
                "--syscalls-file=whitelist",
                "--memory-limit=128",
                "--timeout=5",
                "--learn",
                "--user=repl",
                "--"]

# Connect to Slack
url = SlackRTM.get_url token: TOKEN
client = SlackRTM::Client.new websocket_url: url

puts "[#{Time.now}] Connected to Slack!"

# Listen for new messages (events of type "message")
client.on :message do |data|
  if data['type'] === 'message' and !data['text'].nil? and data['subtype'].nil? and data['reply_to'].nil?
    text_parts = data['text'].split(' ')
    lang = text_parts.second
    text = CGI.unescapeHTML(text_parts.drop(2).join(' '))

    if text_parts.first == "#run"
      case lang
      when "ruby"
        stdout, stderr, status = Open3.capture3(*PLAYPEN_ARGS,
                                                "ruby", "-e", text)
      when "python"
        stdout, stderr, status = Open3.capture3(*PLAYPEN_ARGS,
                                                "python", "-c", text)
      when "hs", "haskell"
        stdout, stderr, status = Open3.capture3(*PLAYPEN_ARGS,
                                                "ghc", "-e", text)
      when "rust"
        stdout, stderr, status = Open3.capture3(*PLAYPEN_ARGS,
                                                "rusti", "-e", text)
      when "scheme", "racket"
        stdout, stderr, status = Open3.capture3(*PLAYPEN_ARGS,
                                                "racket", "--eval", text)
      when "sh", "bash"
        stdout, stderr, status = Open3.capture3(*PLAYPEN_ARGS,
                                                "sh", "-c", text)
      when "bf", "brainfuck"
        stdout, stderr, status = Open3.capture3(*PLAYPEN_ARGS,
                                                "brainfuck", "--eval", text)
      end

      if status.success?
        result = "Done:\n ```\n#{stdout + stderr}\n```"
      else
        result = "Failed: #{stderr}"
      end
      client.send({ type: 'message', channel: data['channel'], text: result })
    end
  end
end

# Runs forever until an exception happens or the process is stopped/killed

client.main_loop
assert false
