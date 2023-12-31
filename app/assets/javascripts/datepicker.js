window.ST = window.ST || {};

(function(module) {

  var dateAtBeginningOfDay = function(date) {
    return new Date(date.getFullYear(), date.getMonth(), date.getDate(), 0, 0, 0, 0);
  };

  var pad = function(num, size) {
    var s = num+"";
    while (s.length < size) s = "0" + s;
    return s;
  };

  // this ignores time zone
  var dateToString = function(date) {
    return date.getFullYear() + '-' + pad((date.getMonth() + 1), 2) + '-' +  pad(date.getDate(), 2);
  };

  var setupPerDayOrNight = function(options, current_start_date, input_arrival_date_el, input_return_date_el) {
    var disabledDates = options.blocked_dates.map(function(d) {
      return new Date(d * 1000);
    });
    var quantityNight = options.listing_quantity_selector === 'night';

    $.fn.datepicker.dates[options.locale] = options.localized_dates;

    $.validator.addMethod("night_selected",
      function(value, element, params) {
        var startVal = $(params.startOnSelector).val();
        if (!!startVal === false) {
          return true;
        } else {
          return startVal !== value;
        }
      });

    $.validator.addMethod("availability_range",
      function(value, element, params) {
        var startVal = $(params.startOnSelector).datepicker('getDates');
        var endVal = $(element).datepicker('getDates');

        if (!startVal || startVal.length !== 1 || !endVal || endVal.length !== 1) {
          return false;
        }

        var startDate = startVal[0].getTime();
        var endDate = endVal[0].getTime();

        // Validate that all booked dates are outside the selected range
        return disabledDates.every(function(d) {
          var date = d.getTime();
          if (startDate === endDate) {
            return date !== startDate;
          }
          return date < startDate || date >= endDate;
        });
      });

    var rules = quantityNight ? {
      "end_on": {
        night_selected: {startOnSelector: ".input-return-date"},
        availability_range: {startOnSelector: ".input-return-date"}
      }
    } : {
      "end_on": {
        availability_range: {startOnSelector: ".input-return-date"}
      }
    };

    $("#booking-dates").validate({
      rules: rules,
      // submitHandler: function(form) {
      //   var $form = $(form);
      //   $form.find("#start-on").attr("name", "");
      //   $form.find("#end-on").attr("name", "");
      //   form.submit();
      // }
    });

    var endDate = new Date(options.end_date * 1000);

    initializeFromToDatePicker('datepicker', {disabledDates: disabledDates, endDate: endDate, nightPicker: quantityNight, current_start_date: current_start_date, input_arrival_date_el: input_arrival_date_el, input_return_date_el: input_return_date_el });
  };

  /**
     Initialize date range picker

     params:

     - `rangeContainerId`: element id
     - `endDate`: Last date that can be selected (type: Date)
     - `disabledDates`: Array of disabled dates (type: Array of Date)
  */
  var initializeFromToDatePicker = function(rangeContainerId, opts) {
    opts = opts || {};
    var input_arrival_date_el = opts.input_arrival_date_el
    var input_return_date_el = opts.input_return_date_el
    var nightPicker = opts.nightPicker || false;
    var endDate = opts.endDate;
    var disabledStartDates = opts.disabledDates || [];
    var disabledEndDates = disabledStartDates.map(function(d) {
      var clonedDate = new Date(d.getTime());
      clonedDate.setDate(clonedDate.getDate() + 1);
      return clonedDate;
    });
    var today = dateAtBeginningOfDay(new Date());
    var dateRage = $('#'+ rangeContainerId);
    var dateLocale = dateRage.data('locale');
    var next_number_days = function(day, number){
      var new_day = day.setDate(day.getDate() + number)
      return new Date(new_day)
    }

    var current_start_date = opts.current_start_date || next_day

    $(input_arrival_date_el).datepicker({
      autoclose: true,
      startDate: today,
      todayHighlight: true,
      datesDisabled: disabledStartDates,
    });

    $(input_return_date_el).datepicker({
      daysOfWeekDisabled: '0',
      autoclose: true,
      startDate: next_number_days(new Date(current_start_date), 1),
      todayHighlight: true,
      datesDisabled: disabledStartDates,
    });


    // $('.input-arrival-date').datepicker('.input-daterange')
    // $('.input-return-date').datepicker('.input-daterange')
    today = dateAtBeginningOfDay(new Date)
    endDate = $(input_return_date_el).datepicker('getDate')

    $(input_arrival_date_el).on('changeDate', function(e){
      newDate = e.dates[0];
      oneDayMore = next_number_days(newDate, 1);
      endDate = $(input_arrival_date_el).datepicker('getDate');
      if(oneDayMore <= endDate){
        newDate = oneDayMore
      }
      $(input_return_date_el).focus().datepicker('setDate', '')
      $(input_arrival_date_el).datepicker('hide');
      $(input_return_date_el).focus().datepicker('setStartDate', newDate)
      $(input_return_date_el).focus().datepicker('show')
    });

    $(input_return_date_el).on('changeDate', function(){
      changeBookingDayUrl = "/en/change_cart_detail_booking_days.js";
      end_date = $(this).val();
      start_date = $(input_arrival_date_el).val();
      diffDays = new Date(end_date) - new Date(start_date);
      diffDaysToNumber = Math.ceil(diffDays / (1000 * 60 * 60 * 24));
      if(diffDaysToNumber > 90){
        $(input_return_date_el).focus().datepicker('setDate', '')
        alert("You cannot rent for more than 90 days")
        return;
      } else {
        if(end_date != "" && start_date != ""){
          $.ajax({
            url: changeBookingDayUrl,
            type: "PUT",
            data: {
               start_date: start_date,
               end_date: end_date,
               today: today
            }
          })
          $(input_return_date_el).datepicker('hide')
        }
      }
    });

    $('.fa-calendar, .icon-movri-calendar').click(function(){
      $(this).parent().find('input').datepicker('show')
    })

    $('.icon-return-date-calendar').click(function(){
      $('.input-return-date-mobile').datepicker('show')
    })

    $('.icon-arrival-date-calendar').click(function(){
      $('.input-arrival-date-mobile').datepicker('show')
    })

    // picker.on('changeDate', function(e) {
    //   var newDate = e.dates[0];
    //   var outputElementId = $(e.target).data("output");
    //   var outputElement = outputElements[outputElementId];

    //   if (outputElementId === "booking-end-output" && !nightPicker) {
    //     var oneDayMore = new Date(newDate);
    //     oneDayMore.setDate(oneDayMore.getDate() + 1);
    //     if (oneDayMore <= endDate) {
    //       newDate = oneDayMore;
    //     }
    //   }

    //   if (outputElementId === "booking-start-output") {
    //     $(".input-return-date").datepicker('hide')
    //     $(".input-return-date").focus().datepicker('show')
    //   }

    //   outputElement.val(module.utils.toISODate(newDate));
    //   setTimeout(function() { $(".input-return-date").valid(); }, 360);
    // });

  };

  // var setupPerHour = function(options) {
  //   var dateInput = $('.input-return-date');
  //   var disabledDates = options.blocked_dates.map(function(d) {
  //     return new Date(d * 1000);
  //   });
  //   var today = dateAtBeginningOfDay(new Date());
  //   var endDate = new Date(options.end_date * 1000);
  //   var currentDate = null;
  //   var selectOne = ST.t('listings.listing_actions.select_one');

  //   $.fn.datepicker.dates[options.locale] = options.localized_dates;

  //   var picker = dateInput.datepicker({
  //     autoclose: true,
  //     datesDisabled: disabledDates,
  //     startDate: today,
  //     endDate: endDate,
  //     language: options.locale
  //   });

  //   var validateForm = function() {
  //     $('#booking-dates').validate();
  //   };

  //   $('#start_time').on('change', function() {
  //     var selected = $(this).find('option:selected'),
  //       startTimeindex = selected.data('index'),
  //       startTimeSlot = selected.data('slot'),
  //       endTime = $('#end_time'),
  //       prevBlocked = false;
  //     if (endTime.prop('disabled') != true) {
  //       setUpSelectOptions(currentDate, false, '#end_time');
  //     }
  //     endTime.find('option').each(function () {
  //       var option = $(this), endTimeIndex = option.data('index'),
  //         endTimeSlot = option.data('slot'), blocked  = option.data('blocked'),
  //         bookingStart = option.data('bookingStart');
  //       if (endTimeIndex > startTimeindex && startTimeSlot === endTimeSlot &&
  //         (!blocked || (!prevBlocked && bookingStart))) {
  //         option.removeAttr('disabled');
  //       } else {
  //         option.prop('disabled', true);
  //       }
  //       prevBlocked = blocked;
  //     });
  //     endTime.removeAttr('disabled');
  //   });

  //   var setUpSelectOptions = function(date, start, selectSelector) {
  //     var date_options = options.options_for_select[date],
  //       options_for_select = ['<option value="" disabled selected>' + selectOne + '</option>'],
  //       prevDisabled = false,
  //       blocked = '';
  //     for(var index in date_options) {
  //       var disabled, option = date_options[index],
  //         value = date + ' ' + option.value;
  //       if (!start && option.slot_end && !prevDisabled) {
  //         disabled = '';
  //         blocked = '';
  //         if (option.next_day) {
  //           value = option.next_day + ' ' + option.value;
  //         }
  //       } else {
  //         disabled = option.disabled ? ' disabled ' : '';
  //         blocked = option.disabled ? 'true' : '';
  //       }
  //       if (!(start && option.slot_end)) {
  //         options_for_select.push('<option value="' + value + '" ' + disabled +
  //           ' data-index="' + index + '" data-slot="' + option.slot +
  //           '" data-blocked="' + blocked + '" data-booking-start="' + !!option.booking_start + '" >' + option.name + '</option>');
  //       }
  //       prevDisabled = option.disabled;
  //     }
  //     $(selectSelector).html($(options_for_select.join('')));
  //     if (!start) {
  //       $(selectSelector).prop('disabled', true);
  //     }
  //   };

  //   picker.on('changeDate', function(e) {
  //     currentDate = dateToString(e.date);
  //     setUpSelectOptions(currentDate, true, '#start_time');
  //     setUpSelectOptions(currentDate, false, '#end_time');
  //   });
  //   validateForm();
  // };

  module.FromToDatePicker = {
    setupPerDayOrNight: setupPerDayOrNight,
    // setupPerHour: setupPerHour
  };
})(window.ST);
