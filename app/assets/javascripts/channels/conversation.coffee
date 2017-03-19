App.conversation = App.cable.subscriptions.create "ConversationChannel",
  connected: ->
    # Called when the subscription is ready for use on the server
    if window.location.pathname == '/chat'
      App.conversation.egress()

  disconnected: ->
    # Called when the subscription has been terminated by the server
    reset_conversation()

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    enable_chat(data)
    place_message(data)
    place_links(data)
    place_topic(data)
    show_typing(data)
    color_my_nickname()
    back_in_waiting_pool(data)
    # console.log data

  message: (str) ->
    @perform 'message', message: str

  typing: ->
    @perform 'typing'

  egress: (get_next = true) ->
    @perform 'egress', get_next: get_next

  next_topic: () ->
    @perform 'next_topic', current_topic: $('#chat-topic').html()

# manipulating the dom

nickname = () ->
  $('#chat-instructions').data('nickname')

submit_message = () ->
  $('#chat-message').on 'keydown', (event) ->
    if event.keyCode == 13 && !event.shiftKey
      str = event.target.value
      # console.log "Submitted string: #{str}"

      blank_regex = /^\s*$/g
      unless blank_regex.test str
        App.conversation.message str

      event.target.value = ""
      event.preventDefault()

scroll_bottom = (sel) ->
  $(sel).scrollTop($(sel)[0].scrollHeight)

reset_conversation = () ->
  $('#chat-history').html('')
  $('#links-shared li').not('.none-yet').remove()
  $('.none-yet').removeClass('hide')
  $('#chat-message').val('')
  $('#typing-indicator').html('')
  $('#chat-topic').html('Waiting for a topic...')
  disable_chat()

disable_chat = () ->
  disable_next()
  disable_messages()
  stop_timer()
  $('#chat-loading').removeClass('hide')

enable_chat = (data) ->
  enable_next()
  enable_messages()
  start_timer()
  $('#chat-loading').addClass('hide')
  $('#chat-message').focus()

disable_next = () ->
  $('#chat-next').addClass('disabled')
  $('#chat-next').attr('disabled', true)
  $('#topic-next').addClass('disabled')
  $('#topic-next').attr('disabled', true)

enable_next = () ->
  $('#chat-next').removeClass('disabled')
  $('#chat-next').attr('disabled', false)
  $('#topic-next').removeClass('disabled')
  $('#topic-next').attr('disabled', false)

disable_messages = () ->
  $('#chat-message').attr('disabled', true)

enable_messages = () ->
  $('#chat-message').attr('disabled', false)

setup_chat_next = () ->
  $('#chat-next').click (e) ->
    if confirm("Are you sure you want to leave this conversation?")
      App.conversation.egress()
      reset_conversation()
      e.preventDefault()
    $('#chat-message').focus()
  $('#topic-next').click (e) ->
    App.conversation.next_topic()
    e.preventDefault()
    $('#chat-message').focus()

add_link = (partial) ->
  # assumes that it's an 'li a'
  $('.none-yet').addClass('hide')
  $('#links-shared').append("<li>" + partial + "</li>")

add_message = (partial) ->
  # assumes that it's a 'div'
  $('#chat-history').append(partial)
  scroll_bottom('#chat-container')

color_my_nickname = () ->
  $('span.label[data-nickname=\'' + nickname() + '\']').addClass("alert")

place_message = (data) ->
  if data.message
    add_message data.message
    $('#typing-indicator').html('')

    if not document.hasFocus()
      # https://developer.mozilla.org/en-US/docs/Web/API/Document/hasFocus
      $('#chat-beep')[0].play()
      # console.log "Plays sound"

place_links = (data) ->
  if data.message
    for link in $(data.message).find('a')
      add_link(link.outerHTML)
    scroll_bottom('#links-container')

place_topic = (data) ->
  if data.topic
    $('#chat-topic').html(data.topic)

back_in_waiting_pool = (data) ->
  if data.waiting_pool
    reset_conversation()

#######################
#  Typing Indicator   #
#######################

typing_interval = 1000
send_typing_indicator = () ->
  past_val = ""
  setInterval () ->
    current_val = $('#chat-message').val()
    if current_val && (past_val != current_val) && (current_val != "")
      past_val = current_val
      # console.log "typing"
      App.conversation.typing()
  , typing_interval

typing_indicator = 0
show_typing = (data) ->
  if data.typing
    $('#typing-indicator').html(data.nickname + " is typing ...")
    clearTimeout(typing_indicator)
    typing_indicator = setTimeout () ->
      $('#typing-indicator').html('')
    , typing_interval

#######################
# Timer Functionality #
#######################

timer_interval = 0
chat_time = 0

start_timer = () ->
  if chat_time == 0
    # console.log "start timer"
    timer_interval = setInterval () ->
      chat_time += 1
      print_time()
    , 1000

stop_timer = () ->
  # console.log "stop timer"
  clearInterval(timer_interval)
  chat_time = 0
  print_time()

print_time = () ->
  $('#chat-time').html(time_string(chat_time))

time_string = (seconds) ->
  final_seconds = seconds % 60
  minutes = Math.floor(seconds / 60)
  final_minutes = minutes % 60
  final_hours = Math.floor(minutes / 60)

  temp = ensure_two_chars(final_minutes) + ":" + ensure_two_chars(final_seconds)

  if final_hours > 0
    final_hours + ":" + temp
  else
    temp

ensure_two_chars = (num) ->
  temp = num + ""
  if temp.length < 2
    "0" + temp
  else
    temp

$(document).on 'turbolinks:load', ->
  submit_message()
  reset_conversation()
  setup_chat_next()
  send_typing_indicator()

  if window.location.pathname == '/chat'
    $("a[target!='_window']").click ->
      App.conversation.egress(false)
