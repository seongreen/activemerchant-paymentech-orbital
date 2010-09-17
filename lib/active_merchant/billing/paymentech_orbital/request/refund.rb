module ActiveMerchant
  module Billing
    module PaymentechOrbital
      module Request
        class Refund < PaymentechOrbital::Request::Base
          attr_reader :money

          def initialize(money=nil, options={})
            @money = money
            super(options)
          end

          delegate :industry_type, :mb_type, :recurring_start_date,
            :recurring_end_date, :recurring_end_date_flag,
            :recurring_max_billings, :recurring_frequency,
            :deferred_bill_date, :soft_descriptors,
            :to => :options

          def request_type; "NewOrder"; end

          def to_s
            "#{self.class.message_map[@message_type]}: Credit Card (#{credit_card.type if credit_card})"
          end

          private
          def request_body(xml)
            add_meta_info(xml)
            add_billing_address(xml)
            add_order_information(xml)
            add_soft_descriptor_info(xml)
            add_tx_ref_num(xml)
          end
          
          def add_tx_ref_num(xml)
            xml.tag!( "TxRefNum", tx_ref_num) if tx_ref_num
          end
          
          def add_meta_info(xml)
            xml.tag! "IndustryType", industry_type || "EC"
            xml.tag! "MessageType", "R"
            xml.tag! "BIN", bin
            xml.tag! "MerchantID", merchant_id
            xml.tag! "TerminalID", terminal_id
          end

          def add_currency(xml)
            xml.tag! "CurrencyCode", currency_code
            xml.tag! "CurrencyExponent", currency_exponent
          end

          def add_billing_address(xml)
            xml.tag! "AVSzip", address[:zip]
            if full_street_address.length < 30
              xml.tag! "AVSaddress1", full_street_address
            else
              xml.tag! "AVSaddress1", address[:address1]
              xml.tag! "AVSaddress2", address[:address2]
            end
            xml.tag! "AVScity", address[:city]
            xml.tag! "AVSstate", address[:state]
            xml.tag! "AVSphoneNum" , address[:phone]
            xml.tag! "AVSname", address[:name]
            xml.tag! "AVScountryCode", address[:country]
          end
          
          def add_order_information(xml)
            xml.tag! "OrderID", order_id
            xml.tag! "Amount", money if money
          end

          def add_soft_descriptor_info(xml)
            if soft_descriptors
              xml.tag! "SDMerchantName", soft_descriptors[:merchant_name]
              xml.tag! "SDProductDescription", soft_descriptors[:production_description]
              xml.tag! "SDMerchantCity", soft_descriptors[:merchant_city]
              xml.tag! "SDMerchantPhone", soft_descriptors[:merchant_phone]
              xml.tag! "SDMerchantURL", soft_descriptors[:merchant_url]
              xml.tag! "SDMerchantEmail", soft_descriptors[:merchant_email]
            end
          end

        end
      end
    end
  end
end
