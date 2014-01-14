$            = jQuery
$.validation    = {}
$.validation.fn = {}
$.fn.validation = (method, args...) ->
  $.validation.fn[method].apply(this, args)

# Utils

defaultFormat = /(\d{1,4})/g

cards = [
  {
      type: 'maestro'
      pattern: /^(5018|5020|5038|6304|6759|676[1-3])/
      format: defaultFormat
      length: [12..19]
      cvcLength: [3]
      luhn: true
  }
  {
      type: 'dinersclub'
      pattern: /^(36|38|30[0-5])/
      format: defaultFormat
      length: [14]
      cvcLength: [3]
      luhn: true
  }
  {
      type: 'laser'
      pattern: /^(6706|6771|6709)/
      format: defaultFormat
      length: [16..19]
      cvcLength: [3]
      luhn: true
  }
  {
      type: 'jcb'
      pattern: /^35/
      format: defaultFormat
      length: [16]
      cvcLength: [3]
      luhn: true
  }
  {
      type: 'unionpay'
      pattern: /^62/
      format: defaultFormat
      length: [16..19]
      cvcLength: [3]
      luhn: false
  }
  {
      type: 'discover'
      pattern: /^(6011|65|64[4-9]|622)/
      format: defaultFormat
      length: [16]
      cvcLength: [3]
      luhn: true
  }
  {
      type: 'mastercard'
      pattern: /^5[1-5]/
      format: defaultFormat
      length: [16]
      cvcLength: [3]
      luhn: true
  }
  {
      type: 'amex'
      pattern: /^3[47]/
      format: /(\d{1,4})(\d{1,6})?(\d{1,5})?/
      length: [15]
      cvcLength: [3..4]
      luhn: true
  }
  {
      type: 'visa'
      pattern: /^4/
      format: defaultFormat
      length: [13..16]
      cvcLength: [3]
      luhn: true
  }
]

cardFromNumber = (num) ->
  num = (num + '').replace(/\D/g, '')
  return card for card in cards when card.pattern.test(num)

cardFromType = (type) ->
  return card for card in cards when card.type is type

luhnCheck = (num) ->
  odd = true
  sum = 0

  digits = (num + '').split('').reverse()

  for digit in digits
    digit = parseInt(digit, 10)
    digit *= 2 if (odd = !odd)
    digit -= 9 if digit > 9
    sum += digit

  sum % 10 == 0

hasTextSelected = ($target) ->
  # If some text is selected
  return true if $target.prop('selectionStart')? and
    $target.prop('selectionStart') isnt $target.prop('selectionEnd')

  # If some text is selected in IE
  return true if document?.selection?.createRange?().text

  false

# Private

# Format Card Number

reFormatCardNumber = (e) ->
  setTimeout =>
    $target = $(e.currentTarget)
    value   = $target.val()
    value   = $.validation.formatCardNumber(value)
    $target.val(value)

formatCardNumber = (e) ->
  # Only format if input is a number
  digit = String.fromCharCode(e.which)
  return unless /^\d+$/.test(digit)

  $target = $(e.currentTarget)
  value   = $target.val()
  card    = cardFromNumber(value + digit)
  length  = (value.replace(/\D/g, '') + digit).length

  upperLength = 16
  upperLength = card.length[card.length.length - 1] if card
  return if length >= upperLength

  # Return if focus isn't at the end of the text
  return if $target.prop('selectionStart')? and
    $target.prop('selectionStart') isnt value.length

  if card && card.type is 'amex'
    # Amex cards are formatted differently
    re = /^(\d{4}|\d{4}\s\d{6})$/
  else
    re = /(?:^|\s)(\d{4})$/

  # If '4242' + 4
  if re.test(value)
    e.preventDefault()
    $target.val(value + ' ' + digit)

  # If '424' + 2
  else if re.test(value + digit)
    e.preventDefault()
    $target.val(value + digit + ' ')

