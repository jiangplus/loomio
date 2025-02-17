class StanceService
  def self.create(stance:, actor:)
    actor.ability.authorize!(:vote_in, stance.poll)

    stance.participant = actor
    stance.cast_at ||= Time.zone.now
    stance.revoked_at = nil
    stance.save!
    stance.poll.update_counts!

    event = Events::StanceCreated.publish!(stance)
    event
  end

  def self.update(stance:, actor:, params: )
    actor.ability.authorize!(:update, stance)
    stance.stance_choices = []
    stance.assign_attributes_and_files(params)
    is_update = !!stance.cast_at
    stance.cast_at ||= Time.zone.now
    stance.revoked_at = nil
    stance.save!
    stance.poll.update_counts!

    if is_update
      Events::StanceUpdated.publish!(stance)
    else
      Events::StanceCreated.publish!(stance)
    end
  end

  def self.redeem(stance:, actor:)
    actor.ability.authorize! :redeem, stance
    return if Stance.where(participant_id: actor.id, poll_id: stance.poll_id, latest: true).exists?
    stance.update(participant: actor, accepted_at: Time.zone.now)
  end

  # def self.destroy(stance:, actor:)
  #   actor.ability.authorize! :destroy, stance
  #   stance.destroy
  #   EventBus.broadcast 'stance_destroy', stance, actor
  # end
end
