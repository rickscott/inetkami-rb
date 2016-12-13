require 'twitter'
require 'parseconfig'
require 'yaml/store'

# wire up configfile and state database
configfile = ParseConfig.new('inetkami.cfg')
db = YAML::Store.new('inetkami.yaml')

last_mention = 0
last_dm      = 0

db.transaction do
    last_mention = db[:last_mention] || 1
    last_dm      = db[:last_dm]      || 1
end

# load & register plugins
Dir["plugins/*.rb"].each {|file| require_relative file }


# plugin_for: command => [plugins to handle it]
plugin_for = Hash.new([])

ObjectSpace.each_object(Class).each do |k|
    if k.name =~ /^InetkamiPlugin::/
        plugin = k.new

        plugin.commands.each do |cmd|
            plugin_for[cmd] += [plugin]
        end
    end
end


### wire up the twitter connection
twitter = Twitter::REST::Client.new do |c|
  c.consumer_key        = configfile['consumer_key']
  c.consumer_secret     = configfile['consumer_secret']
  c.access_token        = configfile['access_token']
  c.access_token_secret = configfile['access_token_secret']
end


# TODO: splitting on word boundaries would be more graceful.
#       and first pri there should be on newlines =)
# cases:
#   1) the whole reply fits in one message
#   2) there is more to follow ⏩
#   3) this is the last follow-on message ⏭

def section_to_140(username, text)
    target_length = 140 - (username.length + 3)  # username + @ + space + mebbe ⏩

    tmpstring = text
    messages = []

    while tmpstring.size > 0
        messages.push(tmpstring.slice!(0,target_length))
    end

    messages.map do |m|
        "@#{username} #{m}"
    end
end



# forever:
while true

    mentions = twitter.mentions_timeline(
        since_id: last_mention, count: 1
    )

    # nb: mentions arrive newest-first, with ordering not guaranteed
    # but we want to process them in order of ascending id
    mentions.sort_by! { |m| m.id }

    mentions.each do |m|
        puts "#{m.id} => #{m.full_text}"

        # write down that we've handled this mention --
        # do this _before_ replying to avoid "getting stuck"
        # on problematic commands
        db.transaction { db[:last_mention] = m.id }
        last_mention = m.id

        # mention format: @our_username <command> [args]
        (us, command, args) = m.full_text.split(' ')

        # call out to whatever plugins are interested in that command
        # and get back some number of replies
        replies = plugin_for[command].map do |p|
            p.run(command, args)
        end

        replies.flatten!

        replies.each do |r|
            msgs = section_to_140(m.user.name, r)

            msgs.each do |u|
                twitter.update(u, in_reply_to_status: m)
            end
        end

        # TODO: handle the case where updates are not unique

    end

    # TODO do all the same for DMs

    sleep configfile['fetch_delay'].to_i
end