formatBackCardNumber = (e) ->
  $target = $(e.currentTarget)
  value   = $target.val()

  return if e.meta

  # Return unless backspacing
  return unless e.which is 8

  # Return if focus isn't at the end of the text
  return if $target.prop('selectionStart')? and
    $target.prop('selectionStart') isnt value.length

  # Remove the trailing space
  if /\d\s$/.test(value)
    e.preventDefault()
    $target.val(value.replace(/\d\s$/, ''))
  else if /\s\d?$/.test(value)
    e.preventDefault()
    $target.val(value.replace(/\s\d?$/, ''))

# Format Expiry

formatExpiry = (e) ->
  # Only format if input is a number
  digit = String.fromCharCode(e.which)
  return unless /^\d+$/.test(digit)

  $target = $(e.currentTarget)
  val     = $target.val() + digit

  if /^\d$/.test(val) and val not in ['0', '1']
    e.preventDefault()
    $target.val("0#{val} / ")

  else if /^\d\d$/.test(val)
    e.preventDefault()
    $target.val("#{val} / ")

formatForwardExpiry = (e) ->
  digit = String.fromCharCode(e.which)
  return unless /^\d+$/.test(digit)

  $target = $(e.currentTarget)
  val     = $target.val()

  if /^\d\d$/.test(val)
    $target.val("#{val} / ")

formatForwardSlash = (e) ->
  slash = String.fromCharCode(e.which)
  return unless slash is '/'

  $target = $(e.currentTarget)
  val     = $target.val()

  if /^\d$/.test(val) and val isnt '0'
    $target.val("0#{val} / ")

formatBackExpiry = (e) ->
  # If shift+backspace is pressed
  return if e.meta

  $target = $(e.currentTarget)
  value   = $target.val()

  # Return unless backspacing
  return unless e.which is 8

  # Return if focus isn't at the end of the text
  return if $target.prop('selectionStart')? and
    $target.prop('selectionStart') isnt value.length

  # Remove the trailing space
  if /\d(\s|\/)+$/.test(value)
    e.preventDefault()
    $target.val(value.replace(/\d(\s|\/)*$/, ''))
  else if /\s\/\s?\d?$/.test(value)
    e.preventDefault()
    $target.val(value.replace(/\s\/\s?\d?$/, ''))


formatEmail = (e) ->
  # Only format if input is a number
  digit = String.fromCharCode(e.which)
  return unless /^\d+$/.test(digit)

  $target = $(e.currentTarget)
  val     = $target.val() + digit

  if /^\d$/.test(val) and val not in ['0', '1']
    e.preventDefault()
    $target.val("0#{val} @ ")

  else if /^\d\d$/.test(val)
    e.preventDefault()
    $target.val("#{val} @ ")

formatEmailForward = (e) ->
  digit = String.fromCharCode(e.which)
  return unless /^\d+$/.test(digit)

  $target = $(e.currentTarget)
  val     = $target.val()

  if /^\d\d$/.test(val)
    $target.val("#{val} @ ")

formatEmailForwardAt = (e) ->
  slash = String.fromCharCode(e.which)
  return unless slash is '@'

  $target = $(e.currentTarget)
  val     = $target.val()

  if /^\d$/.test(val) and val isnt '0'
    $target.val("0#{val} @ ")

formatEmailBack = (e) ->
  # If shift+backspace is pressed
  return if e.meta

  $target = $(e.currentTarget)
  value   = $target.val()

  # Return unless backspacing
  return unless e.which is 8

  # Return if focus isn't at the end of the text
  return if $target.prop('selectionStart')? and
    $target.prop('selectionStart') isnt value.length

  # Remove the trailing space
  if /\d(\s|@)+$/.test(value)
    e.preventDefault()
    $target.val(value.replace(/\d(\s|@)*$/, ''))
  else if /\s@\s?\d?$/.test(value)
    e.preventDefault()
    $target.val(value.replace(/\s@\s?\d?$/, ''))

#  Restrictions

restrictEmail = (e) ->
  $target = $(e.currentTarget)
  return if hasTextSelected($target)
  value = $target.val()
  return false if value.length > 254 # http://stackoverflow.com/questions/386294/what-is-the-maximum-length-of-a-valid-email-address

