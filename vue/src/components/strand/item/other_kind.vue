<script lang="coffee">
import { eventHeadline, eventTitle, eventPollType } from '@/shared/helpers/helptext'
import Records        from '@/shared/services/records'

export default
  props:
    event: Object
    eventable: Object

  computed:
    headline: ->
      actor = @event.actor()
      @$t eventHeadline(@event, true ), # useNesting
        author:   actor.nameWithTitle(@eventable.group())
        username: actor.username
        key:      @event.model().key
        title:    eventTitle(@event)
        polltype: @$t(eventPollType(@event)).toLowerCase()
</script>

<template lang="pug">
.strand-other-kind
  span.text--secondary(v-html='headline')
  formatted-text.thread-item__body(:model="eventable" column="statement")
</template>
