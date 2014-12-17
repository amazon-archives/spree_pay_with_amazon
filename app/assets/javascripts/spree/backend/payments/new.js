/*##
# Amazon Payments - Login and Pay for Spree Commerce
#
# @category    Amazon
# @package     Amazon_Payments
# @copyright   Copyright (c) 2014 Amazon.com
# @license     http://opensource.org/licenses/Apache-2.0  Apache License, Version 2.0
#
##*/
// Pull in file to fix https://github.com/spree/spree/commit/66446eaa8b5726690c3a6933a354be9650660fa2

//= require jquery.payment
$(document).ready(function() {
  if ($("#new_payment").is("*")) {
    $(".cardNumber").payment('formatCardNumber');
    $(".cardExpiry").payment('formatCardExpiry');
    $(".cardCode").payment('formatCardCVC');

    $(".cardNumber").change(function() {
      $(".ccType").val($.payment.cardType(this.value))
    })

    $('.payment_methods_radios').click(
      function() {
        $('.payment-methods').hide();
        $('.payment-methods input').prop('disabled', true);
        if (this.checked) {
          $('#payment_method_' + this.value + ' input').prop('disabled', false);
          $('#payment_method_' + this.value).show();
        }
      }
    );

    $('.payment_methods_radios').each(
      function() {
        if (this.checked) {
          $('#payment_method_' + this.value + ' input').prop('disabled', false);
          $('#payment_method_' + this.value).show();
        } else {
          $('#payment_method_' + this.value).hide();
          $('#payment_method_' + this.value + ' input').prop('disabled', true);
        }

        if ($("#card_new" + this.value).is("*")) {
          $("#card_new" + this.value).radioControlsVisibilityOfElement('#card_form' + this.value);
        }
      }
    );

    $('.cvvLink').click(function(event){
      window_name = 'cvv_info';
      window_options = 'left=20,top=20,width=500,height=500,toolbar=0,resizable=0,scrollbars=1';
      window.open($(this).prop('href'), window_name, window_options);
      event.preventDefault();
    });

    $('select.jump_menu').change(function(){
      window.location = this.options[this.selectedIndex].value;
    });
  }
});