restrictNumeric = (e) ->
  # Key event is for a browser shortcut
  return true if e.metaKey or e.ctrlKey

  # If keycode is a space
  return false if e.which is 32

  # If keycode is a special char (WebKit)
  return true if e.which is 0

  # If char is a special char (Firefox)
  return true if e.which < 33

  input = String.fromCharCode(e.which)

  # Char is a number or a space
  !!/[\d\s]/.test(input)

restrictCardNumber = (e) ->
  $target = $(e.currentTarget)
  digit   = String.fromCharCode(e.which)
  return unless /^\d+$/.test(digit)

  return if hasTextSelected($target)

  # Restrict number of digits
  value = ($target.val() + digit).replace(/\D/g, '')
  card  = cardFromNumber(value)

  if card
    value.length <= card.length[card.length.length - 1]
  else
    # All other cards are 16 digits long
    value.length <= 16

restrictExpiryYear = (e) ->
  $target = $(e.currentTarget)
  digit   = String.fromCharCode(e.which)
  return unless /^\d+$/.test(digit)
  val = $target.val() + digit
  val.length <= 4

restrictExpiryMonth = (e) ->
  $target = $(e.currentTarget)
  digit   = String.fromCharCode(e.which)
  return unless /^\d+$/.test(digit)
  val     = $target.val() + digit
  val.length <= 2

restrictExpiry = (e) ->
  $target = $(e.currentTarget)
  digit   = String.fromCharCode(e.which)
  return unless /^\d+$/.test(digit)

  return if hasTextSelected($target)

  value = $target.val() + digit
  value = value.replace(/\D/g, '')

  return false if value.length > 6

restrictCVC = (e) ->
  $target = $(e.currentTarget)
  digit   = String.fromCharCode(e.which)
  return unless /^\d+$/.test(digit)

  val     = $target.val() + digit
  val.length <= 4

setCardType = (e) ->
  $target  = $(e.currentTarget)
  val      = $target.val()
  cardType = $.validation.cardType(val) or 'unknown'

  unless $target.hasClass(cardType)
    allTypes = (card.type for card in cards)

    $target.removeClass('unknown')
    $target.removeClass(allTypes.join(' '))

    $target.addClass(cardType)
    $target.toggleClass('identified', cardType isnt 'unknown')
    $target.trigger('validation.cardType', cardType)

# Public

# Formatting

$.validation.fn.formatEmail = ->

  @on 'focus', ->
    $(@).parent().removeClass("error")
  
  @on 'blur', ->
    if $.validation.validateEmail(@value)
      $(@).parent().removeClass("error");
    else
      $(@).parent().addClass("error");

  this

$.validation.fn.restrictSameText = ($other) ->

  @on 'focus', ->
    $(@).parent().removeClass("error")
    $other.parent().removeClass("error")
  
  @on 'blur', ->
    if $(@).val() is $other.val()
      $(@).parent().removeClass("error")
      $other.parent().removeClass("error")
    else
      $(@).parent().addClass("error");
      if $other.val() is ""
        $other.parent().addClass("error")
      else
        $other.parent().removeClass("error")
  this

$.validation.fn.formatCardCVC = ->
  @validation('restrictNumeric')
  @on('keypress', restrictCVC)
  this

$.validation.fn.formatCardExpiry = ->
  @validation('restrictNumeric')
  @on('keypress', restrictExpiry)
  @on('keypress', formatExpiry)
  @on('keypress', formatForwardSlash)
  @on('keypress', formatForwardExpiry)
  @on('keydown',  formatBackExpiry)
  this

$.validation.fn.formatCardNumber = ->
  @validation('restrictNumeric')
  @on('keypress', restrictCardNumber)
  @on('keypress', formatCardNumber)
  @on('keydown', formatBackCardNumber)
  @on('keyup', setCardType)
  @on('paste', reFormatCardNumber)
  this

