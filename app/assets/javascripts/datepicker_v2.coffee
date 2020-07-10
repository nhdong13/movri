window.ST = window.ST or {}
((module) ->
  dateAtBeginningOfDay = (date) ->
    new Date(date.getFullYear(), date.getMonth(), date.getDate(), 0, 0, 0, 0)

  pad = (num, size) ->
    s = num + ''
    while s.length < size
      s = '0' + s
    s

  getPromoCode = ->
    $('.promo-code-val').val()

  next_day = (day) ->
    new_day = day.setDate(day.getDate() + 1)
    new Date(new_day)

  # this ignores time zone

  dateToString = (date) ->
    date.getFullYear() + '-' + pad(date.getMonth() + 1, 2) + '-' + pad(date.getDate(), 2)

  ###*
     Initialize date range picker

     params:

     - `rangeContainerId`: element id
     - `endDate`: Last date that can be selected (type: Date)
     - `disabledDates`: Array of disabled dates (type: Array of Date)
  ###

  initializeFromToDatePicker = (rangeContainerId, opts) ->
    $('.input-arrival-date').datepicker
      autoclose: true
      startDate: new Date
      todayHighlight: true

    $('.input-return-date').datepicker
      daysOfWeekDisabled: '0'
      autoclose: true
      startDate: next_day(new Date)
      todayHighlight: true,

    opts = opts or {}
    disabledStartDates = opts.disabledDates or []
    disabledEndDates = disabledStartDates.map((d) ->
      clonedDate = new Date(d.getTime())
      clonedDate.setDate clonedDate.getDate() + 1
      clonedDate
    )

    $('.input-arrival-date').datepicker('input-daterange')
    $('.input-return-date').datepicker('input-daterange')
    today = dateAtBeginningOfDay(new Date)
    endDate = $('.input-return-date').datepicker('getDate')

    dateRage = $('#datepicker')
    dateLocale = dateRage.data('locale')
    $('.input-arrival-date').on 'changeDate', (e) ->
      newDate = e.dates[0]
      oneDayMore = next_day(newDate)
      endDate = $('.input-return-date').datepicker('getDate')
      if oneDayMore <= endDate
        newDate = oneDayMore
      $('#cart_deatail_arrival_date').datepicker 'hide'
      $('#cart_deatail_return_date').focus().datepicker 'show'
      $('#cart_deatail_return_date').focus().datepicker('setStartDate', oneDayMore)

    $('.input-return-date').on 'changeDate', (e) ->
      changeBookingDayUrl = "/en/change_cart_detail_booking_days.js";
      end_date = $(this).val()
      start_date = $('.input-arrival-date').val()
      $.ajax
        url: changeBookingDayUrl,
        type: "PUT",
        data:
           start_date: start_date,
           end_date: end_date,
           code: getPromoCode()
      $('.input-return-date').datepicker 'hide'

  setupForDay = (options) ->
    # disabledDates = options.blocked_dates.map((d) ->
    #   new Date(d * 1000)
    # )
    # $.fn.datepicker.dates[options.locale] = options.localized_dates

    # $.validator.addMethod 'availability_range', (value, element, params) ->
    #   startVal = $(params.startOnSelector).datepicker('getDates')
    #   endVal = $(element).datepicker('getDates')
    #   if !startVal or startVal.length != 1 or !endVal or endVal.length != 1
    #     return false
    #   startDate = startVal[0].getTime()
    #   endDate = endVal[0].getTime()
    #   # Validate that all booked dates are outside the selected range
    #   disabledDates.every (d) ->
    #     date = d.getTime()
    #     if startDate == endDate
    #       return date != startDate
    #     date < startDate or date >= endDate
    # rules = {
    #   'end_on': {
    #     availability_range: {
    #       startOnSelector: '#start-on'
    #       }
    #     }
    #   }
    # $('#booking-dates').validate rules: rules
    # endDate = new Date(options.end_date * 1000)
    initializeFromToDatePicker 'datepicker'
      # disabledDates: disabledDates
      # endDate: endDate
    return

  module.CommonDatePicker =
    setupForDay: setupForDay

  return
) window.ST