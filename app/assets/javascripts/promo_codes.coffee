initPromocodeTimepicker = ->
   $('.promo-code-time-picker').timepicker({
    dropdown: false,
    timeFormat: 'HH:mm',
    });

initPromocodeDatepicker = ->
   $('.promo-code-date-picker').datepicker({
     format: 'yyyy-mm-dd',
    });

onClickSetEndDate = ->
  $('#set_end_date').click ->
    if $(this).is(':checked')
      $('.end-date-section').slideDown('slow')
    else
      $('.end-date-section').slideUp('slow')

onCheckLimitNumberUsage = ->
  $('#promo_code_is_usage_limit_number').click ->
    if $(this).is(':checked')
      $('.limit-number-usage').slideDown('slow')
    else
      $('.limit-number-usage').slideUp('slow')

onSelectMinimumRequirement = ->
  $("input[name='promo_code[minimum_requirements]']").click ->
    if $(this).val() == 'minimum_purchase_amount'
      $('.requirements-field').slideUp('slow')
      $('.minimum-purchase-amount-field').slideDown('slow')
    else if $(this).val() == 'minimum_quantity'
      $('.requirements-field').slideUp('slow')
      $('.minimum-quantity-field').slideDown('slow')
    else
      $('.requirements-field').slideUp('slow')

onSelectSpecificCollectionOrProducts = ->
  $("input[name='promo_code[applies_to]']").click ->
    if $(this).val() == 'specific_collections'
      $('.applies-to-field').slideUp('slow')
      $('.limit-collections-field').slideDown('slow')
    else if $(this).val() == 'specific_products'
      $('.applies-to-field').slideUp('slow')
      $('.limit-products-field').slideDown('slow')
    else
      $('.applies-to-field').slideUp('slow')

onSelectLimitCustomer = ->
  $("input[name='promo_code[customer_eligibility]']").click ->
    if $(this).val() == 'specific_groups'
      $('.customer-eligibility-field').slideUp('slow')
    else if $(this).val() == 'specific_customers'
      $('.customer-eligibility-field').slideUp('slow')
      $('.limit-person-field').slideDown('slow')
    else
      $('.customer-eligibility-field').slideUp('slow')

onSelectTypePromoCode = ->
  $("input[name='promo_code[promo_type]']").click ->
    if $(this).val() == 'fixed_amount'
      $('.fixed-amount-field').slideDown('slow')
    else
      $('.promo-type-field').slideUp('slow')

onClickGenerateCode = ->
  $('.generate-code-btn').click ->
    $.ajax
      method: "GET"
      url: '/admin/promo_codes/generate_code'
      dataType : 'json'
      success: (response) ->
        $("#promo_code_code").val(response.code)

loadSelectize = ->
  $('.limit_collections, .limit_products, .limit_person').selectize({
    create: false,
    delimiter: ',',
    closeAfterSelect: false,
  });

onSubmitPromocodeForm = ->
  $('.btn-submit-promo-code').click (e) ->
    e.preventDefault();

window.PromoCodes =
  run: ->
    $(document).ready ->
      initPromocodeTimepicker()
      initPromocodeDatepicker()
      onClickSetEndDate()
      onCheckLimitNumberUsage()
      onSelectMinimumRequirement()
      loadSelectize()
      onSelectSpecificCollectionOrProducts()
      onSelectLimitCustomer()
      onSelectTypePromoCode()
      onClickGenerateCode()
      # onSubmitPromocodeForm()