$.validation.fn.formatExpiryMonth = ->
  @validation('restrictNumeric')
  @on('keypress', restrictExpiryMonth)
  this

$.validation.fn.formatExpiryYear = ->
  @validation('restrictNumeric')
  @on('keypress', restrictExpiryYear)
  this


# Restrictions

$.validation.fn.restrictNumeric = ->
  @on('keypress', restrictNumeric)
  this

# Validations

$.validation.fn.cardExpiryVal = ->
  $.validation.cardExpiryVal($(this).val())

$.validation.cardExpiryVal = (value) ->
  value = value.replace(/\s/g, '')
  [month, year] = value.split('/', 2)

  # Allow for year shortcut
  if year?.length is 2 and /^\d+$/.test(year)
    prefix = (new Date).getFullYear()
    prefix = prefix.toString()[0..1]
    year   = prefix + year

  month = parseInt(month, 10)
  year  = parseInt(year, 10)

  month: month, year: year

$.validation.validateCardNumber = (num) ->
  num = (num + '').replace(/\s+|-/g, '')
  return false unless /^\d+$/.test(num)

  card = cardFromNumber(num)
  return false unless card

  num.length in card.length and
    (card.luhn is false or luhnCheck(num))

$.validation.validateEmail = (email) =>

  return false unless email

  email = $.trim(email)
  filter = /^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/
 
  (Boolean) filter.test(email)


$.validation.validateCardExpiry = (month, year) =>
  # Allow passing an object
  if typeof month is 'object' and 'month' of month
    {month, year} = month

  return false unless month and year

  month = $.trim(month)
  year  = $.trim(year)

  return false unless /^\d+$/.test(month)
  return false unless /^\d+$/.test(year)
  return false unless parseInt(month, 10) <= 12

  if year.length is 2
    prefix = (new Date).getFullYear()
    prefix = prefix.toString()[0..1]
    year   = prefix + year

  expiry      = new Date(year, month)
  currentTime = new Date

  # Months start from 0 in JavaScript
  expiry.setMonth(expiry.getMonth() - 1)

  # The cc expires at the end of the month,
  # so we need to make the expiry the first day
  # of the month after
  expiry.setMonth(expiry.getMonth() + 1, 1)

  expiry > currentTime

$.validation.validateCardExpiryMonth = (month) =>

  return false unless month

  month = $.trim(month)

  return false unless /^\d+$/.test(month)
  return false unless parseInt(month, 10) <= 12

  currentYear = new Date().getFullYear()
  expiry      = new Date(currentYear, month)
  currentTime = new Date

  # Months start from 0 in JavaScript
  expiry.setMonth(expiry.getMonth() - 1)

  # The cc expires at the end of the month,
  # so we need to make the expiry the first day
  # of the month after
  expiry.setMonth(expiry.getMonth() + 1, 1)

  expiry > currentTime

$.validation.validateCardExpiryYear = (year) =>

  return false unless year

  year  = $.trim(year)
  return false unless /^\d+$/.test(year)

  if year.length is 2
    prefix = (new Date).getFullYear()
    prefix = prefix.toString()[0..1]
    year   = prefix + year

  year = parseInt(year, 10)

  year >= (new Date).getFullYear()
  

$.validation.validateCardCVC = (cvc, type) ->
  cvc = $.trim(cvc)
  return false unless /^\d+$/.test(cvc)

  if type
    # Check against a explicit card type
    cvc.length in cardFromType(type)?.cvcLength
  else
    # Check against all types
    cvc.length >= 3 and cvc.length <= 4

$.validation.cardType = (num) ->
  return null unless num
  cardFromNumber(num)?.type or null

$.validation.formatCardNumber = (num) ->
  card = cardFromNumber(num)
  return num unless card

  upperLength = card.length[card.length.length - 1]

  num = num.replace(/\D/g, '')
  num = num[0..upperLength]

  if card.format.global
    num.match(card.format)?.join(' ')
  else
    groups = card.format.exec(num)
    groups?.shift()
    groups?.join(' ')
