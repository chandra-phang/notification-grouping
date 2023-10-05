# frozen_string_literal: true

require 'json'
require 'date'
require 'logger'

require './error'
require './helper'
require './logging'

# NotificationService will manage notifications process
class NotificationService
  include Logging

  def initialize
    @notifications = {}
  end

  NOTIFICATION_TYPE = {
    1 => 'post_answer',
    2 => 'post_comment',
    3 => 'upvote_answer',
    4 => 'answer_audience',
    5 => 'comment_audience'
  }.freeze

  MESSAGE_TEMPLATE = {
    1 => '%s answered a question',
    2 => '%s commented on a question',
    3 => '%s upvoted your answer',
    4 => '%s also answered in same question',
    5 => '%s also commented in same answer'
  }.freeze

  def getNotificationsForUser(parsed_data, user_id)
    parsed_data.each do |entry|
      # only process notifications which relevant to user_id inputted
      next if entry.user_id == entry.sender_id
      next if entry.user_id != user_id

      unless NOTIFICATION_TYPE[entry.notification_type_id]
        error = format(ERROR['invalid_notification_type'], entry.notification_type_id)
        print_error(error)
        next
      end

      unless MESSAGE_TEMPLATE[entry.notification_type_id]
        error = format(ERROR['message_not_found'], entry.notification_type_id)
        print_error(error)
        next
      end

      notif = create_or_merge_notif(
        receiver_id: entry.user_id,
        sender_id: entry.sender_id,
        target_id: entry.target_id,
        target_type: entry.target_type,
        notification_type_id: entry.notification_type_id,
        created_at: entry.created_at
      )

      create_audience_notification(notif)
    end

    @notifications.each do |_, notif|
      # comment out next if below if want to see all audience notifications
      next if notif[:receiver_id] != user_id

      template = MESSAGE_TEMPLATE[notif[:notification_type_id]]
      actors = merge_actors(notif[:actor_ids])
      message = format(template, actors)

      print_notif(notif[:receiver_id], message, notif[:created_at])
    end
  end

  private

  def print_notif(receiver, message, created_at)
    puts "[#{format_datetime(created_at)}] Receiver: #{receiver}, Message: #{message}"
  end

  def create_or_merge_notif(entry = {})
    created_at = entry[:created_at].is_a?(Time) ? entry[:created_at] : unix_to_datetime(entry[:created_at])
    notif_id = generate_id(entry[:receiver_id], entry[:target_id], entry[:notification_type_id])

    # merge notifications with same user_id, notification_type_id and target_id
    if @notifications[notif_id]
      @notifications[notif_id][:trigger_id] = entry[:sender_id]
      @notifications[notif_id][:actor_ids] << entry[:sender_id]
      @notifications[notif_id][:actor_ids].uniq!
      @notifications[notif_id][:created_at] = created_at
    else
      @notifications[notif_id] = {
        receiver_id: entry[:receiver_id],
        target_id: entry[:target_id],
        target_type: entry[:target_type],
        trigger_id: entry[:sender_id],
        actor_ids: [entry[:sender_id]],
        notification_type_id: entry[:notification_type_id],
        created_at: created_at
      }
    end

    @notifications[notif_id]
  end

  def create_audience_notification(notif)
    # no need to create audience notification for upvote
    return if notif[:actor_ids].length < 2

    case notif[:notification_type_id]
    when 1
      audience_notification_type_id = 4
    when 2
      audience_notification_type_id = 5
    when 3
      return
    end

    audience = notif[:actor_ids] - [notif[:trigger_id]]
    audience.each do |receiver_id|
      create_or_merge_notif(
        receiver_id: receiver_id,
        sender_id: notif[:trigger_id],
        target_id: notif[:target_id],
        notification_type_id: audience_notification_type_id,
        created_at: notif[:created_at]
      )
    end
  end

  def print_error(error)
    logger.error(error)
    puts error
  end

  def generate_id(receiver_id, target_id, notification_type_id)
    "#{receiver_id}_#{target_id}_#{notification_type_id}"
  end

  def merge_actors(actors)
    if actors.length > 2
      others_count = actors.length - 2
      "#{actors[-1]}, #{actors[-2]} and #{others_count} others"
    else
      actors.join(', and ')
    end
  end
end

# Application is class to initialize the program
class Application
  attr_reader :tricks

  include Logging

  def initialize(options = {})
    params = options[:params]
    if params.size < 2
      err_message = ERROR['invalid_params']
      logger.error(err_message)
      raise err_message
    else
      @file_name = params[0]
      @user_id = params[1]
    end
  end

  def run!
    begin
      notif_service = NotificationService.new
      notif_service.getNotificationsForUser(parsed_data, @user_id)
    rescue StandardError => e
      logger.error e.message
      logger.error e.backtrace.join("\n")
      puts "Error: #{e.message}"
    end

    logger.info('Shutting down application...')
  end

  def parsed_data
    file = File.read(@file_name)
    parsed_data = JSON.parse(file, object_class: OpenStruct)
    parsed_data.sort_by(&:created_at)
  end
end

app = Application.new(params: ARGV)
app.run!
