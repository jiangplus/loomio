module Events::Notify::Mentions
  def trigger!
    super
    self.notify_mentions!
  end

  # send event notifications
  def notify_mentions!
    return unless eventable.newly_mentioned_users.any?
    Events::UserMentioned.publish! eventable, user, eventable.newly_mentioned_users
  end

  private

  # remove newly_mentioned_users from those emailed by following
  def email_recipients
    super.where.not(id: eventable.newly_mentioned_users)
  end
end
