<script lang="coffee">
import Records  from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import Flash   from '@/shared/services/flash'
import { head, filter, map, sortBy, isEqual } from 'lodash'

export default
  props:
    stance: Object

  data: ->
    pollOptions: []
    stanceChoices: []

  created: ->
    @watchRecords
      collections: ['pollOptions']
      query: (records) =>
        if @stance.poll().optionsDiffer(@pollOptions)
          @pollOptions = @poll.pollOptionsForVoting()
          @stanceChoices = map @pollOptions, (option) =>
            score: @stance.scoreFor(option)
            option: option
  methods:
    submit: ->
      @stance.stanceChoicesAttributes = map @stanceChoices, (choice) =>
        poll_option_id: choice.option.id
        score: choice.score
      actionName = if !@stance.castAt then 'created' else 'updated'
      @stance.save()
      .then =>
        Flash.success "poll_#{@stance.poll().pollType}_vote_form.stance_#{actionName}"
        EventBus.$emit "closeModal"
      .catch => true

  computed:
    poll: -> @stance.poll()
</script>

<template lang='pug'>
form.poll-score-vote-form(@submit.prevent='submit()')
  .poll-score-vote-form__options
    .poll-score-vote-form__option(v-for='choice in stanceChoices', :key='choice.option.id')
      v-subheader.poll-score-vote-form__option-label {{ choice.option.name }}
      v-slider.poll-score-vote-form__score-slider(
        :disabled="!poll.isVotable()"
        v-model='choice.score'
        :color="choice.option.color"
        :thumb-color="choice.option.color"
        :track-color="choice.option.color"
        :height="4"
        :thumb-size="24"
        :thumb-label="(choice.score > 0) ? 'always' : true"
        :min="poll.minScore"
        :max="poll.maxScore"
      )
  validation-errors(:subject='stance', field='stanceChoices')
  poll-common-stance-reason(:stance='stance', :poll='poll')
  v-card-actions.poll-common-form-actions
    v-btn.poll-common-vote-form__submit(
      block
      :disabled="!poll.isVotable()"
      :loading="stance.processing"
      color="primary"
      type='submit'
    )
      span(v-t="'poll_common.submit_vote'")
</template>
